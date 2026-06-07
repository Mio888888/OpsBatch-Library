#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${SCAN_ROOT:-/etc/ssh}"
LIMIT="${LIMIT:-100}"

echo "Scanning key-like file metadata under $SCAN_ROOT. This command prints metadata only, not key contents."
if [ ! -d "$SCAN_ROOT" ]; then
  echo "Directory not found: $SCAN_ROOT"
  exit 0
fi

echo
echo "== private key candidate metadata =="
find "$SCAN_ROOT" -xdev -type f \( -name '*_key' -o -name '*.key' -o -name 'id_rsa' -o -name 'id_ed25519' -o -name 'id_ecdsa' \) -exec ls -l {} + 2>/dev/null | head -n "$LIMIT"

echo
echo "== files with broad read permissions =="
find "$SCAN_ROOT" -xdev -type f \( -name '*_key' -o -name '*.key' -o -name 'id_rsa' -o -name 'id_ed25519' -o -name 'id_ecdsa' \) \( -perm -004 -o -perm -040 \) -print 2>/dev/null | head -n "$LIMIT"
