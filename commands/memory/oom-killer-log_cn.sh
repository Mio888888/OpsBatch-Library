#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pattern='out of memory|oom-killer|oom_kill|killed process|memory allocation failure'

  if command -v journalctl >/dev/null 2>&1; then
    echo "信息：== journalctl -k OOM entries =="
    journalctl -k --no-pager -n 2000 2>/dev/null | grep -Ei "$pattern" || echo "信息：最近的内核 journal 中未找到 OOM 记录。"
  else
    echo "信息：未安装 journalctl。"
  fi

  echo
  echo "信息：== dmesg OOM entries =="
  if command -v dmesg >/dev/null 2>&1; then
    dmesg -T 2>/dev/null | grep -Ei "$pattern" || dmesg 2>/dev/null | grep -Ei "$pattern" || echo "信息：dmesg 中未发现 OOM 条目，或 dmesg 受限。"
  else
    echo "信息：未安装 dmesg 命令。"
  fi
else
  echo "信息：此命令中的 OOM Killer 日志检查依赖 Linux 内核日志。"
fi
