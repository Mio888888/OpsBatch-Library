#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-}}"
LINES="${2:-${LINES:-1000}}"

if [[ -z "${LOG_FILE}" ]]; then
  echo "请设置 LOG_FILE or pass a log file path to summarize.（Set LOG_FILE or pass a log file path to summarize.）" >&2
  exit 2
fi

if [[ ! "${LINES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LINES must be a positive integer." >&2
  exit 2
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "Log file 未找到: ${LOG_FILE}（Log file not found: ${LOG_FILE}）" >&2
  exit 1
fi

echo "信息：Log maintenance summary"
echo "信息：Log file: ${LOG_FILE}"
echo "信息：Lines analyzed from tail: ${LINES}"
echo "信息：This script is read-only and does not rotate, truncate, or archive logs."
echo

echo "信息：== File details =="
if command -v ls >/dev/null 2>&1; then
  ls -lh "${LOG_FILE}" || true
fi
if command -v wc >/dev/null 2>&1; then
  wc -l "${LOG_FILE}" || true
fi
echo

echo "信息：== Recent severity counts =="
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

echo "信息：== Recent error-like lines =="
tail -n "${LINES}" "${LOG_FILE}" | grep -Ei 'error|failed|fatal|critical|panic' | tail -n 20 || echo "信息：No recent error-like lines found."
