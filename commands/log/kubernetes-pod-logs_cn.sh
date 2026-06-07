#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
POD_NAME="${POD_NAME:-}"
CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl 未找到."
  exit 0
fi

if [ -z "$POD_NAME" ]; then
  echo "拒绝执行： 请显式设置 POD_NAME。"
  echo "信息：命名空间中的 Pod $NAMESPACE:"
  kubectl get pods -n "$NAMESPACE" 2>/dev/null || true
  exit 0
fi

echo "信息：== Kubernetes 日志：namespace=$NAMESPACE pod=$POD_NAME =="
if [ -n "$CONTAINER_NAME" ]; then
  kubectl logs -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER_NAME" --since="$SINCE" --tail="$LINES" 2>&1 || echo "信息：kubectl logs 失败；请检查命名空间、Pod、容器和权限。"
else
  kubectl logs -n "$NAMESPACE" "$POD_NAME" --since="$SINCE" --tail="$LINES" 2>&1 || echo "信息：kubectl logs 失败；请检查命名空间、Pod 和权限。"
fi
