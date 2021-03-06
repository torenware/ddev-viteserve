setup() {
  set -eu -o pipefail
  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)/.."
  echo "DIR is $DIR"
  export TESTDIR=~/tmp/test_vite_serve
  mkdir -p $TESTDIR
  export PROJNAME=ddev-viteserve
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}

  # Set up a mock listener inside the container
  set +e
  nc -zv localhost 3000 &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Port 3000 occupied; not starting mock listener"
  else
    #mockserver -serverPort 3000 &>/dev/null &
    ddev exec .ddev/commands/web/vite-test-listener >mockserver.pid
  fi
  set -e

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

  # shut the mockserver down
  if [ -f mockserver.pid ]; then
    ddev exec kill $(cat mockserver.pid)
    rm mockserver.pid
  fi

  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

print2log() {
  echo "$1" >>~/tmp/errlog.log
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  ddev get ${DIR}
  ddev restart

  # First see if we installed tmux.
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  ddev vite-serve >/dev/null && exit 1

  # mock a js project and see if we succeed.
  cp -r $DIR/tests/testdata/frontend . || exit 1
  if ddev vite-serve >/dev/null; then
    # print2log "success?"
    echo success
  else
    exit 1
  fi

}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || (echo "unable to cd to ${TESTDIR}\n" && exit 1)
  echo "# ddev get drud/ddev-test_vite_serve with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get torenware/ddev-viteserve
  ddev restart

  # First see if we installed tmux.
  ddev exec type tmux 2>/dev/null || exit 1

  # trying to start the command should fail since there is no project
  ddev vite-serve >/dev/null && exit 1

  # mock a js project and see if we succeed.
  cp -r $DIR/tests/testdata/frontend . || exit 1

  # with the mock this should succeed.
  if ddev vite-serve >/dev/null; then
    # print2log "success?"
    echo success
  else
    exit 1
  fi
}
