#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if [ -z "$CONTAINER_NAME" ]; then
  echo "Refusing to run: set CONTAINER_NAME explicitly."
  echo "Available containers:"
  if command -v docker >/dev/null 2>&1; then
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || true
  elif command -v podman >/dev/null 2>&1; then
    podman ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || true
  else
    echo "docker or podman not found."
  fi
  exit 0
fi

echo "== container logs: $CONTAINER_NAME =="
if command -v docker >/dev/null 2>&1; then
  docker logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "docker logs failed; check container name and permissions."
elif command -v podman >/dev/null 2>&1; then
  podman logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "podman logs failed; check container name and permissions."
else
  echo "docker or podman not found."
fi
