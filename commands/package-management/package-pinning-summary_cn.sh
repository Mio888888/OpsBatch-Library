#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package pinning/hold/exclude summary =="

if command -v apt-mark >/dev/null 2>&1; then
  echo "信息：-- apt holds --"
  apt-mark showhold 2>/dev/null || true
fi
if [ -d /etc/apt/preferences.d ] || [ -r /etc/apt/preferences ]; then
  echo "信息：-- apt preferences --"
  for file in /etc/apt/preferences /etc/apt/preferences.d/*; do
    [ -r "$file" ] || continue
    echo "信息：# $file"
    sed -n '1,80p' "$file" 2>/dev/null
  done
fi

if [ -d /etc/yum/pluginconf.d ] || [ -d /etc/dnf/plugins ]; then
  echo "信息：-- yum/dnf versionlock hints --"
  for file in /etc/yum/pluginconf.d/versionlock.list /etc/dnf/plugins/versionlock.list /etc/yum.conf /etc/dnf/dnf.conf; do
    [ -r "$file" ] || continue
    echo "信息：# $file"
    grep -E '^[[:space:]]*(exclude=|includepkgs=|[A-Za-z0-9_.:+-]+)' "$file" 2>/dev/null | sed -n '1,80p'
  done
fi

if [ -r /etc/pacman.conf ]; then
  echo "信息：-- pacman IgnorePkg/IgnoreGroup --"
  grep -E '^[[:space:]]*(IgnorePkg|IgnoreGroup)[[:space:]]*=' /etc/pacman.conf 2>/dev/null || true
fi

if command -v apk >/dev/null 2>&1; then
  echo "信息：-- apk world constraints --"
  [ -r /etc/apk/world ] && sed -n '1,80p' /etc/apk/world 2>/dev/null || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew pinned formulae --"
  brew list --pinned 2>/dev/null || true
fi
