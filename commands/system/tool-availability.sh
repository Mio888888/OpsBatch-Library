#!/usr/bin/env bash
set -euo pipefail

for tool in bash sh zsh python3 python perl awk sed grep curl wget git ssh scp rsync tar gzip; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-10s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '%-10s %s\n' "$tool" "not found"
  fi
done
