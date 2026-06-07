#!/usr/bin/env bash
set -euo pipefail

echo "== local user account summary =="
if [ -r /etc/passwd ]; then
  awk -F: '{printf "%-24s uid=%-6s gid=%-6s home=%-32s shell=%s\n", $1, $3, $4, $6, $7}' /etc/passwd | sort -k2,2n
  echo
  echo "Total local passwd entries: $(wc -l < /etc/passwd | tr -d ' ')"
  echo "Interactive-shell users:"
  awk -F: '$7 !~ /(false|nologin|sync|shutdown|halt)$/ {print $1 " " $6 " " $7}' /etc/passwd | sort
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  dscl . -list /Users UniqueID 2>/dev/null | sort -k2,2n || echo "Cannot query local users with dscl."
else
  echo "No supported local user database found."
fi
