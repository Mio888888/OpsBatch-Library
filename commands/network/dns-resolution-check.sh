#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"

echo "== DNS target =="
echo "$TARGET_HOST"

if command -v dig >/dev/null 2>&1; then
  echo
  echo "== dig A/AAAA =="
  dig +short A "$TARGET_HOST" || true
  dig +short AAAA "$TARGET_HOST" || true

  echo
  echo "== resolver trace summary =="
  dig "$TARGET_HOST" +stats +noall +answer +comments 2>/dev/null || true
elif command -v nslookup >/dev/null 2>&1; then
  nslookup "$TARGET_HOST"
elif command -v host >/dev/null 2>&1; then
  host "$TARGET_HOST"
elif command -v getent >/dev/null 2>&1; then
  getent hosts "$TARGET_HOST"
else
  echo "No DNS lookup tool found; install dig, nslookup, host, or use getent on Linux."
fi
