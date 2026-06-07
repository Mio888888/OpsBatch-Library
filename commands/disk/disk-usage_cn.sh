#!/usr/bin/env bash
set -euo pipefail

echo "信息：== 文件系统使用率 =="
df -h

echo
echo "信息：== 文件系统使用率 by inode-aware POSIX format =="
df -P 2>/dev/null || true
