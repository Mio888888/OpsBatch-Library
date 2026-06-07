#!/usr/bin/env bash
set -euo pipefail

TARGET_PACKAGE="${TARGET_PACKAGE:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "Set TARGET_PACKAGE to inspect package version details, for example TARGET_PACKAGE=openssl."
  exit 0
fi

echo "== package version detail: $TARGET_PACKAGE =="
if command -v apt-cache >/dev/null 2>&1; then
  apt-cache policy "$TARGET_PACKAGE" 2>/dev/null || true
  dpkg-query -W -f='installed: ${binary:Package} ${Version} ${Architecture}\n' "$TARGET_PACKAGE" 2>/dev/null || true
fi
if command -v dnf >/dev/null 2>&1; then
  dnf list --showduplicates "$TARGET_PACKAGE" 2>/dev/null || true
  rpm -qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,25p' || true
elif command -v yum >/dev/null 2>&1; then
  yum list --showduplicates "$TARGET_PACKAGE" 2>/dev/null || true
  rpm -qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,25p' || true
elif command -v rpm >/dev/null 2>&1; then
  rpm -qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,25p' || true
fi
if command -v pacman >/dev/null 2>&1; then
  pacman -Qi "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,30p' || true
  pacman -Si "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,30p' || true
fi
if command -v apk >/dev/null 2>&1; then
  apk info -a "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true
fi
if command -v zypper >/dev/null 2>&1; then
  zypper --non-interactive info "$TARGET_PACKAGE" 2>/dev/null || true
fi
if command -v brew >/dev/null 2>&1; then
  brew info "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,40p' || true
fi
