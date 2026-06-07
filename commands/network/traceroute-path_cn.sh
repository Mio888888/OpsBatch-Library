#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
MAX_HOPS="${MAX_HOPS:-20}"

echo "信息：正在跟踪到 $TARGET_HOST 的路径，最大跳数 $MAX_HOPS"

if command -v traceroute >/dev/null 2>&1; then
  traceroute -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v tracepath >/dev/null 2>&1; then
  tracepath -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v ping >/dev/null 2>&1; then
  echo "未找到 traceroute/tracepath；改为显示 ping 延迟。"
  ping -c 4 "$TARGET_HOST"
else
  echo "信息：未找到 traceroute、tracepath 或 ping 命令。"
fi
