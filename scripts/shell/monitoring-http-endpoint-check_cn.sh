#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:-${TARGET_URL:-http://localhost/}}"
EXPECTED_STATUS="${2:-${EXPECTED_STATUS:-200}}"
TIMEOUT_SECONDS="${3:-${TIMEOUT_SECONDS:-5}}"
LATENCY_WARN_MS="${4:-${LATENCY_WARN_MS:-1000}}"
LATENCY_CRIT_MS="${5:-${LATENCY_CRIT_MS:-3000}}"

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
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ ! "${TARGET_URL}" =~ ^https?:// ]]; then
  unknown "TARGET_URL must start with http:// or https://"
fi
if [[ "${TARGET_URL}" == *[$'\r\n']* ]]; then
  unknown "TARGET_URL must be a single line"
fi
if ! is_positive_int "${EXPECTED_STATUS}" || [[ "${EXPECTED_STATUS}" -lt 100 || "${EXPECTED_STATUS}" -gt 599 ]]; then
  unknown "EXPECTED_STATUS must be an HTTP status code"
fi
if ! is_positive_int "${TIMEOUT_SECONDS}" || ! is_nonnegative_number "${LATENCY_WARN_MS}" || ! is_nonnegative_number "${LATENCY_CRIT_MS}"; then
  unknown "timeout and latency thresholds must be numeric"
fi
if [[ "${TIMEOUT_SECONDS}" -gt 30 ]]; then
  unknown "TIMEOUT_SECONDS must be 30 or less for a bounded HTTP probe"
fi
if ! awk -v warn="${LATENCY_WARN_MS}" -v crit="${LATENCY_CRIT_MS}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "LATENCY_WARN_MS must be less than or equal to LATENCY_CRIT_MS"
fi

status_code=""
elapsed_ms=""
method=""

if command -v curl >/dev/null 2>&1; then
  method="curl"
  curl_output="$(curl -o /dev/null -sS -L --max-time "${TIMEOUT_SECONDS}" -w '%{http_code} %{time_total}' "${TARGET_URL}" 2>/dev/null || true)"
  status_code="$(awk '{print $1}' <<<"${curl_output}")"
  elapsed_seconds="$(awk '{print $2}' <<<"${curl_output}")"
  if [[ -n "${elapsed_seconds}" ]]; then
    elapsed_ms="$(awk -v s="${elapsed_seconds}" 'BEGIN { printf "%.0f", s * 1000 }')"
  fi
elif command -v wget >/dev/null 2>&1; then
  method="wget"
  start_ms="$(now_ms)"
  wget_output="$(wget --server-response --spider --timeout="${TIMEOUT_SECONDS}" "${TARGET_URL}" 2>&1 || true)"
  end_ms="$(now_ms)"
  status_code="$(printf '%s\n' "${wget_output}" | awk '/HTTP\// {code=$2} END {print code}')"
  elapsed_ms="$(awk -v start="${start_ms}" -v end="${end_ms}" 'BEGIN { printf "%.0f", end - start }')"
else
  unknown "curl or wget is required"
fi

if [[ -z "${status_code}" || "${status_code}" == "000" ]]; then
  echo "信息：CRITICAL - HTTP request failed for ${TARGET_URL} using ${method} within ${TIMEOUT_SECONDS}s"
  exit 2
fi

status="OK"
exit_code=0
reason="status and latency within thresholds"
if [[ "${status_code}" != "${EXPECTED_STATUS}" ]]; then
  status="CRITICAL"
  exit_code=2
  reason="status=${status_code} expected=${EXPECTED_STATUS}"
elif compare_ge "${elapsed_ms}" "${LATENCY_CRIT_MS}"; then
  status="CRITICAL"
  exit_code=2
  reason="latency=${elapsed_ms}ms>=${LATENCY_CRIT_MS}ms"
elif compare_ge "${elapsed_ms}" "${LATENCY_WARN_MS}"; then
  status="WARNING"
  exit_code=1
  reason="latency=${elapsed_ms}ms>=${LATENCY_WARN_MS}ms"
fi

echo "信息：${status} - http ${TARGET_URL} status=${status_code} latency=${elapsed_ms}ms (${reason})"
echo "信息：Details: method=${method}; timeout=${TIMEOUT_SECONDS}s; response body and headers are not printed."
exit "${exit_code}"
