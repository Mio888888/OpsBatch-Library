#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-}}"
CONFIRM_RESTART="${2:-${CONFIRM_RESTART:-}}"
CONFIRM_TOKEN="RESTART_SERVICE"

if [[ -z "${SERVICE}" ]]; then
  echo "请设置 SERVICE，或传入要检查/重启的服务名。"
  echo "信息：未执行重启。"
  exit 0
fi

echo "受保护的服务维护计划"
echo "服务: ${SERVICE}"
echo "默认操作：仅状态检查"
echo "重启服务可能中断活动用户或工作负载。"
echo

echo "信息：== 当前服务状态 =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "未找到匹配的 launchctl 服务。"
elif command -v pgrep >/dev/null 2>&1; then
  pgrep -fl "${SERVICE}" || echo "未找到匹配进程: ${SERVICE}."
else
  echo "未找到受支持的 service status命令。"
fi
echo

if [[ "${CONFIRM_RESTART}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：仅状态检查。未执行重启。"
  echo "信息：To restart, rerun with CONFIRM_RESTART=${CONFIRM_TOKEN}."
  exit 0
fi

if command -v systemctl >/dev/null 2>&1; then
  echo "确认令牌已接受。通过 systemctl 重启。"
  systemctl restart "${SERVICE}"
elif command -v service >/dev/null 2>&1; then
  echo "确认令牌已接受。通过 service 重启。"
  service "${SERVICE}" restart
else
  echo "未找到受支持的重启命令。拒绝重启 ${SERVICE}." >&2
  exit 1
fi
