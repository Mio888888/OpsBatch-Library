#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"

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

echo "信息：== Docker 容器详情：$CONTAINER_NAME =="
docker inspect --format 'name={{.Name}}
id={{.Id}}
image={{.Config.Image}}
created={{.Created}}
state={{.State.Status}}
running={{.State.Running}}
exit_code={{.State.ExitCode}}
pid={{.State.Pid}}
restart_policy={{.HostConfig.RestartPolicy.Name}}
network_mode={{.HostConfig.NetworkMode}}' "$CONTAINER_NAME" 2>&1 || true

echo
echo "信息：== 端口映射 =="
docker port "$CONTAINER_NAME" 2>/dev/null || echo "信息：未发现端口映射或容器不可访问。"

echo
echo "信息：== 挂载摘要 =="
docker inspect --format '{{range .Mounts}}{{println .Type .Source "->" .Destination}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || true
