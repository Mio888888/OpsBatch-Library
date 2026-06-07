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
  echo "信息：SERVICE_ACTION 必须是 reload 或 restart。" >&2
  exit 2
fi

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：TIMEOUT 必须是正整数。" >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "信息：TIMEOUT 上限为 60 秒。" >&2
  TIMEOUT=60
fi

echo "受保护的部署服务门禁"
echo "信息：服务： ${SERVICE:-<缺失>}"
echo "信息：Requested action: ${SERVICE_ACTION}"
echo "信息：Validation command: ${VALIDATE_CMD:-<无>}"
echo "信息：健康检查 URL: ${HEALTH_URL:-<无>}"
echo "默认操作：仅状态、验证和计划"
echo "重载或重启服务可能中断活动工作负载。"
echo

if [[ -z "${SERVICE}" ]]; then
  echo "请设置 SERVICE，或将服务名作为第一个参数传入。"
  echo "信息：未执行服务操作。"
  exit 0
fi

echo "信息：== 当前服务状态 =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "未找到匹配的 launchctl 服务。"
else
  echo "未找到受支持的 service status命令。"
fi
echo

echo "信息：== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "信息：正在运行操作员提供的验证命令: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "信息：未提供 VALIDATE_CMD。"
fi
echo

if [[ "${CONFIRM_SERVICE_ACTION}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：仅计划模式。未执行 ${SERVICE_ACTION}。"
  echo "信息：To apply, rerun with CONFIRM_SERVICE_ACTION=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：确认令牌已接受。正在对 ${SERVICE} 应用 ${SERVICE_ACTION}。"
if command -v systemctl >/dev/null 2>&1; then
  if [[ "${SERVICE_ACTION}" == "reload" ]]; then
    systemctl reload "${SERVICE}"
  else
    systemctl restart "${SERVICE}"
  fi
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" "${SERVICE_ACTION}"
else
  echo "未找到受支持的 Linux 服务操作命令。拒绝应用 ${SERVICE_ACTION}." >&2
  exit 1
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "信息：== 操作后健康探测 =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl 不可用; 已跳过健康探测."
  fi
fi
