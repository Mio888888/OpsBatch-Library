#!/usr/bin/env bash
set -euo pipefail

FILE_LIST="${FILE_LIST:-/etc/passwd /etc/group /etc/hosts /etc/sudoers /etc/ssh/sshd_config}"

echo "== file metadata and hashes =="
for path in $FILE_LIST; do
  if [ -e "$path" ]; then
    echo "-- $path --"
    ls -ld "$path" 2>/dev/null || true
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$path" 2>/dev/null || true
    elif command -v shasum >/dev/null 2>&1; then
      shasum -a 256 "$path" 2>/dev/null || true
    else
      echo "No sha256 tool found."
    fi
  else
    echo "missing: $path"
  fi
done

echo
echo "Set FILE_LIST to a space-separated allowlist of files to baseline. Do not include private keys unless output handling is approved."
