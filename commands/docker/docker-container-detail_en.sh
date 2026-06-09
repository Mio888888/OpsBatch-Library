#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found."
  exit 0
fi

if [ -z "$CONTAINER_NAME" ]; then
  echo "Refusing to run: set CONTAINER_NAME explicitly."
  echo "Available containers:"
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}' 2>/dev/null || true
  exit 0
fi

echo "== Docker container detail: $CONTAINER_NAME =="
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
echo "== port mappings =="
docker port "$CONTAINER_NAME" 2>/dev/null || echo "No port mapping found or container is not accessible."

echo
echo "== mount summary =="
docker inspect --format '{{range .Mounts}}{{println .Type .Source "->" .Destination}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || true
