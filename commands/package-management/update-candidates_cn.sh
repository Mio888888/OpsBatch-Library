#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package update candidates =="
echo "信息：This command is read-only and avoids refreshing package metadata."

if command -v apt >/dev/null 2>&1; then
  echo "信息：-- apt list --upgradable --"
  apt list --upgradable 2>/dev/null | sed -n '1,80p' || true
elif command -v apt-get >/dev/null 2>&1; then
  echo "apt is 不可用; run apt-get update only in a maintenance window before checking upgrades.（apt is not available; run apt-get update only in a maintenance window before checking upgrades.）"
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
  echo "信息：pacman needs a database sync to know remote updates; not running pacman -Sy here."
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
  echo "信息：-- brew outdated --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
