#!/usr/bin/env bash
set -euo pipefail

echo "== inode usage =="
df -ih

echo
echo "== inode usage POSIX format =="
df -Pi 2>/dev/null || true
