#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-/var/log/system.log}}"
LINES="${2:-${LINES:-100}}"

if [[ ! "${LINES}" =~ ^[0-9]+$ ]]; then
  echo "信息：LINES must be a positive integer." >&2
  exit 2
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "Log file 未找到: ${LOG_FILE}（Log file not found: ${LOG_FILE}）" >&2
  exit 1
fi

tail -n "${LINES}" "${LOG_FILE}"
