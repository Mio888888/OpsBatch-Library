#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_CONFIG="${1:-${LOGROTATE_CONFIG:-}}"
CONFIRM_ROTATE="${2:-${CONFIRM_ROTATE:-}}"
CONFIRM_TOKEN="RUN_LOGROTATE"

if [[ -z "${LOGROTATE_CONFIG}" ]]; then
  echo "Set LOGROTATE_CONFIG or pass a logrotate config path."
  echo "No rotation was performed."
  exit 0
fi

if [[ ! -f "${LOGROTATE_CONFIG}" ]]; then
  echo "Logrotate config not found: ${LOGROTATE_CONFIG}" >&2
  exit 1
fi

if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command not available on this host." >&2
  exit 1
fi

echo "Protected logrotate maintenance plan"
echo "Config: ${LOGROTATE_CONFIG}"
echo "Default action: debug/dry-run only"
echo "Real rotation can move, compress, truncate, delete logs, and run postrotate hooks."
echo

echo "== logrotate debug output =="
logrotate -d "${LOGROTATE_CONFIG}"
echo

if [[ "${CONFIRM_ROTATE}" != "${CONFIRM_TOKEN}" ]]; then
  echo "Dry-run only. No log rotation was performed."
  echo "To run real rotation, rerun with CONFIRM_ROTATE=${CONFIRM_TOKEN}."
  exit 0
fi

echo "Confirmation token accepted. Running logrotate with verbose output."
logrotate -v "${LOGROTATE_CONFIG}"
