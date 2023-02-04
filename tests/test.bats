setup() {
  set -eu -o pipefail
  VITE_DEV_PORT=5173
  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)/.."
  echo "DIR is $DIR" >&3
  export TEST_FILES=$DIR/tests/testdata
  export TESTDIR=~/tmp/test_vite_serve
  mkdir -p $TESTDIR

  export PROJNAME=ddev-viteserve
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  # copy over php proj
  cp -a $DIR/public .
  # copy over
  ddev config --project-name=${PROJNAME}

  ddev start -y
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || (printf "unable to cd to ${TESTDIR}\n" && exit 1)

  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

print2log() {
  echo "$1" >>~/tmp/errlog.log
}

@test "check laravel proj config" {
  echo "# installing expect utility" >&3
  brew install expect
  echo "# expect installed" >&3
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)

  echo "# laravel project type" >&3
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  type yq >&3
  echo "# config file:" >&3
  cat .ddev/config.yaml >&3
  echo "# eof config.yaml" >&3
  ddev restart

  # Test .env updater
  if [ -f .ddev/.env ]; then
    rm .ddev/.env
  fi

  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  echo "# built custom .env file" >&3
  ddev restart

  # Install a real project
  echo "# Install vanilla project at project root" >&3
  set +e
  npm create -y vite@latest frontend -- --template vanilla
  cd frontend
  cp * ..
  set -e

  echo "# js installed at proj root" >&3

  echo "# call vite-serve with UI" >&3
  eval "run $TEST_FILES/../runselect.exp"
  echo $output >&3

  sleep 10

  # # Test the php web server
  echo "Get URL of project" >&3
  ENDPOINT=$(ddev status -j | jq .raw.urls[0] | tr -d '"')
  echo "# Endpoint is $ENDPOINT" >&3
  curl -k $ENDPOINT -o output.html
  # docker logs ddev-router >&3
  cat output.html >&3
  grep "Vite appears to be listening" output.html || exit 1

}

@test "try using npm as the package manager" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}

  # Install a real project
  echo "# Install vanilla project" >&3
  set +e
  npm create vite@latest frontend -- --template vanilla
  set -e

  echo "# try invalid package manager bun" >&3
  cp $TEST_FILES/use-bun.env .ddev/.env
  ddev restart
  ddev vite-serve && exit 1

  echo "# try valid package manager npm" >&3
  cp $TEST_FILES/use-npm.env .ddev/.env
  ddev restart || exit 1
  ddev vite-serve || exit 1
  sleep 10

  # # Test the php web server
  echo "Get URL of project" >&3
  ENDPOINT=$(ddev status -j | jq .raw.urls[0] | tr -d '"')
  echo "# Endpoint is $ENDPOINT" >&3
  curl -k $ENDPOINT -o output.html
  # docker logs ddev-router >&3
  cat output.html >&3
  grep "Vite appears to be listening" output.html || exit 1

}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3

  # Use pnpm for all these tests
  export VITE_JS_PACKAGE_MGR=pnpm

  ddev get ${DIR}
  echo "# got module from directory" >&3
  ddev restart

  # First see if we installed tmux.
  echo Test for tmux >&3
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  echo "Test vite-serve start with no project (should fail)" >&3
  ddev vite-serve && exit 1

  # Install a real project
  echo "Install vanilla project" >&3
  set +e
  npm create vite@latest frontend -- --template vanilla
  set -e
  echo "# js project installed" >&3
  if ddev vite-serve; then
    # print2log "success?"
    echo success >&3
  else
    echo "vite-serve failed!" >&3
    exit 1
  fi

  # Let project settle
  sleep 10

  # # Test the php web server
  echo "Get URL of project" >&3
  ENDPOINT=$(ddev status -j | jq .raw.urls[0] | tr -d '"')
  echo "# Endpoint is $ENDPOINT" >&3
  curl -k $ENDPOINT -o output.html
  # docker logs ddev-router >&3
  cat output.html >&3
  grep "Vite appears to be listening" output.html || exit 1

  # Test .env updater
  if [ -f .ddev/.env ]; then
    rm .ddev/.env
  fi

  echo "# build default .env" >&3
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  echo "# build done" >&3
  cat .ddev/.env >&3
  echo "# end of .env"
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  # should not change file:
  echo "# repeat build (should be idenpotent)" >&3
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cat .ddev/.env >&3
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  cp $TEST_FILES/other.env .ddev/.env

  echo "# build .env with merge" >&3
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cat .ddev/.env >&3
  cmp -l .ddev/.env $TEST_FILES/other-vite.env >&3 || exit 1

  # should not change file
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cmp -l .ddev/.env $TEST_FILES/other-vite.env >&3 || exit 1
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3

  # Use pnpm for all these tests
  export VITE_JS_PACKAGE_MGR=pnpm

  ddev get torenware/ddev-viteserve
  ddev restart

  # First see if we installed tmux.
  echo Test for tmux >&3
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  ddev vite-serve && exit 1

  # Install a real project
  echo Install vite project >&3
  set +e
  npm create vite@latest frontend -- --template vanilla
  set -e
  if ddev vite-serve; then
    echo success >&3
  else
    echo "vite-serve failed!" >&3
    exit 1
  fi

  # Let project settle
  sleep 10

  # Test the php web server
  echo "Get URL of project" >&3
  ENDPOINT=$(ddev status -j | jq .raw.urls[0] | tr -d '"')
  echo "# Endpoint is $ENDPOINT" >&3
  curl -k $ENDPOINT -o output.html
  # docker logs ddev-router >&3
  cat output.html >&3
  grep "Vite appears to be listening" output.html || exit 1

  # Test .env updater
  if [ -f .ddev/.env ]; then
    rm .ddev/.env
  fi

  echo "# test .env file handling" >&3

  ddev exec .ddev/viteserve/build-dotenv.sh -y >&3
  cat .ddev/.env >&3
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  # should not change file:
  ddev exec .ddev/viteserve/build-dotenv.sh -y >&3
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  cp $TEST_FILES/other.env .ddev/.env

  ddev exec .ddev/viteserve/build-dotenv.sh -y >&3
  cmp -s .ddev/.env $TEST_FILES/other-vite.env || exit 1

  # should not change file
  ddev exec .ddev/viteserve/build-dotenv.sh -y >&3
  cmp -s .ddev/.env $TEST_FILES/other-vite.env || exit 1
}
