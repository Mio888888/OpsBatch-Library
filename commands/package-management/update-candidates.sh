#!/usr/bin/env bash
set -euo pipefail

echo "== package update candidates =="
echo "This command is read-only and avoids refreshing package metadata."

if command -v apt >/dev/null 2>&1; then
  echo "-- apt list --upgradable --"
  apt list --upgradable 2>/dev/null | sed -n '1,80p' || true
elif command -v apt-get >/dev/null 2>&1; then
  echo "apt is not available; run apt-get update only in a maintenance window before checking upgrades."
fi

if command -v dnf >/dev/null 2>&1; then
  echo "-- dnf check-update --"
  dnf check-update --cacheonly 2>/dev/null | sed -n '1,80p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "-- yum check-update --"
  yum check-update -C 2>/dev/null | sed -n '1,80p' || true
fi

if command -v pacman >/dev/null 2>&1; then
  echo "-- pacman foreign/local package note --"
  echo "pacman needs a database sync to know remote updates; not running pacman -Sy here."
  pacman -Qu 2>/dev/null | sed -n '1,80p' || true
fi

if command -v apk >/dev/null 2>&1; then
  echo "-- apk version --"
  apk version -l '<' 2>/dev/null | sed -n '1,80p' || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "-- zypper list-updates --"
  zypper --non-interactive --no-refresh list-updates 2>/dev/null | sed -n '1,80p' || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "-- brew outdated --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
