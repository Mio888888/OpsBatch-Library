#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

echo "== Docker networks =="
docker network ls 2>&1 || true

echo
echo "== network address summary =="
docker network ls -q 2>/dev/null | while read -r network_id; do
  [ -n "$network_id" ] || continue
  docker network inspect --format 'name={{.Name}} driver={{.Driver}} scope={{.Scope}}{{range .IPAM.Config}} subnet={{.Subnet}} gateway={{.Gateway}}{{end}}' "$network_id" 2>/dev/null || true
done
