#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_GROUP="${TARGET_GROUP:-}"
GROUP_ACTION="${GROUP_ACTION:-add}"
CONFIRM_GROUP_CHANGE="${CONFIRM_GROUP_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_GROUP" ]; then
  echo "Refusing to run: set TARGET_USER and TARGET_GROUP explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "Refusing to run: user not found: $TARGET_USER"
  exit 0
fi

case "$GROUP_ACTION" in
  add|remove) ;;
  *) echo "Refusing to run: GROUP_ACTION must be add or remove."; exit 0 ;;
esac

echo "== planned group membership change =="
echo "TARGET_USER=$TARGET_USER"
echo "TARGET_GROUP=$TARGET_GROUP"
echo "GROUP_ACTION=$GROUP_ACTION"
echo "Current groups: $(id -Gn "$TARGET_USER" 2>/dev/null || true)"

if [ "$CONFIRM_GROUP_CHANGE" != "CHANGE_GROUP_MEMBERSHIP" ]; then
  echo "Dry-run only. Set CONFIRM_GROUP_CHANGE=CHANGE_GROUP_MEMBERSHIP after confirming access impact and approval."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo usermod -aG "$TARGET_GROUP" "$TARGET_USER"
  else
    if command -v gpasswd >/dev/null 2>&1; then
      sudo gpasswd -d "$TARGET_USER" "$TARGET_GROUP"
    else
      echo "gpasswd is required to remove a user from a group on this Linux system."
    fi
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v dseditgroup >/dev/null 2>&1; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo dseditgroup -o edit -a "$TARGET_USER" -t user "$TARGET_GROUP"
  else
    sudo dseditgroup -o edit -d "$TARGET_USER" -t user "$TARGET_GROUP"
  fi
else
  echo "No supported group membership tool found."
fi
