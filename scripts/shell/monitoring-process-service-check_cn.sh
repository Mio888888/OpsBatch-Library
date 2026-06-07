#!/usr/bin/env bash
set -euo pipefail

TARGET_NAME="${1:-${TARGET_NAME:-ssh}}"
MODE="${2:-${MODE:-service}}"
MIN_COUNT="${3:-${MIN_COUNT:-1}}"
MAX_COUNT="${4:-${MAX_COUNT:-0}}"

is_nonnegative_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

unknown() {
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ -z "${TARGET_NAME}" ]]; then
  unknown "target name must not be empty"
fi
if [[ "${TARGET_NAME}" == -* ]]; then
  unknown "TARGET_NAME must not start with '-'"
fi
if [[ "${MODE}" != "service" && "${MODE}" != "process" ]]; then
  unknown "MODE must be service or process"
fi
if ! is_nonnegative_int "${MIN_COUNT}" || ! is_nonnegative_int "${MAX_COUNT}"; then
  unknown "MIN_COUNT and MAX_COUNT must be non-negative integers"
fi
if [[ "${MAX_COUNT}" -gt 0 && "${MIN_COUNT}" -gt "${MAX_COUNT}" ]]; then
  unknown "MIN_COUNT must be less than or equal to MAX_COUNT when MAX_COUNT is set"
fi

status="OK"
exit_code=0
detail=""
count="0"

if [[ "${MODE}" == "service" ]]; then
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "${TARGET_NAME}"; then
      detail="systemctl reports active"
      count="1"
    else
      state="$(systemctl is-active "${TARGET_NAME}" 2>/dev/null || true)"
      detail="systemctl state=${state:-未知}"
      count="0"
    fi
  elif command -v service >/dev/null 2>&1; then
    if service "${TARGET_NAME}" status >/dev/null 2>&1; then
      detail="service command reports running"
      count="1"
    else
      detail="service command did not report running"
      count="0"
    fi
  else
    MODE="process"
    detail="服务管理器不可用；已回退到进程匹配"
  fi
fi

if [[ "${MODE}" == "process" ]]; then
  if command -v pgrep >/dev/null 2>&1; then
    count="$(pgrep -x "${TARGET_NAME}" 2>/dev/null | wc -l | tr -d ' ' || true)"
    if [[ "${count}" == "0" ]]; then
      count="$(pgrep -f "${TARGET_NAME}" 2>/dev/null | wc -l | tr -d ' ' || true)"
      detail="pgrep -f match count=${count}"
    else
      detail="pgrep -x exact match count=${count}"
    fi
  elif command -v ps >/dev/null 2>&1; then
    count="$(ps -Ao comm= 2>/dev/null | awk -v name="${TARGET_NAME}" '$0 == name {c++} END {print c+0}')"
    detail="ps exact command match count=${count}"
  else
    unknown "no supported process inspection command found"
  fi
fi

if [[ "${count}" -lt "${MIN_COUNT}" ]]; then
  status="CRITICAL"
  exit_code=2
  detail="${detail}; count ${count} below minimum ${MIN_COUNT}"
elif [[ "${MAX_COUNT}" -gt 0 && "${count}" -gt "${MAX_COUNT}" ]]; then
  status="WARNING"
  exit_code=1
  detail="${detail}; count ${count} above maximum ${MAX_COUNT}"
fi

echo "信息：${status} - ${MODE}=${TARGET_NAME} count=${count} min=${MIN_COUNT} max=${MAX_COUNT}"
echo "信息：详情：${detail}"
if command -v pgrep >/dev/null 2>&1; then
  echo "信息：匹配进程（有界）:"
  pgrep -fl "${TARGET_NAME}" 2>/dev/null | head -n 10 || true
fi
exit "${exit_code}"
