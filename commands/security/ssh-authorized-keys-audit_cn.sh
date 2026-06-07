#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
MAX_KEYS="${MAX_KEYS:-20}"

list_users() {
  if [ -n "$TARGET_USER" ]; then
    printf '%s\n' "$TARGET_USER"
  elif [ -r /etc/passwd ]; then
    awk -F: '$6 != "" && $7 !~ /(false|nologin|sync|shutdown|halt)$/ {print $1}' /etc/passwd
  elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
    dscl . -list /Users 2>/dev/null | grep -v '^_'
  fi
}

for user in $(list_users); do
  if [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
    home="$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
  elif command -v getent >/dev/null 2>&1; then
    home="$(getent passwd "$user" 2>/dev/null | awk -F: '{print $6}')"
  elif [ -r /etc/passwd ]; then
    home="$(awk -F: -v user="$user" '$1 == user {print $6}' /etc/passwd)"
  fi

  auth_file="$home/.ssh/authorized_keys"
  echo "信息：== $user ($auth_file) =="
  if [ -f "$auth_file" ]; then
    ls -ld "$home" "$home/.ssh" "$auth_file" 2>/dev/null || true
    echo "信息：key_count=$(grep -Ev '^[[:space:]]*(#|$)' "$auth_file" 2>/dev/null | wc -l | tr -d ' ')"
    grep -Ev '^[[:space:]]*(#|$)' "$auth_file" 2>/dev/null | head -n "$MAX_KEYS" | awk '{print NR ": " $1 " " $2 " " $3}'
  else
    echo "authorized_keys 未找到 or not readable.（authorized_keys not found or not readable.）"
  fi
  echo
done
