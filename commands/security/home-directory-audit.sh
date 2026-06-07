#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ -r /etc/passwd ]; then
  if [ -n "$TARGET_USER" ]; then
    awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
  else
    awk -F: '$6 != "" {print}' /etc/passwd
  fi | while IFS=: read -r user _ uid gid gecos home shell; do
    [ -z "$user" ] && continue
    printf '%s uid=%s home=%s shell=%s\n' "$user" "$uid" "$home" "$shell"
    if [ -d "$home" ]; then
      ls -ld "$home" 2>/dev/null || true
      owner="$(ls -ldn "$home" 2>/dev/null | awk '{print $3":"$4}')"
      if [ "$owner" != "$uid:$gid" ]; then
        echo "  warning: home owner numeric uid/gid is $owner, expected $uid:$gid"
      fi
    else
      echo "  warning: home directory missing or not a directory"
    fi
    echo
  done
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  users="${TARGET_USER:-$(dscl . -list /Users 2>/dev/null)}"
  for user in $users; do
    home="$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
    shell="$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}')"
    printf '%s home=%s shell=%s\n' "$user" "$home" "$shell"
    [ -n "$home" ] && ls -ld "$home" 2>/dev/null || echo "  warning: home directory missing or not readable"
    echo
  done
else
  echo "No supported user home source found."
fi
