setup() {
  set -eu -o pipefail
  export PROJECT_NAME="test-grafana"
  export DDEV_NON_INTERACTIVE=true
  export PROJECT_SOURCE_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TEST_DIR="${BATS_TMPDIR}/${PROJECT_NAME}"
  export TESTDATA_DIR='tests/testdata'
  export OTEL_ENDPOINT_INTERNAL='opentelemetry-grafana'
  export PROJECT_DOMAIN="${PROJECT_NAME}.ddev.site"

  ddev delete -Oy ${PROJECT_NAME} >/dev/null 2>&1 || true
  mkdir -p $TEST_DIR
  cd "${TEST_DIR}"
  ddev config --project-name=${PROJECT_NAME}
  ddev start -y >/dev/null

  ddev exec "mkdir -p ${TESTDATA_DIR}"
  cp -r ${PROJECT_SOURCE_DIR}/${TESTDATA_DIR}/* ${TEST_DIR}/${TESTDATA_DIR}/
}

check_endpoint() {
  set -eu -o pipefail
  local url="$1"
  local expected_output="${2:-NO_CHECK}"
  local run_type="${3:-local}"
  local payload="${4:-''}"

  if [ "$run_type" == "ddev" ]; then
    echo "run ddev exec \"curl -s -X POST -H \"Content-Type: application/json\" -d "$payload" $url\""
    run ddev exec "curl -s -X POST -H \"Content-Type: application/json\" -d "$payload" $url"
  else
    echo "run curl -s -X POST -H \"Content-Type: application/json\" -d "$payload" $url"
    run curl -s -X POST -H "Content-Type: application/json" -d "$payload" $url
  fi
  if [ ! $status -eq 0 ]; then
    echo "curl failed with status $status"
    echo "output: $output"
  fi
  [ $status -eq 0 ]

  if [ "$expected_output" != "NO_CHECK" ]; then
    if [ ! "$expected_output" == "$output" ]; then
      echo "expected_output: $expected_output"
      echo "output: $output"
    fi
    [ "$expected_output" == "$output" ]
  fi
}

check_otel_endpoint() {
  local url="$1"
  local test_asset_filename="$2"
  local run_type="${3:-local}"
  local payload="@${TESTDATA_DIR}/$test_asset_filename"
  local expected_response='{"partialSuccess":{}}'

  check_endpoint $url $expected_response $run_type $payload
}

check_otel_response() {
  set -eu -o pipefail
  local suffix="$1"
  local payload_file="$2"

  check_otel_endpoint "http://${OTEL_ENDPOINT_INTERNAL}${suffix}" $payload_file ddev
  check_otel_endpoint "http://${PROJECT_DOMAIN}${suffix}" $payload_file
  check_otel_endpoint "https://${PROJECT_DOMAIN}${suffix}" $payload_file
}

health_checks() {
  # Wait for services to start.
  sleep 3

  check_endpoint "http://grafana-alloy:12345/-/ready" 'Alloy is ready.' 'ddev'
  check_endpoint "http://grafana:3000/healthz" 'ok' 'ddev'
  check_endpoint "http://grafana-loki:3100/ready" '' 'ddev'
  check_endpoint "http://grafana-mimir:8080/ready" 'ready' 'ddev'
  check_endpoint "http://grafana-tempo:3200/ready" 'NO_CHECK' 'ddev'

  check_endpoint "https://${PROJECT_DOMAIN}:12345/-/ready" 'Alloy is ready.'
  check_endpoint "https://${PROJECT_DOMAIN}:3000/healthz" 'ok'

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
  echo "# ddev add-on get ${PROJECT_SOURCE_DIR} with project ${PROJECT_NAME} in ${TEST_DIR} ($(pwd))" >&3
  ddev add-on get ${PROJECT_SOURCE_DIR}
  ddev restart
  health_checks
}
