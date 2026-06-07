#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-}}"
TARGET_MODE="${2:-${TARGET_MODE:-}}"
CONFIRM_CHMOD="${3:-${CONFIRM_CHMOD:-}}"
CONFIRM_TOKEN="APPLY_TARGET_MODE"

if [[ -z "${TARGET_PATH}" ]]; then
  echo "请设置 TARGET_PATH or pass a path to inspect permissions.（Set TARGET_PATH or pass a path to inspect permissions.）"
  echo "信息：No permission changes were performed."
  exit 0
fi

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "Target path 未找到: ${TARGET_PATH}（Target path not found: ${TARGET_PATH}）" >&2
  exit 1
fi

echo "受保护 permission maintenance plan（Protected permission maintenance plan）"
echo "信息：Target path: ${TARGET_PATH}"
echo "信息：Requested mode: ${TARGET_MODE:-<none>}"
echo "默认操作： inspect only（Default action: inspect only）"
echo "信息：Changing permissions can expose or block access to files and services."
echo

echo "信息：== Current permissions =="
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
  echo "信息：No TARGET_MODE provided. Inspection complete; no permission changes were performed."
  exit 0
fi

if [[ ! "${TARGET_MODE}" =~ ^[0-7]{3,4}$ ]]; then
  echo "信息：TARGET_MODE must be an octal mode such as 0644 or 0750." >&2
  exit 2
fi

echo "信息：Planned change: chmod ${TARGET_MODE} ${TARGET_PATH}"
if [[ "${CONFIRM_CHMOD}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：Plan only. No permission changes were performed."
  echo "信息：To apply, rerun with CONFIRM_CHMOD=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：Confirmation token accepted. Applying chmod."
chmod "${TARGET_MODE}" "${TARGET_PATH}"
ls -ld "${TARGET_PATH}"
