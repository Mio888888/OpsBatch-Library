#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "== recent package operation history (limit: $LIMIT) =="

for file in /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log; do
  [ -r "$file" ] || continue
  echo "-- $file --"
  tail -n "$LIMIT" "$file" 2>/dev/null || true
done

if command -v dnf >/dev/null 2>&1; then
  echo "-- dnf history --"
  dnf history list 2>/dev/null | sed -n '1,40p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "-- yum history --"
  yum history list 2>/dev/null | sed -n '1,40p' || true
fi

if [ -r /var/log/pacman.log ]; then
  echo "-- pacman log --"
  tail -n "$LIMIT" /var/log/pacman.log 2>/dev/null || true
fi

if [ -r /var/log/apk.log ]; then
  echo "-- apk log --"
  tail -n "$LIMIT" /var/log/apk.log 2>/dev/null || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "-- zypper packages log --"
  [ -r /var/log/zypp/history ] && tail -n "$LIMIT" /var/log/zypp/history 2>/dev/null || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "-- brew leaves and analytics state --"
  brew leaves 2>/dev/null | sed -n '1,80p' || true
fi
