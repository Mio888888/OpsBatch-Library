#!/usr/bin/env bash
set -euo pipefail

if [ -n "${LOGROTATE_CONFIG:-}" ]; then
  LOGROTATE_CONFIG_WAS_SET="true"
else
  LOGROTATE_CONFIG_WAS_SET="false"
fi
LOGROTATE_CONFIG="${LOGROTATE_CONFIG:-/etc/logrotate.conf}"
LOGROTATE_STATE="${LOGROTATE_STATE:-}"
CONFIRM_ROTATE="${CONFIRM_ROTATE:-}"

if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command 未找到."
  exit 0
fi

if [ ! -f "$LOGROTATE_CONFIG" ]; then
  echo "信息：LOGROTATE_CONFIG is not a file: $LOGROTATE_CONFIG"
  exit 0
fi

echo "信息：== logrotate dry-run =="
if [ -n "$LOGROTATE_STATE" ]; then
  logrotate -d -s "$LOGROTATE_STATE" "$LOGROTATE_CONFIG" 2>&1 | tail -n 200 || true
else
  logrotate -d "$LOGROTATE_CONFIG" 2>&1 | tail -n 200 || true
fi

if [ "$CONFIRM_ROTATE" != "RUN_LOGROTATE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_ROTATE=RUN_LOGROTATE 并显式设置 LOGROTATE_CONFIG，以便在复核试运行输出和维护窗口后执行 logrotate。"
  exit 0
fi

if [ "$LOGROTATE_CONFIG_WAS_SET" != "true" ]; then
  echo
  echo "信息：拒绝真实运行：请同时显式设置 LOGROTATE_CONFIG 和 CONFIRM_ROTATE=RUN_LOGROTATE。"
  exit 0
fi

echo
echo "信息：正在使用配置 $LOGROTATE_CONFIG 执行 logrotate。"
if [ -n "$LOGROTATE_STATE" ]; then
  logrotate -v -s "$LOGROTATE_STATE" "$LOGROTATE_CONFIG"
else
  logrotate -v "$LOGROTATE_CONFIG"
fi
