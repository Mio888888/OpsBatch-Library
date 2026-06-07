#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_PACKAGE="${TARGET_PACKAGE:-}"
CONFIRM_UPGRADE="${CONFIRM_UPGRADE:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "拒绝执行： set TARGET_PACKAGE explicitly. Use TARGET_PACKAGE=all only after reviewing full-system upgrade impact.（Refusing to run: set TARGET_PACKAGE explicitly. Use TARGET_PACKAGE=all only after reviewing full-system upgrade impact.）"
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

echo "信息：== protected package upgrade plan =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：TARGET_PACKAGE=$TARGET_PACKAGE"

case "$PACKAGE_MANAGER:$TARGET_PACKAGE" in
  apt:all) apt-get -s upgrade 2>/dev/null | sed -n '1,100p' || true ;;
  apt:*) apt-get -s install --only-upgrade "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  dnf:all) dnf upgrade --assumeno --setopt=metadata_expire=-1 2>/dev/null | sed -n '1,100p' || true ;;
  dnf:*) dnf upgrade --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  yum:all) yum update --assumeno --setopt=metadata_expire=-1 2>/dev/null | sed -n '1,100p' || true ;;
  yum:*) yum update --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  pacman:all) echo "信息：pacman full upgrade would run: sudo pacman -Syu" ;;
  pacman:*) pacman -Sp "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  apk:all) apk upgrade -s 2>/dev/null | sed -n '1,100p' || true ;;
  apk:*) apk add -s -u "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  zypper:all) zypper --non-interactive update --dry-run 2>/dev/null | sed -n '1,100p' || true ;;
  zypper:*) zypper --non-interactive update --dry-run "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  brew:all) HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,100p' || true ;;
  brew:*) HOMEBREW_NO_AUTO_UPDATE=1 brew outdated "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  *) echo "Unsupported package manager. 请设置 PACKAGE_MANAGER explicitly after review.（Unsupported package manager. Set PACKAGE_MANAGER explicitly after review.）" ;;
esac

if [ "$CONFIRM_UPGRADE" != "UPGRADE_PACKAGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_UPGRADE=UPGRADE_PACKAGE after reviewing changelog, dependencies, maintenance window, backups, and rollback plan.（Dry-run only. Set CONFIRM_UPGRADE=UPGRADE_PACKAGE after reviewing changelog, dependencies, maintenance window, backups, and rollback plan.）"
  exit 0
fi

case "$PACKAGE_MANAGER:$TARGET_PACKAGE" in
  apt:all) sudo apt-get upgrade ;;
  apt:*) sudo apt-get install --only-upgrade "$TARGET_PACKAGE" ;;
  dnf:all) sudo dnf upgrade ;;
  dnf:*) sudo dnf upgrade "$TARGET_PACKAGE" ;;
  yum:all) sudo yum update ;;
  yum:*) sudo yum update "$TARGET_PACKAGE" ;;
  pacman:all) sudo pacman -Syu ;;
  pacman:*) sudo pacman -S "$TARGET_PACKAGE" ;;
  apk:all) sudo apk upgrade ;;
  apk:*) sudo apk add -u "$TARGET_PACKAGE" ;;
  zypper:all) sudo zypper update ;;
  zypper:*) sudo zypper update "$TARGET_PACKAGE" ;;
  brew:all) brew upgrade ;;
  brew:*) brew upgrade "$TARGET_PACKAGE" ;;
  *) echo "信息：Unsupported package manager; no changes made." ;;
esac
