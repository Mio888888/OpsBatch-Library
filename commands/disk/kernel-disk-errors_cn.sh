#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== 近期内核磁盘和文件系统错误 =="
  dmesg -T 2>/dev/null | grep -Ei 'I/O error|blk_update_request|buffer error|EXT4-fs error|XFS.*error|BTRFS.*error|nvme.*error|ata[0-9].*error|reset|failed command' | tail -120 || true

  if command -v journalctl >/dev/null 2>&1; then
    echo
    echo "信息：== 今天以来 journal 内核磁盘错误 =="
    journalctl -k --since today --no-pager 2>/dev/null | grep -Ei 'I/O error|EXT4-fs error|XFS.*error|BTRFS.*error|nvme.*error|ata[0-9].*error' | tail -120 || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'eventMessage CONTAINS[c] "I/O error" OR eventMessage CONTAINS[c] "disk" OR eventMessage CONTAINS[c] "filesystem"' 2>/dev/null | tail -120 || true
else
  echo "未找到受支持的 内核日志命令。"
fi
