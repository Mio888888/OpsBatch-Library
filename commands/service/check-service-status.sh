#!/usr/bin/env bash
set -euo pipefail

SERVICE=${SERVICE:-ssh}
if command -v systemctl >/dev/null 2>&1; then
  systemctl status "$SERVICE" --no-pager
elif command -v service >/dev/null 2>&1; then
  service "$SERVICE" status
else
  pgrep -fl "$SERVICE" || true
fi
