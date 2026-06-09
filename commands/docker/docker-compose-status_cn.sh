#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-}"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  compose=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  compose=(docker-compose)
else
  echo "信息：未找到 docker compose 或 docker-compose。"
  exit 0
fi

if [ -n "$COMPOSE_FILE" ]; then
  compose+=(-f "$COMPOSE_FILE")
fi

echo "信息：== Docker Compose 版本 =="
"${compose[@]}" version 2>&1 || true

echo
echo "信息：== Docker Compose 服务状态 =="
"${compose[@]}" ps 2>&1 || true

echo
echo "信息：== Docker Compose 镜像 =="
"${compose[@]}" images 2>&1 || true

echo
echo "信息：== Docker Compose 配置校验 =="
"${compose[@]}" config --quiet 2>&1 && echo "信息：Compose 配置校验通过。" || true
