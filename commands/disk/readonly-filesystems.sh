#!/usr/bin/env bash
set -euo pipefail

echo "== read-only mounted filesystems =="
if [ "$(uname -s)" = "Linux" ] && command -v findmnt >/dev/null 2>&1; then
  findmnt -A -o TARGET,SOURCE,FSTYPE,OPTIONS | awk 'NR==1 || $0 ~ /(^|,)ro(,|$)/'
else
  mount | grep -E '\(([^)]*,)?read-only|\bro[,)]' || true
fi

echo
echo "== recent readonly / remount related kernel messages =="
if [ "$(uname -s)" = "Linux" ]; then
  dmesg -T 2>/dev/null | grep -Ei 'read-only|readonly|remount|EXT4-fs error|XFS.*error|I/O error' | tail -80 || true
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 2h --style compact --predicate 'eventMessage CONTAINS[c] "read-only" OR eventMessage CONTAINS[c] "I/O error"' 2>/dev/null | tail -80 || true
fi
