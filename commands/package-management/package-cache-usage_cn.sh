#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package manager cache usage =="
if command -v apt-get >/dev/null 2>&1; then
  du -sh /var/cache/apt /var/lib/apt/lists 2>/dev/null || true
fi
if command -v dnf >/dev/null 2>&1; then
  du -sh /var/cache/dnf 2>/dev/null || true
fi
if command -v yum >/dev/null 2>&1; then
  du -sh /var/cache/yum 2>/dev/null || true
fi
if command -v pacman >/dev/null 2>&1; then
  du -sh /var/cache/pacman/pkg 2>/dev/null || true
fi
if command -v brew >/dev/null 2>&1; then
  brew --cache 2>/dev/null | while read -r cache_dir; do du -sh "$cache_dir" 2>/dev/null; done
fi
