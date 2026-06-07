#!/usr/bin/env bash
set -euo pipefail

echo "信息：== UID 0 accounts =="
if [ -r /etc/passwd ]; then
  awk -F: '$3 == 0 {print}' /etc/passwd

  echo
  echo "信息：== duplicate UIDs =="
  awk -F: '{count[$3]++; users[$3]=users[$3] " " $1} END {for (uid in count) if (count[uid] > 1) print "uid=" uid " users=" users[uid]}' /etc/passwd | sort -n

  echo
  echo "信息：== high-risk interactive system accounts (uid < 1000 with login shell) =="
  awk -F: '$3 < 1000 && $7 !~ /(false|nologin|sync|shutdown|halt)$/ {print}' /etc/passwd | sort -t: -k3,3n

  echo
  echo "信息：== users with missing primary group =="
  while IFS=: read -r user _ uid gid _ _ _; do
    if ! awk -F: -v gid="$gid" '$3 == gid {found=1} END {exit found ? 0 : 1}' /etc/group 2>/dev/null; then
      echo "信息：$user uid=$uid gid=$gid has no matching primary group"
    fi
  done < /etc/passwd
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  echo "信息：== UID 0 users =="
  dscl . -list /Users UniqueID 2>/dev/null | awk '$2 == 0 {print}'
  echo
  echo "信息：== duplicate UIDs =="
  dscl . -list /Users UniqueID 2>/dev/null | awk '{count[$2]++; users[$2]=users[$2] " " $1} END {for (uid in count) if (count[uid] > 1) print "uid=" uid " users=" users[uid]}' | sort -n
else
  echo "未找到受支持的 user database found.（No supported user database found.）"
fi
