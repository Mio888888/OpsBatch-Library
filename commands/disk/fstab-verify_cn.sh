#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== /etc/fstab 条目 =="
  grep -Ev '^\s*(#|$)' /etc/fstab 2>/dev/null || true

  echo
  echo "信息：== findmnt 验证 =="
  if command -v findmnt >/dev/null 2>&1; then
    findmnt --verify --verbose 2>/dev/null || true
  else
    echo "信息：未安装 findmnt；无法验证 fstab。"
  fi
else
  echo "信息：此命令中的 fstab 验证仅适用于 Linux。macOS 使用不同的挂载配置机制。"
fi
