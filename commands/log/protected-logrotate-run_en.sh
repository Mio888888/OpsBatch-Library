#!/usr/bin/env bash
set -euo pipefail

if [ -n "${LOGROTATE_CONFIG:-}" ]; then
  LOGROTATE_CONFIG_WAS_SET="true"
else
  LOGROTATE_CONFIG_WAS_SET="false"
fi
LOGROTATE_CONFIG="${LOGROTATE_CONFIG:-/etc/logrotate.conf}"
LOGROTATE_STATE="${LOGROTATE_STATE:-}"
CONFIRM_ROTATE="${CONFIRM_ROTATE:-}"

if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command not found."
  exit 0
fi

if [ ! -f "$LOGROTATE_CONFIG" ]; then
  echo "LOGROTATE_CONFIG is not a file: $LOGROTATE_CONFIG"
  exit 0
fi

echo "== logrotate dry-run =="
if [ -n "$LOGROTATE_STATE" ]; then
  logrotate -d -s "$LOGROTATE_STATE" "$LOGROTATE_CONFIG" 2>&1 | tail -n 200 || true
else
  logrotate -d "$LOGROTATE_CONFIG" 2>&1 | tail -n 200 || true
fi

if [ "$CONFIRM_ROTATE" != "RUN_LOGROTATE" ]; then
  echo
  echo "Dry-run only. Set CONFIRM_ROTATE=RUN_LOGROTATE and LOGROTATE_CONFIG explicitly to execute logrotate after reviewing dry-run output and maintenance window."
  exit 0
fi

if [ "$LOGROTATE_CONFIG_WAS_SET" != "true" ]; then
  echo
  echo "Refusing real run: set LOGROTATE_CONFIG explicitly together with CONFIRM_ROTATE=RUN_LOGROTATE."
  exit 0
fi

echo
echo "Executing logrotate with config $LOGROTATE_CONFIG."
if [ -n "$LOGROTATE_STATE" ]; then
  logrotate -v -s "$LOGROTATE_STATE" "$LOGROTATE_CONFIG"
else
  logrotate -v "$LOGROTATE_CONFIG"
fi
