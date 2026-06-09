#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

args=(stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}')
[ -n "$CONTAINER_NAME" ] && args+=("$CONTAINER_NAME")

echo "== Docker container resource usage =="
docker "${args[@]}" 2>&1 || true
