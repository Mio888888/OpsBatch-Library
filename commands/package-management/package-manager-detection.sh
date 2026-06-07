#!/usr/bin/env bash
set -euo pipefail

echo "== operating system =="
uname -a 2>/dev/null || true
[ -r /etc/os-release ] && sed -n '1,12p' /etc/os-release 2>/dev/null || true
[ "$(uname -s 2>/dev/null)" = "Darwin" ] && sw_vers 2>/dev/null || true

echo
echo "== package managers =="
for tool in apt apt-get dpkg dnf yum rpm pacman apk zypper brew softwareupdate pip3 pip npm; do
  if command -v "$tool" >/dev/null 2>&1; then
    path="$(command -v "$tool")"
    version="$($tool --version 2>/dev/null | head -1 || true)"
    [ -z "$version" ] && version="available"
    printf '%-16s %-40s %s\n' "$tool" "$path" "$version"
  else
    printf '%-16s %s\n' "$tool" "not found"
  fi
done
