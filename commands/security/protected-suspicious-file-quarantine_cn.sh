#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE="${TARGET_FILE:-}"
QUARANTINE_DIR="${QUARANTINE_DIR:-}"
CONFIRM_QUARANTINE="${CONFIRM_QUARANTINE:-}"

if [ -z "$TARGET_FILE" ] || [ -z "$QUARANTINE_DIR" ]; then
  echo "拒绝执行： set TARGET_FILE and QUARANTINE_DIR explicitly."
  exit 0
fi

if [ ! -f "$TARGET_FILE" ]; then
  echo "拒绝执行： TARGET_FILE 必须存在且为普通文件: $TARGET_FILE"
  exit 0
fi

echo "信息：== 计划文件隔离 =="
ls -l "$TARGET_FILE" 2>/dev/null || true
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$TARGET_FILE" 2>/dev/null || true
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$TARGET_FILE" 2>/dev/null || true
fi
printf '将移动到隔离目录: %s\n' "$QUARANTINE_DIR"

if [ "$CONFIRM_QUARANTINE" != "MOVE_TARGET_FILE" ]; then
  echo "仅试运行。 请设置 CONFIRM_QUARANTINE=MOVE_TARGET_FILE 在确认后 该文件不是运行中服务所需且证据采集已完成后。"
  exit 0
fi

sudo mkdir -p "$QUARANTINE_DIR"
sudo chmod 700 "$QUARANTINE_DIR"
target_name="$(basename "$TARGET_FILE")"
sudo mv -i "$TARGET_FILE" "$QUARANTINE_DIR/$target_name.$(date +%Y%m%d%H%M%S)"
echo "信息：已将可疑文件移动到 $QUARANTINE_DIR。"
