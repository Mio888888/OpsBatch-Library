#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-}}"
LINES="${2:-${LINES:-1000}}"

if [[ -z "${LOG_FILE}" ]]; then
  echo "Set LOG_FILE or pass a log file path to summarize." >&2
  exit 2
fi

if [[ ! "${LINES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LINES must be a positive integer." >&2
  exit 2
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "Log file not found: ${LOG_FILE}" >&2
  exit 1
fi

echo "Log maintenance summary"
echo "Log file: ${LOG_FILE}"
echo "Lines analyzed from tail: ${LINES}"
echo "This script is read-only and does not rotate, truncate, or archive logs."
echo

echo "== File details =="
if command -v ls >/dev/null 2>&1; then
  ls -lh "${LOG_FILE}" || true
fi
if command -v wc >/dev/null 2>&1; then
  wc -l "${LOG_FILE}" || true
fi
echo

echo "== Recent severity counts =="
tail -n "${LINES}" "${LOG_FILE}" | awk '
  BEGIN { info=0; warn=0; error=0; critical=0 }
  /[Ii][Nn][Ff][Oo]/ { info++ }
  /[Ww][Aa][Rr][Nn]/ { warn++ }
  /[Ee][Rr][Rr][Oo][Rr]/ { error++ }
  /[Cc][Rr][Ii][Tt]|[Ff][Aa][Tt][Aa][Ll]/ { critical++ }
  END {
    printf "info=%d\nwarn=%d\nerror=%d\ncritical_or_fatal=%d\n", info, warn, error, critical
  }
'
echo

echo "== Recent error-like lines =="
tail -n "${LINES}" "${LOG_FILE}" | grep -Ei 'error|failed|fatal|critical|panic' | tail -n 20 || echo "No recent error-like lines found."
