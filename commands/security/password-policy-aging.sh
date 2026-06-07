#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -n "$TARGET_USER" ]; then
    echo "== password aging for $TARGET_USER =="
    if command -v chage >/dev/null 2>&1; then
      sudo chage -l "$TARGET_USER" 2>/dev/null || chage -l "$TARGET_USER" 2>/dev/null || echo "Cannot read password aging for $TARGET_USER."
    else
      echo "chage is not available."
    fi
  else
    echo "== password policy files =="
    for file in /etc/login.defs /etc/security/faillock.conf /etc/pam.d/common-password /etc/pam.d/system-auth; do
      if [ -r "$file" ]; then
        echo "-- $file --"
        grep -Ev '^[[:space:]]*(#|$)' "$file" 2>/dev/null | head -80 || true
      fi
    done
    echo
    echo "Set TARGET_USER to inspect one user's password aging with chage."
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  pwpolicy getaccountpolicies 2>/dev/null || echo "Cannot read macOS password policies."
else
  echo "No supported password policy source found."
fi
