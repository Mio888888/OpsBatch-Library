#!/usr/bin/env bash
set -euo pipefail

SHOW_ALL="${SHOW_ALL:-false}"
SHOW_DIGESTS="${SHOW_DIGESTS:-false}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

args=(images)
[ "$SHOW_ALL" = "true" ] && args+=(-a)
[ "$SHOW_DIGESTS" = "true" ] && args+=(--digests)

echo "== Docker images =="
docker "${args[@]}" --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}' 2>&1 || true

echo
echo "== dangling image candidates =="
docker images --filter dangling=true --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}' 2>/dev/null || true
