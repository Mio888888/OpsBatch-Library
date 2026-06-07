#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-ssh}"
SINCE="${SINCE:-2 hours ago}"
LINES="${LINES:-120}"

echo "== service logs: $SERVICE_NAME since $SINCE =="
if [ "$(uname -s)" = "Linux" ] && command -v journalctl >/dev/null 2>&1; then
  journalctl -u "$SERVICE_NAME" --since "$SINCE" -n "$LINES" --no-pager 2>/dev/null || echo "No journal entries found or insufficient permission for service: $SERVICE_NAME"
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 2h --style compact --predicate "process == \"$SERVICE_NAME\"" 2>/dev/null | tail -n "$LINES" || true
else
  echo "No supported service log command found. Set SERVICE_NAME to the target service/process name."
fi
