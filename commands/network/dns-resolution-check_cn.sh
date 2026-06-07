#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"

echo "信息：== DNS target =="
echo "信息：$TARGET_HOST"

if command -v dig >/dev/null 2>&1; then
  echo
  echo "信息：== dig A/AAAA =="
  dig +short A "$TARGET_HOST" || true
  dig +short AAAA "$TARGET_HOST" || true

  echo
  echo "信息：== resolver trace summary =="
  dig "$TARGET_HOST" +stats +noall +answer +comments 2>/dev/null || true
elif command -v nslookup >/dev/null 2>&1; then
  nslookup "$TARGET_HOST"
elif command -v host >/dev/null 2>&1; then
  host "$TARGET_HOST"
elif command -v getent >/dev/null 2>&1; then
  getent hosts "$TARGET_HOST"
else
  echo "信息：No DNS lookup tool found; install dig, nslookup, host, or use getent on Linux."
fi
