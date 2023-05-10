setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-grafana
  mkdir -p $TESTDIR
  export PROJNAME=test-grafana
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  # Wait for services to start up.
  sleep 30
  # printenv

  # Workaround for failing checks on GitHub actions
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    DDEV_CLOUD_ENV=1
  else
    DDEV_CLOUD_ENV=
  fi
  # Add the `[ -z "$DDEV_CLOUD_ENV" ] && ` prefix to execute a check only
  # on local launches of bats tests.

  # Grafana service
  ddev exec "curl -s http://grafana:3000/api/health"
  curl -s http://${PROJNAME}.ddev.site:3001/api/health
  curl -s https://${PROJNAME}.ddev.site/
  curl -s https://${PROJNAME}.ddev.site:3000/api/health

  # Loki service
  # Loki takes 15+ secs to initialize, so use the http://loki:3100/ready url
  # is not a good idea, just checking the services endpoint.
  ddev exec "curl -s http://loki:3100/services"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s http://localhost:3100/services"
  [ -z "$DDEV_CLOUD_ENV" ] && curl -s https://${PROJNAME}.ddev.site:3100/services

  # Prometeus service
  ddev exec "curl -s http://prometheus:9090/-/ready"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s http://localhost:9090/-/ready"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s https://${PROJNAME}.ddev.site:9090/-/ready"

  # Tempo service
  # Tempo takes 15 secs to initialize, so use the http://tempo:3200/ready url
  # is not a good idea, just checking the version endpoint.
  ddev exec "curl -s http://tempo:3200/status/version"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s http://localhost:3200/status/version"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s https://${PROJNAME}.ddev.site:3200/status/version"

  # Tempo HTTP receivers ports
  ddev exec "curl -s http://tempo:4318/"
 [ -z "$DDEV_CLOUD_ENV" ] &&  ddev exec "curl -s https://${PROJNAME}.ddev.site:4318/"
  ddev exec "curl -s http://tempo:9411/"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s https://${PROJNAME}.ddev.site:9411/"
  ddev exec "curl -s http://tempo:14268/"
  [ -z "$DDEV_CLOUD_ENV" ] && ddev exec "curl -s https://${PROJNAME}.ddev.site:14268/"

}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  # Do something here to verify functioning extra service
  # For extra credit, use a real CMS with actual config.
  health_checks
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get MurzNN/ddev-grafana with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get MurzNN/ddev-grafana
  ddev restart >/dev/null
  health_checks
}

