setup() {
  export PROJECT_NAME=test-grafana
  # export PROJECT_NAME=test-grafana-local # tmp

  set -eu -o pipefail
  export DDEV_NON_INTERACTIVE=true
  export PROJECT_SOURCE_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TEST_DIR="${BATS_TMPDIR}/${PROJECT_NAME}"
  # export TEST_DIR="${PROJECT_SOURCE_DIR}/../${PROJECT_NAME}" # tmp
  export TESTDATA_DIR='tests/testdata'
  export OTEL_ENDPOINT_INTERNAL='opentelemetry-grafana'
  export PROJECT_DOMAIN="${PROJECT_NAME}.ddev.site"

  ddev delete -Oy ${PROJECT_NAME} >/dev/null 2>&1 || true
  mkdir -p $TEST_DIR
  cd "${TEST_DIR}"
  ddev config --project-name=${PROJECT_NAME}
  ddev start -y >/dev/null

  ddev exec "mkdir -p ${TESTDATA_DIR}" #tmp
  cp -r ${PROJECT_SOURCE_DIR}/${TESTDATA_DIR}/* ${TEST_DIR}/${TESTDATA_DIR}/
}

check_otel_endpoint() {
  set -eu -o pipefail
  local url="$1"
  local use_local="$2"
  local payload_file="$3"
  local expected_output_default='{"partialSuccess":{}}'
  local expected_output="${4:-$expected_output_default}"

  if [ $use_local -eq 1 ]; then
    echo "run curl -s -X POST -H \"Content-Type: application/json\" -d @${TESTDATA_DIR}/$payload_file $url"
    run curl -s -X POST -H "Content-Type: application/json" -d @${TESTDATA_DIR}/$payload_file $url
  else
    echo "run ddev exec \"curl -s -X POST -H \"Content-Type: application/json\" -d @${TESTDATA_DIR}/$payload_file $url\""
    run ddev exec "curl -s -X POST -H \"Content-Type: application/json\" -d @${TESTDATA_DIR}/$payload_file $url"
  fi
  echo "output: $output"
  [ $status -eq 0 ]
  [ "$expected_output" == "$output" ]
}

check_otel_response() {
  set -eu -o pipefail
  local suffix="$1"
  local payload_file="$2"

  check_otel_endpoint "http://${OTEL_ENDPOINT_INTERNAL}${suffix}" 0 $payload_file
  check_otel_endpoint "http://${PROJECT_DOMAIN}${suffix}" 1 $payload_file
  check_otel_endpoint "https://${PROJECT_DOMAIN}${suffix}" 1 $payload_file
}

health_checks() {
  sleep 10
  check_otel_response ":4318/v1/traces" "test-trace.json"
  check_otel_response ":4318/v1/metrics" "test-metric.json"
  check_otel_response ":4318/v1/logs" "test-log.json"
}

teardown() {
  ddev logs
  set -eu -o pipefail
  cd ${TEST_DIR} || ( printf "unable to cd to ${TEST_DIR}\n" && exit 1 )
  ddev rm -Oy ${PROJECT_NAME} >/dev/null 2>&1
  [ "${TEST_DIR}" != "" ] && rm -rf ${TEST_DIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TEST_DIR}
  echo "# ddev get ${PROJECT_SOURCE_DIR} with project ${PROJECT_NAME} in ${TEST_DIR} ($(pwd))" >&3
  ddev add-on get ${PROJECT_SOURCE_DIR}
  ddev restart
  health_checks
}

# @test "install from release" {
#   set -eu -o pipefail
#   cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#   echo "# ddev get MurzNN/ddev-grafana with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#   ddev addon get MurzNN/ddev-grafana
#   ddev restart >/dev/null
#   health_checks
# }

