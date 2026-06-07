#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-ssh}}"

echo "Service: ${SERVICE}"

if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
else
  pgrep -fl "${SERVICE}" || {
    echo "No matching process found for ${SERVICE}."
    exit 0
  }
fi
