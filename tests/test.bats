setup() {
  set -eu -o pipefail
  VITE_DEV_PORT=5173
  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)/.."
  echo "DIR is $DIR"
  export TEST_FILES=$DIR/tests/testdata
  export TESTDIR=~/tmp/test_vite_serve
  mkdir -p $TESTDIR
  export PROJNAME=ddev-viteserve
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}

  # Set up a mock listener inside the container
  # set +e
  # ddev exec nc -zv localhost $VITE_DEV_PORT &
  # if [ $? -eq 0 ]; then
  #   echo "Port $VITE_DEV_PORT occupied; not starting mock listener"
  # else
  #   ddev exec .ddev/viteserve/vite-test-listener $VITE_DEV_PORT >mockserver.pid
  # fi
  # set -e

  # fix the config so we don't clash on ports
  cat >>.ddev/config.yaml <<PORT_UPDATE
router_http_port: "9990"
router_https_port: "9943"
PORT_UPDATE

  ddev start
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || (printf "unable to cd to ${TESTDIR}\n" && exit 1)

  # We're using a real vite proj now, so tearing down
  # ddev will take down the project.

  # shut the mockserver down
  # if [ -f mockserver.pid ]; then
  #   ddev exec kill $(cat mockserver.pid)
  #   rm mockserver.pid
  # fi

  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

print2log() {
  echo "$1" >>~/tmp/errlog.log
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart

  # First see if we installed tmux.
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  ddev vite-serve && exit 1

  # Install a real project
  set +e
  npm create vite@latest frontend -- --template vanilla
  set -e
  if ddev vite-serve; then
    # print2log "success?"
    echo success
  else
    exit 1
  fi

  # Test .env updater
  if [ -f .ddev/.env ]; then
    rm .ddev/.env
  fi

  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  # should not change file:
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cmp -s .ddev/.env $TEST_FILES/all-vite.env || exit 1

  cp $TEST_FILES/other.env .ddev/.env

  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cmp -s .ddev/.env $TEST_FILES/other-vite.env || exit 1

  # should not change file
  ddev exec .ddev/viteserve/build-dotenv.sh -y >/dev/null
  cmp -s .ddev/.env $TEST_FILES/other-vite.env || exit 1
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get torenware/ddev-viteserve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get torenware/ddev-viteserve
  ddev restart

  # First see if we installed tmux.
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  ddev vite-serve && exit 1

  # Install a real project
  set +e
  npm create vite@latest frontend -- --template vanilla
  set -e
  if ddev vite-serve; then
    echo success
  else
    exit 1
  fi
}
