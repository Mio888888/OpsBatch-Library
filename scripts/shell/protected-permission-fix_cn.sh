#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-}}"
TARGET_MODE="${2:-${TARGET_MODE:-}}"
CONFIRM_CHMOD="${3:-${CONFIRM_CHMOD:-}}"
CONFIRM_TOKEN="APPLY_TARGET_MODE"

if [[ -z "${TARGET_PATH}" ]]; then
  echo "请设置 TARGET_PATH，或传入要检查权限的路径。"
  echo "信息：未执行权限变更。"
  exit 0
fi

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "目标路径未找到: ${TARGET_PATH}" >&2
  exit 1
fi

echo "受保护 permission maintenance plan"
echo "信息：目标路径: ${TARGET_PATH}"
echo "信息：请求权限模式: ${TARGET_MODE:-<无>}"
echo "默认操作：仅检查"
echo "信息：更改权限可能暴露或阻断对文件和服务的访问。"
echo

echo "信息：== 当前权限 =="
ls -ld "${TARGET_PATH}"
if command -v stat >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin|FreeBSD)
      stat -f 'mode=%Lp owner=%Su group=%Sg path=%N' "${TARGET_PATH}" || true
      ;;
    *)
      stat -c 'mode=%a owner=%U group=%G path=%n' "${TARGET_PATH}" || true
      ;;
  esac
fi
echo

if [[ -z "${TARGET_MODE}" ]]; then
  echo "信息：未提供 TARGET_MODE。检查完成；未执行权限变更。"
  exit 0
fi

if [[ ! "${TARGET_MODE}" =~ ^[0-7]{3,4}$ ]]; then
  echo "信息：TARGET_MODE 必须是八进制权限模式，例如 0644 或 0750。" >&2
  exit 2
fi

echo "信息：计划变更：chmod ${TARGET_MODE} ${TARGET_PATH}"
if [[ "${CONFIRM_CHMOD}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：仅计划。未执行权限变更。"
  echo "信息：To apply, rerun with CONFIRM_CHMOD=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：确认令牌已接受。正在应用 chmod."
chmod "${TARGET_MODE}" "${TARGET_PATH}"
ls -ld "${TARGET_PATH}"
