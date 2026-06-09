#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

if [ -z "$CONTAINER_NAME" ]; then
  echo "拒绝执行：请显式设置 CONTAINER_NAME。"
  echo "信息：可用容器："
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "信息：== Docker 容器日志：$CONTAINER_NAME =="
docker logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "信息：docker logs 失败；请检查容器名称、时间范围和权限。"
