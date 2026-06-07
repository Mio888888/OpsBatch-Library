#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package repository/source summary =="

if [ -d /etc/apt ]; then
  echo "信息：-- apt sources --"
  for file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -r "$file" ] || continue
    echo "信息：# $file"
    grep -Ev '^[[:space:]]*(#|$)' "$file" 2>/dev/null | sed -n '1,20p'
  done
fi

if [ -d /etc/yum.repos.d ]; then
  echo "信息：-- yum/dnf repos --"
  for file in /etc/yum.repos.d/*.repo; do
    [ -r "$file" ] || continue
    echo "信息：# $file"
    grep -E '^[[:space:]]*(\[|name=|enabled=|baseurl=|metalink=|mirrorlist=|gpgcheck=)' "$file" 2>/dev/null | sed -n '1,40p'
  done
fi

if [ -r /etc/pacman.conf ]; then
  echo "信息：-- pacman repositories --"
  grep -E '^[[:space:]]*(\[|Server|Include|SigLevel)' /etc/pacman.conf 2>/dev/null | sed -n '1,80p'
fi

if [ -d /etc/apk ]; then
  echo "信息：-- apk repositories --"
  [ -r /etc/apk/repositories ] && grep -Ev '^[[:space:]]*(#|$)' /etc/apk/repositories 2>/dev/null
fi

if command -v zypper >/dev/null 2>&1; then
  echo "信息：-- zypper repositories --"
  zypper --non-interactive repos --details 2>/dev/null || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew taps --"
  brew tap 2>/dev/null || true
fi
