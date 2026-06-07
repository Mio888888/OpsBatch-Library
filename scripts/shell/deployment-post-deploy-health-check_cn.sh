#!/usr/bin/env bash
set -euo pipefail

HEALTH_URL="${1:-${HEALTH_URL:-}}"
SERVICE="${2:-${SERVICE:-}}"
HOST="${HOST:-}"
PORT="${PORT:-}"
TIMEOUT="${TIMEOUT:-10}"
ATTEMPTS="${ATTEMPTS:-3}"

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：TIMEOUT 必须是正整数。" >&2
  exit 2
fi

if [[ ! "${ATTEMPTS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：ATTEMPTS 必须是正整数。" >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "信息：TIMEOUT 上限为 60 秒。" >&2
  TIMEOUT=60
fi

if (( ATTEMPTS > 10 )); then
  echo "信息：ATTEMPTS 上限为 10。" >&2
  ATTEMPTS=10
fi

echo "信息：部署后健康检查"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：健康检查 URL: ${HEALTH_URL:-<未提供>}"
echo "信息：服务： ${SERVICE:-<未提供>}"
echo "信息：主机/端口: ${HOST:-<未提供>}/${PORT:-<未提供>}"
echo "信息：本脚本只执行有界的只读健康探测。"
echo

status=0

echo "信息：== 服务健康状态 =="
if [[ -n "${SERVICE}" ]]; then
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "${SERVICE}"; then
      echo "信息：service_active=1 manager=systemctl"
    else
      echo "信息：service_active=0 manager=systemctl"
      status=1
    fi
  elif command -v service >/dev/null 2>&1; then
    if service "${SERVICE}" status >/dev/null 2>&1; then
      echo "信息：service_status_ok=1 manager=service"
    else
      echo "信息：service_status_ok=0 manager=service"
      status=1
    fi
  elif command -v launchctl >/dev/null 2>&1; then
    if launchctl print "system/${SERVICE}" >/dev/null 2>&1 || launchctl print "gui/$(id -u)/${SERVICE}" >/dev/null 2>&1; then
      echo "信息：service_present=1 manager=launchctl"
    else
      echo "信息：service_present=0 manager=launchctl"
      status=1
    fi
  else
    echo "未找到受支持的 服务管理器。"
  fi
else
  echo "信息：未提供 SERVICE。"
fi
echo

echo "信息：== HTTP 健康检查 URL =="
if [[ -n "${HEALTH_URL}" ]]; then
  if command -v curl >/dev/null 2>&1; then
    success=0
    for attempt in $(seq 1 "${ATTEMPTS}"); do
      echo "信息：attempt=${attempt}"
      if curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"; then
        success=1
        break
      fi
    done
    if [[ "${success}" != "1" ]]; then
      status=1
    fi
  else
    echo "curl 不可用."
    status=1
  fi
else
  echo "信息：未提供 HEALTH_URL。"
fi
echo

echo "信息：== TCP 健康状态 =="
if [[ -n "${HOST}" && -n "${PORT}" ]]; then
  if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
    echo "信息：PORT 必须介于 1 到 65535 之间。" >&2
    exit 2
  fi
  if command -v nc >/dev/null 2>&1; then
    nc -z -w "${TIMEOUT}" "${HOST}" "${PORT}" && echo "信息：tcp_connect=ok" || { echo "信息：tcp_connect=failed"; status=1; }
  elif command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
    if timeout "${TIMEOUT}" bash -c ': < /dev/tcp/$1/$2' _ "${HOST}" "${PORT}" 2>/dev/null; then
      echo "信息：tcp_connect=ok"
    else
      echo "信息：tcp_connect=failed"
      status=1
    fi
  else
    echo "信息：未找到有界 TCP 探测工具。"
    status=1
  fi
else
  echo "信息：未提供 HOST 和 PORT。"
fi

exit "${status}"
