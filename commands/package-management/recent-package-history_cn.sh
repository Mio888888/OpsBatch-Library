#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "信息：== recent package operation history (limit: $LIMIT) =="

for file in /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log; do
  [ -r "$file" ] || continue
  echo "信息：-- $file --"
  tail -n "$LIMIT" "$file" 2>/dev/null || true
done

if command -v dnf >/dev/null 2>&1; then
  echo "信息：-- dnf history --"
  dnf history list 2>/dev/null | sed -n '1,40p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "信息：-- yum history --"
  yum history list 2>/dev/null | sed -n '1,40p' || true
fi

if [ -r /var/log/pacman.log ]; then
  echo "信息：-- pacman log --"
  tail -n "$LIMIT" /var/log/pacman.log 2>/dev/null || true
fi

if [ -r /var/log/apk.log ]; then
  echo "信息：-- apk log --"
  tail -n "$LIMIT" /var/log/apk.log 2>/dev/null || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "信息：-- zypper packages log --"
  [ -r /var/log/zypp/history ] && tail -n "$LIMIT" /var/log/zypp/history 2>/dev/null || true
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew leaves and analytics state --"
  brew leaves 2>/dev/null | sed -n '1,80p' || true
fi
