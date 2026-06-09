#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
CONFIRM_RESTART="${CONFIRM_RESTART:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

if [ -z "$CONTAINER_NAME" ]; then
  echo "拒绝执行：请显式设置 CONTAINER_NAME。"
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "信息：== 计划重启 Docker 容器 =="
docker ps -a --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true

if [ "$CONFIRM_RESTART" != "RESTART_CONTAINER" ]; then
  echo "仅试运行。请在确认业务影响、依赖和回滚方案后设置 CONFIRM_RESTART=RESTART_CONTAINER。"
  exit 0
fi

docker restart "$CONTAINER_NAME"
