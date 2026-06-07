#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
POD_NAME="${POD_NAME:-}"
CONTAINER_NAME="${CONTAINER_NAME:-}"
LINES="${LINES:-120}"
SINCE="${SINCE:-2h}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found."
  exit 0
fi

if [ -z "$POD_NAME" ]; then
  echo "Refusing to run: set POD_NAME explicitly."
  echo "Pods in namespace $NAMESPACE:"
  kubectl get pods -n "$NAMESPACE" 2>/dev/null || true
  exit 0
fi

echo "== Kubernetes logs: namespace=$NAMESPACE pod=$POD_NAME =="
if [ -n "$CONTAINER_NAME" ]; then
  kubectl logs -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER_NAME" --since="$SINCE" --tail="$LINES" 2>&1 || echo "kubectl logs failed; check namespace, pod, container and permissions."
else
  kubectl logs -n "$NAMESPACE" "$POD_NAME" --since="$SINCE" --tail="$LINES" 2>&1 || echo "kubectl logs failed; check namespace, pod and permissions."
fi
