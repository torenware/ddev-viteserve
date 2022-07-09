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
  ddev delete -Oy ${PROJNAME}
  #[ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

print2log() {
  echo "$1" >>~/tmp/errlog.log
}

@test "install from directory" {
  set -eu -o pipefail
  # print2log '# Hello, terminal!'
  cd ${TESTDIR}
  # print2log "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))"
  ddev get ${DIR}
  ddev restart
  # Do something here to verify functioning extra service
  # For extra credit, use a real CMS with actual config.
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"

  # First see if we installed tmux.
  ddev exec type tmux 2>/dev/null || exit 1
  # print2log "tmux found"

  # trying to start the command should fail since there is no project
  # print2log "does a lack of front end cause a fail?"
  ddev vite-serve >/dev/null && exit 1
  # print2log "# No frontend, and vite-server correctly fails to start"

  # mock a js project and see if we succeed.
  # createmockproj
  # print2log "# cp -r $DIR/tests/testdata/frontend ${TESTDIR}"
  # print2log "# try to install frontend mock" >&3
  cp -r $DIR/tests/testdata/frontend . || exit 1
  # print2log "# try to test if we succeed with mock"
  if ddev vite-serve >/dev/null; then
    // # print2log "success?"
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
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
}
