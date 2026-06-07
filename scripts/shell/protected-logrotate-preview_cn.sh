#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_CONFIG="${1:-${LOGROTATE_CONFIG:-}}"
CONFIRM_ROTATE="${2:-${CONFIRM_ROTATE:-}}"
CONFIRM_TOKEN="RUN_LOGROTATE"

if [[ -z "${LOGROTATE_CONFIG}" ]]; then
  echo "请设置 LOGROTATE_CONFIG，或传入 logrotate 配置路径。"
  echo "信息：未执行日志轮转。"
  exit 0
fi

if [[ ! -f "${LOGROTATE_CONFIG}" ]]; then
  echo "Logrotate config 未找到: ${LOGROTATE_CONFIG}" >&2
  exit 1
fi

if ! command -v logrotate >/dev/null 2>&1; then
  echo "此主机上 logrotate 命令不可用。" >&2
  exit 1
fi

echo "受保护 logrotate maintenance plan"
echo "信息：Config: ${LOGROTATE_CONFIG}"
echo "默认操作：仅 debug/dry-run（调试/试运行）"
echo "信息：真实轮转可能移动、压缩、截断、删除日志并运行 postrotate 钩子。"
echo

echo "信息：== logrotate debug output =="
logrotate -d "${LOGROTATE_CONFIG}"
echo

if [[ "${CONFIRM_ROTATE}" != "${CONFIRM_TOKEN}" ]]; then
  echo "仅试运行。未执行日志轮转。"
  echo "信息：要执行真实轮转，请重新运行并设置 CONFIRM_ROTATE=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：确认令牌已接受。正在运行 logrotate 并输出详细信息。"
logrotate -v "${LOGROTATE_CONFIG}"
