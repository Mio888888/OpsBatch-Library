#!/usr/bin/env bash
set -euo pipefail

echo "信息：== local user account summary =="
if [ -r /etc/passwd ]; then
  awk -F: '{printf "%-24s uid=%-6s gid=%-6s home=%-32s shell=%s\n", $1, $3, $4, $6, $7}' /etc/passwd | sort -k2,2n
  echo
  echo "信息：Total local passwd entries: $(wc -l < /etc/passwd | tr -d ' ')"
  echo "信息：Interactive-shell users:"
  awk -F: '$7 !~ /(false|nologin|sync|shutdown|halt)$/ {print $1 " " $6 " " $7}' /etc/passwd | sort
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  dscl . -list /Users UniqueID 2>/dev/null | sort -k2,2n || echo "信息：无法使用 dscl 查询本地用户。"
else
  echo "未找到受支持的 本地用户数据库。"
fi
