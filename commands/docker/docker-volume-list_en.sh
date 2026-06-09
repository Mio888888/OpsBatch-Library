#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

echo "== Docker volumes =="
docker volume ls 2>&1 || true

echo
echo "== volume mountpoint summary =="
docker volume ls -q 2>/dev/null | while read -r volume; do
  [ -n "$volume" ] || continue
  docker volume inspect --format 'name={{.Name}} driver={{.Driver}} mountpoint={{.Mountpoint}}' "$volume" 2>/dev/null || true
done

echo
echo "== unused volume candidates =="
docker volume ls -qf dangling=true 2>/dev/null || true
