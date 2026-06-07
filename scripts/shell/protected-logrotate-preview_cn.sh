#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_CONFIG="${1:-${LOGROTATE_CONFIG:-}}"
CONFIRM_ROTATE="${2:-${CONFIRM_ROTATE:-}}"
CONFIRM_TOKEN="RUN_LOGROTATE"

if [[ -z "${LOGROTATE_CONFIG}" ]]; then
  echo "请设置 LOGROTATE_CONFIG or pass a logrotate config path.（Set LOGROTATE_CONFIG or pass a logrotate config path.）"
  echo "信息：No rotation was performed."
  exit 0
fi

if [[ ! -f "${LOGROTATE_CONFIG}" ]]; then
  echo "Logrotate config 未找到: ${LOGROTATE_CONFIG}（Logrotate config not found: ${LOGROTATE_CONFIG}）" >&2
  exit 1
fi

if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command 不可用 on this host.（logrotate command not available on this host.）" >&2
  exit 1
fi

echo "受保护 logrotate maintenance plan（Protected logrotate maintenance plan）"
echo "信息：Config: ${LOGROTATE_CONFIG}"
echo "默认操作： debug/dry-run only（Default action: debug/dry-run only）"
echo "信息：Real rotation can move, compress, truncate, delete logs, and run postrotate hooks."
echo

echo "信息：== logrotate debug output =="
logrotate -d "${LOGROTATE_CONFIG}"
echo

if [[ "${CONFIRM_ROTATE}" != "${CONFIRM_TOKEN}" ]]; then
  echo "仅试运行。 No log rotation was performed.（Dry-run only. No log rotation was performed.）"
  echo "信息：To run real rotation, rerun with CONFIRM_ROTATE=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：Confirmation token accepted. Running logrotate with verbose output."
logrotate -v "${LOGROTATE_CONFIG}"
