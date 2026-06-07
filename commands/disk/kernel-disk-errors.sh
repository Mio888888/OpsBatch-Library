#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== recent kernel disk and filesystem errors =="
  dmesg -T 2>/dev/null | grep -Ei 'I/O error|blk_update_request|buffer error|EXT4-fs error|XFS.*error|BTRFS.*error|nvme.*error|ata[0-9].*error|reset|failed command' | tail -120 || true

  if command -v journalctl >/dev/null 2>&1; then
    echo
    echo "== journal kernel disk errors since today =="
    journalctl -k --since today --no-pager 2>/dev/null | grep -Ei 'I/O error|EXT4-fs error|XFS.*error|BTRFS.*error|nvme.*error|ata[0-9].*error' | tail -120 || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'eventMessage CONTAINS[c] "I/O error" OR eventMessage CONTAINS[c] "disk" OR eventMessage CONTAINS[c] "filesystem"' 2>/dev/null | tail -120 || true
else
  echo "No supported kernel log command found."
fi
