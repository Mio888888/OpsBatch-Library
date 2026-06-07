#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package update candidates =="
echo "信息：此命令为只读，并避免刷新软件包元数据。"

if command -v apt >/dev/null 2>&1; then
  echo "信息：-- apt list --upgradable --"
  apt list --upgradable 2>/dev/null | sed -n '1,80p' || true
elif command -v apt-get >/dev/null 2>&1; then
  echo "apt 不可用；检查升级前，仅可在维护窗口内运行 apt-get update。"
fi

if command -v dnf >/dev/null 2>&1; then
  echo "信息：-- dnf check-update --"
  dnf check-update --cacheonly 2>/dev/null | sed -n '1,80p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "信息：-- yum check-update --"
  yum check-update -C 2>/dev/null | sed -n '1,80p' || true
fi

if command -v pacman >/dev/null 2>&1; then
  echo "信息：-- pacman foreign/local package note --"
  echo "信息：pacman 需要同步数据库才能获知远端更新；此处不运行 pacman -Sy。"
  pacman -Qu 2>/dev/null | sed -n '1,80p' || true
fi

if command -v apk >/dev/null 2>&1; then
  echo "信息：-- apk version --"
  apk version -l '<' 2>/dev/null | sed -n '1,80p' || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "信息：-- zypper list-updates --"
  zypper --non-interactive --no-refresh list-updates 2>/dev/null | sed -n '1,80p' || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew 过期软件包 --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
