#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-}}"
SERVICE_ACTION="${2:-${SERVICE_ACTION:-reload}}"
CONFIRM_SERVICE_ACTION="${3:-${CONFIRM_SERVICE_ACTION:-}}"
CONFIRM_TOKEN="APPLY_SERVICE_ACTION"
VALIDATE_CMD="${VALIDATE_CMD:-}"
HEALTH_URL="${HEALTH_URL:-}"
TIMEOUT="${TIMEOUT:-10}"

if [[ ! "${SERVICE_ACTION}" =~ ^(reload|restart)$ ]]; then
  echo "SERVICE_ACTION must be reload or restart." >&2
  exit 2
fi

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "TIMEOUT must be a positive integer." >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "TIMEOUT is capped at 60 seconds." >&2
  TIMEOUT=60
fi

echo "Protected deployment service gate"
echo "Service: ${SERVICE:-<missing>}"
echo "Requested action: ${SERVICE_ACTION}"
echo "Validation command: ${VALIDATE_CMD:-<none>}"
echo "Health URL: ${HEALTH_URL:-<none>}"
echo "Default action: status, validation, and plan only"
echo "Reloading or restarting a service may interrupt active workloads."
echo

if [[ -z "${SERVICE}" ]]; then
  echo "Set SERVICE or pass a service name as the first argument."
  echo "No service action was performed."
  exit 0
fi

echo "== Current service status =="
if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
elif command -v launchctl >/dev/null 2>&1; then
  launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "No matching launchctl service found."
else
  echo "No supported service status command found."
fi
echo

echo "== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "Running validation command supplied by operator: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "No VALIDATE_CMD supplied."
fi
echo

if [[ "${CONFIRM_SERVICE_ACTION}" != "${CONFIRM_TOKEN}" ]]; then
  echo "Plan only. No ${SERVICE_ACTION} was performed."
  echo "To apply, rerun with CONFIRM_SERVICE_ACTION=${CONFIRM_TOKEN}."
  exit 0
fi

echo "Confirmation token accepted. Applying ${SERVICE_ACTION} to ${SERVICE}."
if command -v systemctl >/dev/null 2>&1; then
  if [[ "${SERVICE_ACTION}" == "reload" ]]; then
    systemctl reload "${SERVICE}"
  else
    systemctl restart "${SERVICE}"
  fi
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" "${SERVICE_ACTION}"
else
  echo "No supported Linux service action command found. Refusing to apply ${SERVICE_ACTION}." >&2
  exit 1
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "== Post-action health probe =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl not available; health probe skipped."
  fi
fi
