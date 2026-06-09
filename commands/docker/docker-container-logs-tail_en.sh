#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

if [ -z "$CONTAINER_NAME" ]; then
  echo "Refusing to run: set CONTAINER_NAME explicitly."
  echo "Available containers:"
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "== Docker container logs: $CONTAINER_NAME =="
docker logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "docker logs failed; check container name, time window, and permissions."
