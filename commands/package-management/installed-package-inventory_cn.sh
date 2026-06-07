#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "信息：== installed package inventory (limit: $LIMIT) =="

if command -v dpkg-query >/dev/null 2>&1; then
  echo "信息：-- dpkg packages --"
  dpkg-query -W -f='${binary:Package}\t${Version}\t${Architecture}\n' 2>/dev/null | head -"$LIMIT"
elif command -v rpm >/dev/null 2>&1; then
  echo "信息：-- rpm packages --"
  rpm -qa --qf '%{NAME}\t%{VERSION}-%{RELEASE}\t%{ARCH}\n' 2>/dev/null | sort | head -"$LIMIT"
elif command -v pacman >/dev/null 2>&1; then
  echo "信息：-- pacman packages --"
  pacman -Q 2>/dev/null | head -"$LIMIT"
elif command -v apk >/dev/null 2>&1; then
  echo "信息：-- apk packages --"
  apk info -vv 2>/dev/null | head -"$LIMIT"
elif command -v zypper >/dev/null 2>&1; then
  echo "信息：-- zypper packages --"
  zypper --non-interactive search --installed-only 2>/dev/null | head -"$LIMIT"
elif command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew formulae --"
  brew list --versions 2>/dev/null | head -"$LIMIT"
  echo "信息：-- brew casks --"
  brew list --cask --versions 2>/dev/null | head -"$LIMIT"
else
  echo "未找到受支持的 package inventory command found.（No supported package inventory command found.）"
fi
