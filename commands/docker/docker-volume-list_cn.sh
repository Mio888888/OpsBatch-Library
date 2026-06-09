#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

echo "信息：== Docker 卷列表 =="
docker volume ls 2>&1 || true

echo
echo "信息：== 卷挂载点摘要 =="
docker volume ls -q 2>/dev/null | while read -r volume; do
  [ -n "$volume" ] || continue
  docker volume inspect --format 'name={{.Name}} driver={{.Driver}} mountpoint={{.Mountpoint}}' "$volume" 2>/dev/null || true
done

echo
echo "信息：== 未使用卷候选 =="
docker volume ls -qf dangling=true 2>/dev/null || true
