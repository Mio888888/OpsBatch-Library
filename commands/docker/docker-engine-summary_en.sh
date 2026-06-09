#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

echo "== Docker client/server version =="
docker version 2>&1 || true

echo
echo "== Docker info summary =="
docker info 2>&1 | sed -n '1,90p' || true

if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  echo
  echo "== docker.service status =="
  systemctl is-active docker 2>/dev/null || true
  systemctl status docker --no-pager 2>/dev/null | head -50 || true
fi
