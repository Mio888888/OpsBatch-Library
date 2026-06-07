#!/usr/bin/env bash
set -euo pipefail

NEW_USER="${NEW_USER:-}"
NEW_USER_COMMENT="${NEW_USER_COMMENT:-OpsBatch managed user}"
NEW_USER_SHELL="${NEW_USER_SHELL:-/bin/bash}"
NEW_USER_HOME="${NEW_USER_HOME:-}"
CONFIRM_CREATE_USER="${CONFIRM_CREATE_USER:-}"

if [ -z "$NEW_USER" ]; then
  echo "Refusing to run: set NEW_USER explicitly."
  exit 0
fi

case "$NEW_USER" in
  *[!a-zA-Z0-9._-]*|'')
    echo "Refusing to run: NEW_USER contains unsupported characters."
    exit 0
    ;;
esac

echo "== planned local user creation =="
echo "NEW_USER=$NEW_USER"
echo "NEW_USER_COMMENT=$NEW_USER_COMMENT"
echo "NEW_USER_SHELL=$NEW_USER_SHELL"
echo "NEW_USER_HOME=${NEW_USER_HOME:-default}"

if id "$NEW_USER" >/dev/null 2>&1; then
  echo "Refusing to run: user already exists: $NEW_USER"
  exit 0
fi

if [ "$CONFIRM_CREATE_USER" != "CREATE_LOCAL_USER" ]; then
  echo "Dry-run only. Set CONFIRM_CREATE_USER=CREATE_LOCAL_USER after reviewing username, shell, home and password bootstrap plan."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ -n "$NEW_USER_HOME" ]; then
    sudo useradd -m -d "$NEW_USER_HOME" -s "$NEW_USER_SHELL" -c "$NEW_USER_COMMENT" "$NEW_USER"
  else
    sudo useradd -m -s "$NEW_USER_SHELL" -c "$NEW_USER_COMMENT" "$NEW_USER"
  fi
  echo "User created. Set an initial password or key through your approved secret process."
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  uid="${NEW_USER_UID:-}"
  if [ -z "$uid" ]; then
    uid="$(dscl . -list /Users UniqueID 2>/dev/null | awk '{print $2}' | sort -n | tail -1 | awk '{print $1 + 1}')"
  fi
  home="${NEW_USER_HOME:-/Users/$NEW_USER}"
  sudo dscl . -create "/Users/$NEW_USER"
  sudo dscl . -create "/Users/$NEW_USER" UserShell "$NEW_USER_SHELL"
  sudo dscl . -create "/Users/$NEW_USER" RealName "$NEW_USER_COMMENT"
  sudo dscl . -create "/Users/$NEW_USER" UniqueID "$uid"
  sudo dscl . -create "/Users/$NEW_USER" PrimaryGroupID "20"
  sudo dscl . -create "/Users/$NEW_USER" NFSHomeDirectory "$home"
  sudo createhomedir -c -u "$NEW_USER" >/dev/null 2>&1 || true
  echo "User created. Set an initial password or key through your approved secret process."
else
  echo "No supported local user creation tool found."
fi
