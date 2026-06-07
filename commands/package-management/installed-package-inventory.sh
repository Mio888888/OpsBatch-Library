#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "== installed package inventory (limit: $LIMIT) =="

if command -v dpkg-query >/dev/null 2>&1; then
  echo "-- dpkg packages --"
  dpkg-query -W -f='${binary:Package}\t${Version}\t${Architecture}\n' 2>/dev/null | head -"$LIMIT"
elif command -v rpm >/dev/null 2>&1; then
  echo "-- rpm packages --"
  rpm -qa --qf '%{NAME}\t%{VERSION}-%{RELEASE}\t%{ARCH}\n' 2>/dev/null | sort | head -"$LIMIT"
elif command -v pacman >/dev/null 2>&1; then
  echo "-- pacman packages --"
  pacman -Q 2>/dev/null | head -"$LIMIT"
elif command -v apk >/dev/null 2>&1; then
  echo "-- apk packages --"
  apk info -vv 2>/dev/null | head -"$LIMIT"
elif command -v zypper >/dev/null 2>&1; then
  echo "-- zypper packages --"
  zypper --non-interactive search --installed-only 2>/dev/null | head -"$LIMIT"
elif command -v brew >/dev/null 2>&1; then
  echo "-- brew formulae --"
  brew list --versions 2>/dev/null | head -"$LIMIT"
  echo "-- brew casks --"
  brew list --cask --versions 2>/dev/null | head -"$LIMIT"
else
  echo "No supported package inventory command found."
fi
