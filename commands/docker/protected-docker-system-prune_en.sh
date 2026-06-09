#!/usr/bin/env bash
set -euo pipefail

PRUNE_TARGET="${PRUNE_TARGET:-}"
INCLUDE_VOLUMES="${INCLUDE_VOLUMES:-false}"
UNTIL="${UNTIL:-}"
CONFIRM_PRUNE="${CONFIRM_PRUNE:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

if [ -z "$PRUNE_TARGET" ]; then
  echo "Refusing to run: set PRUNE_TARGET explicitly. Supported values: system, images, containers, networks, volumes, builder."
  docker system df 2>/dev/null || true
  exit 0
fi

echo "== Docker cleanup plan =="
printf 'prune_target=%s\n' "$PRUNE_TARGET"
printf 'include_volumes=%s\n' "$INCLUDE_VOLUMES"
printf 'until=%s\n' "${UNTIL:-<none>}"
docker system df 2>/dev/null || true

if [ "$CONFIRM_PRUNE" != "PRUNE_DOCKER_RESOURCES" ]; then
  echo "Dry-run only. Set CONFIRM_PRUNE=PRUNE_DOCKER_RESOURCES after confirming image rollback, volume data, build cache, and business impact."
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
  *) echo "Unsupported PRUNE_TARGET: $PRUNE_TARGET. Supported values: system, images, containers, networks, volumes, builder." ;;
esac
