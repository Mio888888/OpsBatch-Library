#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-}}"
CONFIRM_RESTART="${2:-${CONFIRM_RESTART:-}}"
CONFIRM_TOKEN="RESTART_SERVICE"

if [[ -z "${SERVICE}" ]]; then
  echo "请设置 SERVICE or pass a service name to inspect/restart.（Set SERVICE or pass a service name to inspect/restart.）"
  echo "信息：No restart was performed."
  exit 0
fi

echo "受保护 service maintenance plan（Protected service maintenance plan）"
echo "服务: ${SERVICE}"
echo "默认操作： status only（Default action: status only）"
echo "重启 a service 可能中断 active users or workloads.（Restarting a service may interrupt active users or workloads.）"
echo

echo "信息：== Current service status =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "未找到匹配的 launchctl service found.（No matching launchctl service found.）"
elif command -v pgrep >/dev/null 2>&1; then
  pgrep -fl "${SERVICE}" || echo "未找到匹配进程: ${SERVICE}."
else
  echo "未找到受支持的 service status command found.（No supported service status command found.）"
fi
echo

if [[ "${CONFIRM_RESTART}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：Status only. No restart was performed."
  echo "信息：To restart, rerun with CONFIRM_RESTART=${CONFIRM_TOKEN}."
  exit 0
fi

if command -v systemctl >/dev/null 2>&1; then
  echo "Confirmation token accepted. 重启 via systemctl.（Confirmation token accepted. Restarting via systemctl.）"
  systemctl restart "${SERVICE}"
elif command -v service >/dev/null 2>&1; then
  echo "Confirmation token accepted. 重启 via service.（Confirmation token accepted. Restarting via service.）"
  service "${SERVICE}" restart
else
  echo "未找到受支持的 restart command found. Refusing to restart ${SERVICE}.（No supported restart command found. Refusing to restart ${SERVICE}.）" >&2
  exit 1
fi
