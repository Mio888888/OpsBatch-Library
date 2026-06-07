#!/usr/bin/env bash
set -euo pipefail

echo "== package repository/source summary =="

if [ -d /etc/apt ]; then
  echo "-- apt sources --"
  for file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -r "$file" ] || continue
    echo "# $file"
    grep -Ev '^[[:space:]]*(#|$)' "$file" 2>/dev/null | sed -n '1,20p'
  done
fi

if [ -d /etc/yum.repos.d ]; then
  echo "-- yum/dnf repos --"
  for file in /etc/yum.repos.d/*.repo; do
    [ -r "$file" ] || continue
    echo "# $file"
    grep -E '^[[:space:]]*(\[|name=|enabled=|baseurl=|metalink=|mirrorlist=|gpgcheck=)' "$file" 2>/dev/null | sed -n '1,40p'
  done
fi

if [ -r /etc/pacman.conf ]; then
  echo "-- pacman repositories --"
  grep -E '^[[:space:]]*(\[|Server|Include|SigLevel)' /etc/pacman.conf 2>/dev/null | sed -n '1,80p'
fi

if [ -d /etc/apk ]; then
  echo "-- apk repositories --"
  [ -r /etc/apk/repositories ] && grep -Ev '^[[:space:]]*(#|$)' /etc/apk/repositories 2>/dev/null
fi

if command -v zypper >/dev/null 2>&1; then
  echo "-- zypper repositories --"
  zypper --non-interactive repos --details 2>/dev/null || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "-- brew taps --"
  brew tap 2>/dev/null || true
fi
