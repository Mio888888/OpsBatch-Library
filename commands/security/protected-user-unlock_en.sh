#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_UNLOCK_USER="${CONFIRM_UNLOCK_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "Refusing to run: set TARGET_USER explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "Refusing to run: user not found: $TARGET_USER"
  exit 0
fi

echo "== planned account unlock =="
id "$TARGET_USER" 2>/dev/null || true

if [ "$CONFIRM_UNLOCK_USER" != "UNLOCK_TARGET_USER" ]; then
  echo "Dry-run only. Set CONFIRM_UNLOCK_USER=UNLOCK_TARGET_USER after confirming approval and password/key state."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  sudo passwd -u "$TARGET_USER"
  if command -v faillock >/dev/null 2>&1; then
    sudo faillock --user "$TARGET_USER" --reset 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  sudo pwpolicy -u "$TARGET_USER" -setpolicy isDisabled=0
else
  echo "No supported account unlock tool found."
fi
