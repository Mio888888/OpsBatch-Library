#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "信息：未找到 docker 命令。"
  exit 0
fi

echo "信息：== Docker client/server version =="
docker version 2>&1 || true

echo
echo "信息：== Docker info 摘要 =="
docker info 2>&1 | sed -n '1,90p' || true

if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  echo
  echo "信息：== docker.service 状态 =="
  systemctl is-active docker 2>/dev/null || true
  systemctl status docker --no-pager 2>/dev/null | head -50 || true
fi
