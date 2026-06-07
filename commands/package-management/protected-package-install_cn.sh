#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_PACKAGE="${TARGET_PACKAGE:-}"
CONFIRM_INSTALL="${CONFIRM_INSTALL:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "拒绝执行：请显式设置 TARGET_PACKAGE，例如 TARGET_PACKAGE=htop。"
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

echo "信息：== 受保护软件包安装计划 =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：TARGET_PACKAGE=$TARGET_PACKAGE"

case "$PACKAGE_MANAGER" in
  apt) apt-get -s install "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  dnf) dnf install --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  yum) yum install --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  pacman) pacman -Sp "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  apk) apk add -s "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  zypper) zypper --non-interactive install --dry-run "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  brew) brew info "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true ;;
  *) echo "不支持的软件包管理器。请查看支持的取值后显式设置 PACKAGE_MANAGER。" ;;
esac

if [ "$CONFIRM_INSTALL" != "INSTALL_PACKAGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_INSTALL=INSTALL_PACKAGE 在审核软件包来源、依赖、变更窗口和回滚计划后。"
  exit 0
fi

case "$PACKAGE_MANAGER" in
  apt) sudo apt-get install "$TARGET_PACKAGE" ;;
  dnf) sudo dnf install "$TARGET_PACKAGE" ;;
  yum) sudo yum install "$TARGET_PACKAGE" ;;
  pacman) sudo pacman -S "$TARGET_PACKAGE" ;;
  apk) sudo apk add "$TARGET_PACKAGE" ;;
  zypper) sudo zypper install "$TARGET_PACKAGE" ;;
  brew) brew install "$TARGET_PACKAGE" ;;
  *) echo "信息：不支持的软件包管理器；未执行变更。" ;;
esac
