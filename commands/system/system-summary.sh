#!/usr/bin/env bash
set -euo pipefail

echo "=== Identity ==="
hostname 2>/dev/null || true
whoami 2>/dev/null || true
echo "=== Kernel ==="
uname -a
echo "=== Uptime ==="
uptime
echo "=== CPU count ==="
if command -v nproc >/dev/null 2>&1; then
  nproc
elif command -v sysctl >/dev/null 2>&1; then
  sysctl -n hw.ncpu 2>/dev/null || true
fi
echo "=== Memory ==="
if command -v free >/dev/null 2>&1; then
  free -h
elif command -v vm_stat >/dev/null 2>&1; then
  vm_stat | head -20
fi
echo "=== Disk ==="
df -h | head -20
