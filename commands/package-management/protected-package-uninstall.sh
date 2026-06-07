#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_PACKAGE="${TARGET_PACKAGE:-}"
CONFIRM_UNINSTALL="${CONFIRM_UNINSTALL:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "Refusing to run: set TARGET_PACKAGE explicitly, for example TARGET_PACKAGE=unused-package."
  exit 0
fi

if [ "$PACKAGE_MANAGER" = "auto" ]; then
  if command -v apt-get >/dev/null 2>&1; then PACKAGE_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1; then PACKAGE_MANAGER="dnf"
  elif command -v yum >/dev/null 2>&1; then PACKAGE_MANAGER="yum"
  elif command -v pacman >/dev/null 2>&1; then PACKAGE_MANAGER="pacman"
  elif command -v apk >/dev/null 2>&1; then PACKAGE_MANAGER="apk"
  elif command -v zypper >/dev/null 2>&1; then PACKAGE_MANAGER="zypper"
  elif command -v brew >/dev/null 2>&1; then PACKAGE_MANAGER="brew"
  else PACKAGE_MANAGER="unsupported"; fi
fi

echo "== protected package uninstall plan =="
echo "PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "TARGET_PACKAGE=$TARGET_PACKAGE"

case "$PACKAGE_MANAGER" in
  apt) apt-get -s remove "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  dnf) dnf remove --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  yum) yum remove --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  pacman) echo "pacman remove would run: sudo pacman -R $TARGET_PACKAGE"; pacman -Qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true ;;
  apk) apk del -s "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  zypper) zypper --non-interactive remove --dry-run "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  brew) brew uses --installed "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true; brew info "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true ;;
  *) echo "Unsupported package manager. Set PACKAGE_MANAGER explicitly after review." ;;
esac

if [ "$CONFIRM_UNINSTALL" != "UNINSTALL_PACKAGE" ]; then
  echo
  echo "Dry-run only. Set CONFIRM_UNINSTALL=UNINSTALL_PACKAGE after reviewing reverse dependencies, service impact, backups, and rollback plan."
  exit 0
fi

case "$PACKAGE_MANAGER" in
  apt) sudo apt-get remove "$TARGET_PACKAGE" ;;
  dnf) sudo dnf remove "$TARGET_PACKAGE" ;;
  yum) sudo yum remove "$TARGET_PACKAGE" ;;
  pacman) sudo pacman -R "$TARGET_PACKAGE" ;;
  apk) sudo apk del "$TARGET_PACKAGE" ;;
  zypper) sudo zypper remove "$TARGET_PACKAGE" ;;
  brew) brew uninstall "$TARGET_PACKAGE" ;;
  *) echo "Unsupported package manager; no changes made." ;;
esac
