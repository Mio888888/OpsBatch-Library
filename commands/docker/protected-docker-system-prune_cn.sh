#!/usr/bin/env bash
set -euo pipefail

PRUNE_TARGET="${PRUNE_TARGET:-}"
INCLUDE_VOLUMES="${INCLUDE_VOLUMES:-false}"
UNTIL="${UNTIL:-}"
CONFIRM_PRUNE="${CONFIRM_PRUNE:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

if [ -z "$PRUNE_TARGET" ]; then
  echo "拒绝执行：请显式设置 PRUNE_TARGET，可选 system、images、containers、networks、volumes、builder。"
  docker system df 2>/dev/null || true
  exit 0
fi

echo "信息：== Docker 清理计划 =="
printf 'prune_target=%s\n' "$PRUNE_TARGET"
printf 'include_volumes=%s\n' "$INCLUDE_VOLUMES"
printf 'until=%s\n' "${UNTIL:-<none>}"
docker system df 2>/dev/null || true

if [ "$CONFIRM_PRUNE" != "PRUNE_DOCKER_RESOURCES" ]; then
  echo "仅试运行。请在确认镜像回滚、卷数据、构建缓存和业务影响后设置 CONFIRM_PRUNE=PRUNE_DOCKER_RESOURCES。"
  exit 0
fi

filter_args=()
[ -n "$UNTIL" ] && filter_args+=(--filter "until=$UNTIL")

case "$PRUNE_TARGET" in
  system)
    args=(system prune -f "${filter_args[@]}")
    [ "$INCLUDE_VOLUMES" = "true" ] && args+=(--volumes)
    docker "${args[@]}"
    ;;
  images) docker image prune -a -f "${filter_args[@]}" ;;
  containers) docker container prune -f "${filter_args[@]}" ;;
  networks) docker network prune -f "${filter_args[@]}" ;;
  volumes) docker volume prune -f "${filter_args[@]}" ;;
  builder) docker builder prune -f "${filter_args[@]}" ;;
  *) echo "信息：不支持的 PRUNE_TARGET: $PRUNE_TARGET。支持值：system、images、containers、networks、volumes、builder。" ;;
esac
