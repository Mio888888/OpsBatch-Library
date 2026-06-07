#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if [ -z "$CONTAINER_NAME" ]; then
  echo "拒绝执行： 请显式设置 CONTAINER_NAME。"
  echo "信息：可用容器："
  if command -v docker >/dev/null 2>&1; then
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || true
  elif command -v podman >/dev/null 2>&1; then
    podman ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || true
  else
    echo "docker or podman 未找到."
  fi
  exit 0
fi

echo "信息：== 容器日志： $CONTAINER_NAME =="
if command -v docker >/dev/null 2>&1; then
  docker logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "信息：docker logs 失败；请检查容器名称和权限。"
elif command -v podman >/dev/null 2>&1; then
  podman logs --since "$SINCE" --tail "$LINES" "$CONTAINER_NAME" 2>&1 || echo "信息：podman logs 失败；请检查容器名称和权限。"
else
  echo "docker or podman 未找到."
fi
