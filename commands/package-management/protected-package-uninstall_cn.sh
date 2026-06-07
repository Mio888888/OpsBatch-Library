#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_PACKAGE="${TARGET_PACKAGE:-}"
CONFIRM_UNINSTALL="${CONFIRM_UNINSTALL:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "拒绝执行：请显式设置 TARGET_PACKAGE，例如 TARGET_PACKAGE=unused-package。"
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

echo "信息：== 受保护软件包卸载计划 =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：TARGET_PACKAGE=$TARGET_PACKAGE"

case "$PACKAGE_MANAGER" in
  apt) apt-get -s remove "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  dnf) dnf remove --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  yum) yum remove --assumeno --setopt=metadata_expire=-1 "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  pacman) echo "信息：pacman 删除将执行: sudo pacman -R $TARGET_PACKAGE"; pacman -Qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true ;;
  apk) apk del -s "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  zypper) zypper --non-interactive remove --dry-run "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,100p' || true ;;
  brew) brew uses --installed "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true; brew info "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true ;;
  *) echo "不支持的软件包管理器。请审核后显式设置 PACKAGE_MANAGER。" ;;
esac

if [ "$CONFIRM_UNINSTALL" != "UNINSTALL_PACKAGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_UNINSTALL=UNINSTALL_PACKAGE 在审核反向依赖、服务影响、备份和回滚计划后。"
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
  *) echo "信息：不支持的软件包管理器；未执行变更。" ;;
esac
