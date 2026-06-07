#!/usr/bin/env bash
set -euo pipefail

echo "== filesystem usage =="
df -h

echo
echo "== filesystem usage by inode-aware POSIX format =="
df -P 2>/dev/null || true
