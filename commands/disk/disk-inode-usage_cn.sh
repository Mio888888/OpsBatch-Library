#!/usr/bin/env bash
set -euo pipefail

echo "信息：== inode usage =="
df -ih

echo
echo "信息：== inode usage POSIX format =="
df -Pi 2>/dev/null || true
