#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-}}"
PATTERN="${2:-${PATTERN:-error|critical|fatal}}"
MAX_LINES="${3:-${MAX_LINES:-1000}}"
WARN_COUNT="${4:-${WARN_COUNT:-1}}"
CRIT_COUNT="${5:-${CRIT_COUNT:-10}}"

is_nonnegative_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

if [[ -z "${LOG_FILE}" ]]; then
  for candidate in /var/log/system.log /var/log/syslog /var/log/messages; do
    if [[ -r "${candidate}" ]]; then
      LOG_FILE="${candidate}"
      break
    fi
  done
fi

if [[ -z "${LOG_FILE}" || ! -r "${LOG_FILE}" ]]; then
  unknown "no readable log file found; set LOG_FILE or pass a path explicitly"
fi
if [[ "${LOG_FILE}" == -* ]]; then
  unknown "LOG_FILE must not start with '-'"
fi
if [[ -z "${PATTERN}" ]]; then
  unknown "PATTERN must not be empty"
fi
if ! is_positive_int "${MAX_LINES}" || ! is_nonnegative_int "${WARN_COUNT}" || ! is_nonnegative_int "${CRIT_COUNT}"; then
  unknown "MAX_LINES must be positive; WARN_COUNT and CRIT_COUNT must be non-negative integers"
fi
if [[ "${MAX_LINES}" -gt 100000 ]]; then
  unknown "MAX_LINES must be 100000 or less for bounded log inspection"
fi
if [[ "${WARN_COUNT}" -gt "${CRIT_COUNT}" ]]; then
  unknown "WARN_COUNT must be less than or equal to CRIT_COUNT"
fi
grep_status=0
grep -Eq -- "${PATTERN}" </dev/null 2>/dev/null || grep_status=$?
if [[ "${grep_status}" -eq 2 ]]; then
  unknown "PATTERN must be a valid extended regular expression"
fi

count="$(tail -n "${MAX_LINES}" "${LOG_FILE}" 2>/dev/null | grep -Eic -- "${PATTERN}" || true)"

status="OK"
exit_code=0
if [[ "${count}" -ge "${CRIT_COUNT}" ]]; then
  status="CRITICAL"
  exit_code=2
elif [[ "${count}" -ge "${WARN_COUNT}" ]]; then
  status="WARNING"
  exit_code=1
fi

echo "${status} - log_matches=${count} file=${LOG_FILE} max_lines=${MAX_LINES} warn=${WARN_COUNT} crit=${CRIT_COUNT}"
echo "Details: pattern was counted case-insensitively; matching log lines are not printed to avoid leaking sensitive content."
exit "${exit_code}"
