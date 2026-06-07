#!/usr/bin/env bash
set -euo pipefail

echo "== listening TCP/UDP sockets =="
if command -v ss >/dev/null 2>&1; then
  ss -tulpen 2>/dev/null | head -120 || ss -tulpn 2>/dev/null | head -120 || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | head -120 || true
  lsof -nP -iUDP 2>/dev/null | head -80 || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -anv 2>/dev/null | grep -Ei 'listen|udp' | head -120 || true
else
  echo "No supported socket listing tool found."
fi

echo
echo "== route and interface context =="
if command -v ip >/dev/null 2>&1; then
  ip -brief addr 2>/dev/null || true
  ip route show 2>/dev/null | head -60 || true
elif command -v ifconfig >/dev/null 2>&1; then
  ifconfig 2>/dev/null | head -120 || true
  netstat -rn 2>/dev/null | head -60 || true
fi
