#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_SHELL="${TARGET_SHELL:-}"
CONFIRM_SHELL_CHANGE="${CONFIRM_SHELL_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_SHELL" ]; then
  echo "Refusing to run: set TARGET_USER and TARGET_SHELL explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "Refusing to run: user not found: $TARGET_USER"
  exit 0
fi

if [ -f /etc/shells ] && ! grep -qx "$TARGET_SHELL" /etc/shells; then
  echo "Warning: TARGET_SHELL is not listed in /etc/shells: $TARGET_SHELL"
fi

echo "== planned shell change =="
echo "TARGET_USER=$TARGET_USER"
echo "TARGET_SHELL=$TARGET_SHELL"
echo "Current passwd entry:"
if command -v getent >/dev/null 2>&1; then
  getent passwd "$TARGET_USER" 2>/dev/null || true
elif [ -r /etc/passwd ]; then
  awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
fi

if [ "$CONFIRM_SHELL_CHANGE" != "CHANGE_TARGET_SHELL" ]; then
  echo "Dry-run only. Set CONFIRM_SHELL_CHANGE=CHANGE_TARGET_SHELL after confirming login/service impact."
  exit 0
fi

if command -v chsh >/dev/null 2>&1; then
  sudo chsh -s "$TARGET_SHELL" "$TARGET_USER"
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  sudo dscl . -create "/Users/$TARGET_USER" UserShell "$TARGET_SHELL"
else
  echo "No supported shell change tool found."
fi
