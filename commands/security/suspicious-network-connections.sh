#!/usr/bin/env bash
set -euo pipefail

TOP_LIMIT="${TOP_LIMIT:-30}"

echo "== established remote connection counts =="
if command -v ss >/dev/null 2>&1; then
  ss -tunp state established 2>/dev/null | awk 'NR>1 {print $5}' | sed 's/^\[//; s/\]$//; s/:[^:]*$//' | sort | uniq -c | sort -nr | head -n "$TOP_LIMIT"
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/ESTABLISHED/ {print $5}' | sed 's/^\[//; s/\]$//; s/\.[0-9][0-9]*$//' | sort | uniq -c | sort -nr | head -n "$TOP_LIMIT"
else
  echo "No supported connection listing tool found."
fi

echo
echo "== connections on uncommon high-risk service ports =="
if command -v ss >/dev/null 2>&1; then
  ss -tunp 2>/dev/null | grep -E ':(22|23|3389|5900|6379|9200|9300|11211|27017|3306|5432)[[:space:]]' | head -80 || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -i 2>/dev/null | grep -E ':(22|23|3389|5900|6379|9200|9300|11211|27017|3306|5432)' | head -80 || true
fi

echo
echo "Review only: high counts or sensitive service ports are investigation leads, not proof of compromise."
