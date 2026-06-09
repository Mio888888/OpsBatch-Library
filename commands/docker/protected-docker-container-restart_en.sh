#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
CONFIRM_RESTART="${CONFIRM_RESTART:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

if [ -z "$CONTAINER_NAME" ]; then
  echo "Refusing to run: set CONTAINER_NAME explicitly."
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "== planned Docker container restart =="
docker ps -a --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true

if [ "$CONFIRM_RESTART" != "RESTART_CONTAINER" ]; then
  echo "Dry-run only. Set CONFIRM_RESTART=RESTART_CONTAINER after confirming business impact, dependencies, and rollback plan."
  exit 0
fi

docker restart "$CONTAINER_NAME"
