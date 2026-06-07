#!/usr/bin/env bash
set -euo pipefail

CACHE_TARGET="${CACHE_TARGET:-}"
CONFIRM_CLEAN="${CONFIRM_CLEAN:-}"

if [ -z "$CACHE_TARGET" ]; then
  echo "拒绝执行： set CACHE_TARGET explicitly, for example CACHE_TARGET=apt, CACHE_TARGET=dnf, CACHE_TARGET=pacman, CACHE_TARGET=brew, or CACHE_TARGET=all.（Refusing to run: set CACHE_TARGET explicitly, for example CACHE_TARGET=apt, CACHE_TARGET=dnf, CACHE_TARGET=pacman, CACHE_TARGET=brew, or CACHE_TARGET=all.）"
  exit 0
fi

echo "信息：== protected package cache cleanup plan =="
echo "信息：CACHE_TARGET=$CACHE_TARGET"

if [ "$CONFIRM_CLEAN" != "CLEAN_PACKAGE_CACHE" ]; then
  echo "仅试运行。 请设置 CONFIRM_CLEAN=CLEAN_PACKAGE_CACHE after reviewing package manager cache impact.（Dry-run only. Set CONFIRM_CLEAN=CLEAN_PACKAGE_CACHE after reviewing package manager cache impact.）"
  echo "信息：Detected cache locations:"
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
  *) echo "信息：Unsupported CACHE_TARGET: $CACHE_TARGET. Supported values: all, apt, dnf, yum, pacman, zypper, brew." ;;
esac
