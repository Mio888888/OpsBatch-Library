#!/usr/bin/env bash
set -euo pipefail

CACHE_TARGET="${CACHE_TARGET:-}"
CONFIRM_CLEAN="${CONFIRM_CLEAN:-}"

if [ -z "$CACHE_TARGET" ]; then
  echo "拒绝执行：请显式设置 CACHE_TARGET，例如 CACHE_TARGET=apt、dnf、pacman、brew 或 all。"
  exit 0
fi

echo "信息：== 受保护软件包缓存清理计划 =="
echo "信息：CACHE_TARGET=$CACHE_TARGET"

if [ "$CONFIRM_CLEAN" != "CLEAN_PACKAGE_CACHE" ]; then
  echo "仅试运行。 请设置 CONFIRM_CLEAN=CLEAN_PACKAGE_CACHE 在审核软件包管理器缓存影响后。"
  echo "信息：检测到的缓存位置:"
  [ -d /var/cache/apt ] && du -sh /var/cache/apt /var/lib/apt/lists 2>/dev/null || true
  [ -d /var/cache/dnf ] && du -sh /var/cache/dnf 2>/dev/null || true
  [ -d /var/cache/yum ] && du -sh /var/cache/yum 2>/dev/null || true
  [ -d /var/cache/pacman/pkg ] && du -sh /var/cache/pacman/pkg 2>/dev/null || true
  command -v brew >/dev/null 2>&1 && brew --cache 2>/dev/null | while read -r cache_dir; do du -sh "$cache_dir" 2>/dev/null; done
  exit 0
fi

case "$CACHE_TARGET" in
  all)
    command -v apt-get >/dev/null 2>&1 && sudo apt-get clean
    command -v dnf >/dev/null 2>&1 && sudo dnf clean all
    command -v yum >/dev/null 2>&1 && sudo yum clean all
    command -v pacman >/dev/null 2>&1 && sudo pacman -Sc
    command -v zypper >/dev/null 2>&1 && sudo zypper clean --all
    command -v brew >/dev/null 2>&1 && brew cleanup -s
    ;;
  apt) sudo apt-get clean ;;
  dnf) sudo dnf clean all ;;
  yum) sudo yum clean all ;;
  pacman) sudo pacman -Sc ;;
  zypper) sudo zypper clean --all ;;
  brew) brew cleanup -s ;;
  *) echo "信息：不支持的 CACHE_TARGET: $CACHE_TARGET。支持值：all、apt、dnf、yum、pacman、zypper、brew。" ;;
esac
