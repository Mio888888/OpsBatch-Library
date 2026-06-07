#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-/var/log/system.log}}"
LINES="${2:-${LINES:-100}}"

if [[ ! "${LINES}" =~ ^[0-9]+$ ]]; then
  echo "信息：LINES 必须是正整数。" >&2
  exit 2
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "日志文件未找到: ${LOG_FILE}" >&2
  exit 1
fi

tail -n "${LINES}" "${LOG_FILE}"
