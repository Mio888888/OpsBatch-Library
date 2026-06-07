#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-}}"
SERVICE_ACTION="${2:-${SERVICE_ACTION:-reload}}"
CONFIRM_SERVICE_ACTION="${3:-${CONFIRM_SERVICE_ACTION:-}}"
CONFIRM_TOKEN="APPLY_SERVICE_ACTION"
VALIDATE_CMD="${VALIDATE_CMD:-}"
HEALTH_URL="${HEALTH_URL:-}"
TIMEOUT="${TIMEOUT:-10}"

if [[ ! "${SERVICE_ACTION}" =~ ^(reload|restart)$ ]]; then
  echo "信息：SERVICE_ACTION must be reload or restart." >&2
  exit 2
fi

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：TIMEOUT must be a positive integer." >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "信息：TIMEOUT is capped at 60 seconds." >&2
  TIMEOUT=60
fi

echo "受保护 deployment service gate（Protected deployment service gate）"
echo "信息：Service: ${SERVICE:-<missing>}"
echo "信息：Requested action: ${SERVICE_ACTION}"
echo "信息：Validation command: ${VALIDATE_CMD:-<none>}"
echo "信息：Health URL: ${HEALTH_URL:-<none>}"
echo "默认操作： status, validation, and plan only（Default action: status, validation, and plan only）"
echo "Reloading or restarting a service 可能中断 active workloads.（Reloading or restarting a service may interrupt active workloads.）"
echo

if [[ -z "${SERVICE}" ]]; then
  echo "请设置 SERVICE or pass a service name as the first argument.（Set SERVICE or pass a service name as the first argument.）"
  echo "信息：No service action was performed."
  exit 0
fi

echo "信息：== Current service status =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "未找到匹配的 launchctl service found.（No matching launchctl service found.）"
else
  echo "未找到受支持的 service status command found.（No supported service status command found.）"
fi
echo

echo "信息：== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "信息：Running validation command supplied by operator: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "信息：No VALIDATE_CMD supplied."
fi
echo

if [[ "${CONFIRM_SERVICE_ACTION}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：Plan only. No ${SERVICE_ACTION} was performed."
  echo "信息：To apply, rerun with CONFIRM_SERVICE_ACTION=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：Confirmation token accepted. Applying ${SERVICE_ACTION} to ${SERVICE}."
if command -v systemctl >/dev/null 2>&1; then
  if [[ "${SERVICE_ACTION}" == "reload" ]]; then
    systemctl reload "${SERVICE}"
  else
    systemctl restart "${SERVICE}"
  fi
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" "${SERVICE_ACTION}"
else
  echo "未找到受支持的 Linux service action command found. Refusing to apply ${SERVICE_ACTION}.（No supported Linux service action command found. Refusing to apply ${SERVICE_ACTION}.）" >&2
  exit 1
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "信息：== Post-action health probe =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl 不可用; health probe skipped.（curl not available; health probe skipped.）"
  fi
fi
