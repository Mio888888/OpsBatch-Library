#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-${LOG_FILE:-}}"
LINES="${2:-${LINES:-1000}}"

if [[ -z "${LOG_FILE}" ]]; then
  echo "请设置 LOG_FILE，或传入要汇总的日志文件路径。" >&2
  exit 2
fi

if [[ ! "${LINES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LINES 必须是正整数。" >&2
  exit 2
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "日志文件未找到: ${LOG_FILE}" >&2
  exit 1
fi

echo "信息：Log maintenance summary"
echo "信息：Log file: ${LOG_FILE}"
echo "信息：从 tail 分析的行数: ${LINES}"
echo "信息：本脚本为只读，不会轮转、截断或归档日志。"
echo

echo "信息：== File details =="
if command -v ls >/dev/null 2>&1; then
  ls -lh "${LOG_FILE}" || true
fi
if command -v wc >/dev/null 2>&1; then
  wc -l "${LOG_FILE}" || true
fi
echo

echo "信息：== 最近严重级别计数 =="
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

echo "信息：== 最近疑似错误行 =="
tail -n "${LINES}" "${LOG_FILE}" | grep -Ei 'error|failed|fatal|critical|panic' | tail -n 20 || echo "信息：未找到近期疑似错误行。"
