#!/usr/bin/env bash
set -euo pipefail

VERBOSE="${VERBOSE:-false}"

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

echo "信息：== Docker 磁盘占用 =="
if [ "$VERBOSE" = "true" ]; then
  docker system df -v 2>&1 || true
else
  docker system df 2>&1 || true
fi

if [ "$(uname -s)" = "Linux" ]; then
  data_root="$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || true)"
  if [ -n "$data_root" ] && [ -d "$data_root" ]; then
    echo
    echo "信息：== Docker data root 占用 =="
    du -sh "$data_root" 2>/dev/null || true
  fi
fi
