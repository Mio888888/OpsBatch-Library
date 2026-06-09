#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"
EXEC_COMMAND="${EXEC_COMMAND:-}"
EXEC_USER="${EXEC_USER:-}"
CONFIRM_EXEC="${CONFIRM_EXEC:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

if [ -z "$CONTAINER_NAME" ] || [ -z "$EXEC_COMMAND" ]; then
  echo "拒绝执行：请显式设置 CONTAINER_NAME 和 EXEC_COMMAND。"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "信息：== 计划在 Docker 容器内执行命令 =="
printf 'container=%s\n' "$CONTAINER_NAME"
printf 'exec_user=%s\n' "${EXEC_USER:-<container default>}"
printf 'exec_command=%s\n' "$EXEC_COMMAND"
docker ps --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true

if [ "$CONFIRM_EXEC" != "EXEC_IN_CONTAINER" ]; then
  echo "仅试运行。请在确认命令影响、权限和回滚方案后设置 CONFIRM_EXEC=EXEC_IN_CONTAINER。"
  exit 0
fi

args=(exec)
[ -n "$EXEC_USER" ] && args+=(-u "$EXEC_USER")
args+=("$CONTAINER_NAME" sh -lc "$EXEC_COMMAND")
docker "${args[@]}"
