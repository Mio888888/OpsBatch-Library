#!/usr/bin/env bash
set -euo pipefail

echo "== mounts with selected options =="
if [ "$(uname -s)" = "Linux" ] && command -v findmnt >/dev/null 2>&1; then
  findmnt -A -o TARGET,FSTYPE,OPTIONS | grep -E '(^TARGET|ro|rw|noexec|nosuid|nodev|relatime|sync|errors=)' || true
else
  mount | grep -E 'ro|rw|noexec|nosuid|nodev|sync|errors=' || true
fi
