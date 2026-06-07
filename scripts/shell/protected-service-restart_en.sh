#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-}}"
CONFIRM_RESTART="${2:-${CONFIRM_RESTART:-}}"
CONFIRM_TOKEN="RESTART_SERVICE"

if [[ -z "${SERVICE}" ]]; then
  echo "Set SERVICE or pass a service name to inspect/restart."
  echo "No restart was performed."
  exit 0
fi

echo "Protected service maintenance plan"
echo "Service: ${SERVICE}"
echo "Default action: status only"
echo "Restarting a service may interrupt active users or workloads."
echo

echo "== Current service status =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "No matching launchctl service found."
elif command -v pgrep >/dev/null 2>&1; then
  pgrep -fl "${SERVICE}" || echo "No matching process found for ${SERVICE}."
else
  echo "No supported service status command found."
fi
echo

if [[ "${CONFIRM_RESTART}" != "${CONFIRM_TOKEN}" ]]; then
  echo "Status only. No restart was performed."
  echo "To restart, rerun with CONFIRM_RESTART=${CONFIRM_TOKEN}."
  exit 0
fi

if command -v systemctl >/dev/null 2>&1; then
  echo "Confirmation token accepted. Restarting via systemctl."
  systemctl restart "${SERVICE}"
elif command -v service >/dev/null 2>&1; then
  echo "Confirmation token accepted. Restarting via service."
  service "${SERVICE}" restart
else
  echo "No supported restart command found. Refusing to restart ${SERVICE}." >&2
  exit 1
fi
