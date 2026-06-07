#!/usr/bin/env bash
set -euo pipefail

echo "信息：== filesystem usage =="
df -h

echo
echo "信息：== filesystem usage by inode-aware POSIX format =="
df -P 2>/dev/null || true
