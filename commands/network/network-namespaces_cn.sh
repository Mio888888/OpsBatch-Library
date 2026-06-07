#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== process network namespaces =="
  if command -v lsns >/dev/null 2>&1; then
    lsns -t net
  else
    echo "信息：未安装 lsns；显示首批进程的命名空间符号链接。"
    find /proc/[0-9]*/ns/net -maxdepth 0 -type l -print 2>/dev/null | head -40 | while read -r ns; do
      printf '%s -> ' "$ns"
      readlink "$ns" 2>/dev/null || true
    done
  fi

  if command -v ip >/dev/null 2>&1; then
    echo
    echo "信息：== 已命名网络命名空间 =="
    ip netns list 2>/dev/null || true
  fi
else
  echo "信息：网络命名空间是 Linux 专属能力；此处不显示 macOS 等价信息。"
fi
