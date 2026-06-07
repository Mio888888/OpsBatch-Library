#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${TARGET_PATH:-}"
TARGET_MODE="${TARGET_MODE:-}"
CONFIRM_CHMOD="${CONFIRM_CHMOD:-}"

if [ -z "$TARGET_PATH" ] || [ -z "$TARGET_MODE" ]; then
  echo "Refusing to run: set TARGET_PATH and TARGET_MODE explicitly, for example TARGET_PATH=/etc/ssh/sshd_config TARGET_MODE=600."
  exit 0
fi

if [ ! -e "$TARGET_PATH" ]; then
  echo "Refusing to run: target does not exist: $TARGET_PATH"
  exit 0
fi

echo "== planned chmod =="
ls -ld "$TARGET_PATH" 2>/dev/null || true
printf 'Would run: chmod %s %s\n' "$TARGET_MODE" "$TARGET_PATH"

case "$TARGET_MODE" in
  *[!0-7]*|'')
    echo "Refusing to run: TARGET_MODE must be an octal mode such as 600 or 750."
    exit 0
    ;;
esac

if [ "$CONFIRM_CHMOD" != "APPLY_TARGET_MODE" ]; then
  echo "Dry-run only. Set CONFIRM_CHMOD=APPLY_TARGET_MODE after confirming ownership, service impact and rollback path."
  exit 0
fi

sudo chmod "$TARGET_MODE" "$TARGET_PATH"
ls -ld "$TARGET_PATH" 2>/dev/null || true
