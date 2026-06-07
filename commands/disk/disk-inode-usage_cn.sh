#!/usr/bin/env bash
set -euo pipefail

echo "信息：== inode 使用率 =="
df -ih

echo
echo "信息：== inode 使用率 POSIX 格式 =="
df -Pi 2>/dev/null || true
