#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_PACKAGE="${TARGET_PACKAGE:-}"
CONFIRM_UPGRADE="${CONFIRM_UPGRADE:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "拒绝执行： 请显式设置 TARGET_PACKAGE。仅在审核全系统升级影响后才使用 TARGET_PACKAGE=all 在审核全系统升级影响后。"
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

echo "信息：== 受保护软件包升级计划 =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：TARGET_PACKAGE=$TARGET_PACKAGE"

case "$PACKAGE_MANAGER:$TARGET_PACKAGE" in
  apt:all) apt-get -s upgrade 2>/dev/null | sed -n '1,100p' || true ;;
  apt:*) apt-get -s install --only-upgrade "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  dnf:all) dnf upgrade --assumeno --setopt=metadata_expire=-1 2>/dev/null | sed -n '1,100p' || true ;;
  dnf:*) dnf upgrade --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  yum:all) yum update --assumeno --setopt=metadata_expire=-1 2>/dev/null | sed -n '1,100p' || true ;;
  yum:*) yum update --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  pacman:all) echo "信息：pacman 全量升级将执行: sudo pacman -Syu" ;;
  pacman:*) pacman -Sp "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  apk:all) apk upgrade -s 2>/dev/null | sed -n '1,100p' || true ;;
  apk:*) apk add -s -u "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  zypper:all) zypper --non-interactive update --dry-run 2>/dev/null | sed -n '1,100p' || true ;;
  zypper:*) zypper --non-interactive update --dry-run "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  brew:all) HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,100p' || true ;;
  brew:*) HOMEBREW_NO_AUTO_UPDATE=1 brew outdated "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  *) echo "不支持的软件包管理器。请审核后显式设置 PACKAGE_MANAGER。" ;;
esac

if [ "$CONFIRM_UPGRADE" != "UPGRADE_PACKAGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_UPGRADE=UPGRADE_PACKAGE 在审核变更日志、依赖、维护窗口、备份和回滚计划后。"
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
  *) echo "信息：不支持的软件包管理器；未执行变更。" ;;
esac
