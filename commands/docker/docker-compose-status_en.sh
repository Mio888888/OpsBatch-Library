#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-}"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  compose=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  compose=(docker-compose)
else
  echo "docker compose or docker-compose not found."
  exit 0
fi

if [ -n "$COMPOSE_FILE" ]; then
  compose+=(-f "$COMPOSE_FILE")
fi

echo "== Docker Compose version =="
"${compose[@]}" version 2>&1 || true

echo
echo "== Docker Compose service status =="
"${compose[@]}" ps 2>&1 || true

echo
echo "== Docker Compose images =="
"${compose[@]}" images 2>&1 || true

echo
echo "== Docker Compose config validation =="
"${compose[@]}" config --quiet 2>&1 && echo "Compose config validation passed." || true
