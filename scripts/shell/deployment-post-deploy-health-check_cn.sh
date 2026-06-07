#!/usr/bin/env bash
set -euo pipefail

HEALTH_URL="${1:-${HEALTH_URL:-}}"
SERVICE="${2:-${SERVICE:-}}"
HOST="${HOST:-}"
PORT="${PORT:-}"
TIMEOUT="${TIMEOUT:-10}"
ATTEMPTS="${ATTEMPTS:-3}"

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：TIMEOUT must be a positive integer." >&2
  exit 2
fi

if [[ ! "${ATTEMPTS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：ATTEMPTS must be a positive integer." >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "信息：TIMEOUT is capped at 60 seconds." >&2
  TIMEOUT=60
fi

if (( ATTEMPTS > 10 )); then
  echo "信息：ATTEMPTS is capped at 10." >&2
  ATTEMPTS=10
fi

echo "信息：Deployment post-deploy health check"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Health URL: ${HEALTH_URL:-<not provided>}"
echo "信息：Service: ${SERVICE:-<not provided>}"
echo "信息：Host/port: ${HOST:-<not provided>}/${PORT:-<not provided>}"
echo "信息：This script performs bounded read-only health probes only."
echo

status=0

echo "信息：== Service health =="
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
    echo "未找到受支持的 service manager found.（No supported service manager found.）"
  fi
else
  echo "信息：No SERVICE provided."
fi
echo

echo "信息：== HTTP health URL =="
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
    echo "curl 不可用.（curl not available.）"
    status=1
  fi
else
  echo "信息：No HEALTH_URL provided."
fi
echo

echo "信息：== TCP health =="
if [[ -n "${HOST}" && -n "${PORT}" ]]; then
  if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
    echo "信息：PORT must be between 1 and 65535." >&2
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
    echo "信息：No bounded TCP probe tool found."
    status=1
  fi
else
  echo "信息：No HOST and PORT provided."
fi

exit "${status}"
