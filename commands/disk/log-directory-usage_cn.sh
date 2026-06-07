#!/usr/bin/env bash
set -euo pipefail

echo "信息：== common log directory usage =="
for dir in /var/log /Library/Logs "$HOME/Library/Logs"; do
  if [ -d "$dir" ]; then
    echo "信息：-- $dir --"
    du -sh "$dir" 2>/dev/null || true
    du -xh -d 1 "$dir" 2>/dev/null | sort -hr | head -20 || true
    echo
  fi
done
