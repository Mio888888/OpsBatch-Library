#!/usr/bin/env bash
set -euo pipefail

CURRENT_LINK="${1:-${CURRENT_LINK:-}}"
TARGET_RELEASE="${2:-${TARGET_RELEASE:-}}"
ACTION="${ACTION:-deploy}"
CONFIRM_DEPLOY="${3:-${CONFIRM_DEPLOY:-}}"
CONFIRM_TOKEN="SWITCH_RELEASE"
VALIDATE_CMD="${VALIDATE_CMD:-}"
SERVICE="${SERVICE:-}"
SERVICE_ACTION="${SERVICE_ACTION:-none}"
HEALTH_URL="${HEALTH_URL:-}"
TIMEOUT="${TIMEOUT:-10}"

if [[ ! "${ACTION}" =~ ^(deploy|rollback)$ ]]; then
  echo "信息：ACTION 必须是 deploy 或 rollback。" >&2
  exit 2
fi

if [[ ! "${SERVICE_ACTION}" =~ ^(none|reload|restart)$ ]]; then
  echo "信息：SERVICE_ACTION 必须是 none、reload 或 restart。" >&2
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

echo "受保护的部署发布切换计划"
echo "信息：Action: ${ACTION}"
echo "信息：当前链接: ${CURRENT_LINK:-<缺失>}"
echo "信息：目标发布: ${TARGET_RELEASE:-<缺失>}"
echo "信息：Validation command: ${VALIDATE_CMD:-<无>}"
echo "信息：服务/操作: ${SERVICE:-<无>}/${SERVICE_ACTION}"
echo "信息：健康检查 URL: ${HEALTH_URL:-<无>}"
echo "默认操作：仅计划与验证"
echo "切换发布或重启服务可能中断活动工作负载。"
echo

if [[ -z "${CURRENT_LINK}" || -z "${TARGET_RELEASE}" ]]; then
  echo "请设置 CURRENT_LINK and TARGET_RELEASE, or pass them as the first two arguments."
  echo "信息：未执行部署变更。"
  exit 0
fi

if [[ ! -d "${TARGET_RELEASE}" ]]; then
  echo "目标发布目录未找到: ${TARGET_RELEASE}" >&2
  exit 1
fi

if [[ -e "${CURRENT_LINK}" && ! -L "${CURRENT_LINK}" ]]; then
  echo "信息：当前链接路径存在但不是符号链接；拒绝替换： ${CURRENT_LINK}" >&2
  exit 1
fi

echo "信息：== 当前状态 =="
if [[ -L "${CURRENT_LINK}" ]]; then
  printf '%s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"
else
  echo "信息：当前链接尚不存在。"
fi
ls -ld "${TARGET_RELEASE}" 2>/dev/null || true
echo

echo "信息：== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "信息：正在运行操作员提供的验证命令: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "信息：未提供 VALIDATE_CMD；跳过验证命令。"
fi
echo

echo "信息：== 计划变更 =="
printf 'would_switch: %s -> %s\n' "${CURRENT_LINK}" "${TARGET_RELEASE}"
if [[ "${SERVICE_ACTION}" != "none" ]]; then
  if [[ -z "${SERVICE}" ]]; then
    echo "信息：SERVICE_ACTION=${SERVICE_ACTION} 已请求但 SERVICE 为空；拒绝执行。" >&2
    exit 2
  fi
  printf 'would_%s_service: %s\n' "${SERVICE_ACTION}" "${SERVICE}"
fi
if [[ -n "${HEALTH_URL}" ]]; then
  printf 'would_probe_health_url: %s\n' "${HEALTH_URL}"
fi
echo

if [[ "${CONFIRM_DEPLOY}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：仅计划模式。未切换发布、重载/重启服务或执行部署变更。"
  echo "信息：To apply, rerun with CONFIRM_DEPLOY=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：确认令牌已接受。正在切换发布符号链接。"
ln -sfn "${TARGET_RELEASE}" "${CURRENT_LINK}"
printf 'switched: %s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"

if [[ "${SERVICE_ACTION}" != "none" ]]; then
  echo
  echo "信息：== 服务 ${SERVICE_ACTION} =="
  if command -v systemctl >/dev/null 2>&1; then
    if [[ "${SERVICE_ACTION}" == "reload" ]]; then
      systemctl reload "${SERVICE}"
    else
      systemctl restart "${SERVICE}"
    fi
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" "${SERVICE_ACTION}"
  else
    echo "切换后未找到受支持的服务管理器。可能需要手动执行服务操作。" >&2
    exit 1
  fi
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "信息：== 切换后健康探测 =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl 不可用；无法运行健康探测。" >&2
    exit 1
  fi
fi
