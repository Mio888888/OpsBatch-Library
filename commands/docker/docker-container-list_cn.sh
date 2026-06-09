#!/usr/bin/env bash
set -euo pipefail

SHOW_ALL="${SHOW_ALL:-true}"
SHOW_SIZE="${SHOW_SIZE:-false}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

args=(ps)
[ "$SHOW_ALL" = "true" ] && args+=(-a)
[ "$SHOW_SIZE" = "true" ] && args+=(--size)

echo "信息：== Docker 容器列表 =="
docker "${args[@]}" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.ID}}' 2>&1 || true
