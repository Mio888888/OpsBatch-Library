#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
PACKET_SIZE="${PACKET_SIZE:-1472}"

echo "信息：== 目标 =="
echo "信息：TARGET_HOST=$TARGET_HOST"
echo "信息：PACKET_SIZE=$PACKET_SIZE"

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "信息：== ping 禁止分片探测 =="
  ping -c 4 -M do -s "$PACKET_SIZE" "$TARGET_HOST" 2>/dev/null || echo "信息：路径 MTU 探测失败、ICMP 被阻止或包大小过大。"

  if command -v tracepath >/dev/null 2>&1; then
    echo
    echo "信息：== tracepath MTU hints =="
    tracepath "$TARGET_HOST" 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== ping 禁止分片探测 =="
  ping -c 4 -D -s "$PACKET_SIZE" "$TARGET_HOST" 2>/dev/null || echo "信息：路径 MTU 探测失败、ICMP 被阻止或包大小过大。"
else
  echo "未找到受支持的 MTU 探测命令。"
fi
