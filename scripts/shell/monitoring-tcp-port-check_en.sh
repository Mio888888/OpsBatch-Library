#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${1:-${TARGET_HOST:-localhost}}"
TARGET_PORT="${2:-${TARGET_PORT:-22}}"
TIMEOUT_SECONDS="${3:-${TIMEOUT_SECONDS:-3}}"
LATENCY_WARN_MS="${4:-${LATENCY_WARN_MS:-500}}"
LATENCY_CRIT_MS="${5:-${LATENCY_CRIT_MS:-1000}}"

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

is_nonnegative_number() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

compare_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'
}

now_ms() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import time; print(int(time.time() * 1000))'
  else
    awk -v seconds="$(date +%s)" 'BEGIN { printf "%.0f", seconds * 1000 }'
  fi
}

unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

if [[ -z "${TARGET_HOST}" ]]; then
  unknown "TARGET_HOST must not be empty"
fi
if [[ "${TARGET_HOST}" == -* ]]; then
  unknown "TARGET_HOST must not start with '-'"
fi
if ! is_positive_int "${TARGET_PORT}" || [[ "${TARGET_PORT}" -gt 65535 ]]; then
  unknown "TARGET_PORT must be an integer between 1 and 65535"
fi
if ! is_positive_int "${TIMEOUT_SECONDS}" || ! is_nonnegative_number "${LATENCY_WARN_MS}" || ! is_nonnegative_number "${LATENCY_CRIT_MS}"; then
  unknown "timeout and latency thresholds must be numeric"
fi
if [[ "${TIMEOUT_SECONDS}" -gt 30 ]]; then
  unknown "TIMEOUT_SECONDS must be 30 or less for a bounded TCP probe"
fi
if ! awk -v warn="${LATENCY_WARN_MS}" -v crit="${LATENCY_CRIT_MS}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "LATENCY_WARN_MS must be less than or equal to LATENCY_CRIT_MS"
fi

start_ms="$(now_ms)"
connect_ok="false"
method=""

if command -v nc >/dev/null 2>&1; then
  method="nc"
  if nc -z -w "${TIMEOUT_SECONDS}" "${TARGET_HOST}" "${TARGET_PORT}" >/dev/null 2>&1; then
    connect_ok="true"
  fi
else
  method="bash /dev/tcp"
  if command -v timeout >/dev/null 2>&1; then
    if timeout "${TIMEOUT_SECONDS}" bash -c ': < /dev/tcp/$1/$2' _ "${TARGET_HOST}" "${TARGET_PORT}" >/dev/null 2>&1; then
      connect_ok="true"
    fi
  else
    unknown "nc or timeout is required for a bounded TCP probe"
  fi
fi

end_ms="$(now_ms)"
elapsed_ms="$(awk -v start="${start_ms}" -v end="${end_ms}" 'BEGIN { printf "%.0f", end - start }')"

if [[ "${connect_ok}" != "true" ]]; then
  echo "CRITICAL - tcp ${TARGET_HOST}:${TARGET_PORT} connection failed using ${method} within ${TIMEOUT_SECONDS}s"
  exit 2
fi

status="OK"
exit_code=0
if compare_ge "${elapsed_ms}" "${LATENCY_CRIT_MS}"; then
  status="CRITICAL"
  exit_code=2
elif compare_ge "${elapsed_ms}" "${LATENCY_WARN_MS}"; then
  status="WARNING"
  exit_code=1
fi

echo "${status} - tcp ${TARGET_HOST}:${TARGET_PORT} connected in ${elapsed_ms}ms warn=${LATENCY_WARN_MS}ms crit=${LATENCY_CRIT_MS}ms"
echo "Details: method=${method}; timeout=${TIMEOUT_SECONDS}s; single-target read-only probe."
exit "${exit_code}"
