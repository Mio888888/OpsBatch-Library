#!/usr/bin/env bash
set -euo pipefail

CURRENT_LINK="${1:-${CURRENT_LINK:-}}"
TARGET_RELEASE="${2:-${TARGET_RELEASE:-}}"
ACTION="${ACTION:-deploy}"
CONFIRM_DEPLOY="${3:-${CONFIRM_DEPLOY:-}}"
CONFIRM_TOKEN="SWITCH_RELEASE"
VALIDATE_CMD="${VALIDATE_CMD:-}"
SERVICE="${SERVICE:-}"
SERVICE_ACTION="${SERVICE_ACTION:-none}"
HEALTH_URL="${HEALTH_URL:-}"
TIMEOUT="${TIMEOUT:-10}"

if [[ ! "${ACTION}" =~ ^(deploy|rollback)$ ]]; then
  echo "ACTION must be deploy or rollback." >&2
  exit 2
fi

if [[ ! "${SERVICE_ACTION}" =~ ^(none|reload|restart)$ ]]; then
  echo "SERVICE_ACTION must be none, reload, or restart." >&2
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

echo "Protected deployment release switch plan"
echo "Action: ${ACTION}"
echo "Current link: ${CURRENT_LINK:-<missing>}"
echo "Target release: ${TARGET_RELEASE:-<missing>}"
echo "Validation command: ${VALIDATE_CMD:-<none>}"
echo "Service/action: ${SERVICE:-<none>}/${SERVICE_ACTION}"
echo "Health URL: ${HEALTH_URL:-<none>}"
echo "Default action: plan and validation only"
echo "Switching releases or restarting services may interrupt active workloads."
echo

if [[ -z "${CURRENT_LINK}" || -z "${TARGET_RELEASE}" ]]; then
  echo "Set CURRENT_LINK and TARGET_RELEASE, or pass them as the first two arguments."
  echo "No deployment change was performed."
  exit 0
fi

if [[ ! -d "${TARGET_RELEASE}" ]]; then
  echo "Target release directory not found: ${TARGET_RELEASE}" >&2
  exit 1
fi

if [[ -e "${CURRENT_LINK}" && ! -L "${CURRENT_LINK}" ]]; then
  echo "Current link path exists but is not a symlink; refusing to replace: ${CURRENT_LINK}" >&2
  exit 1
fi

echo "== Current state =="
if [[ -L "${CURRENT_LINK}" ]]; then
  printf '%s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"
else
  echo "Current link does not exist yet."
fi
ls -ld "${TARGET_RELEASE}" 2>/dev/null || true
echo

echo "== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "Running validation command supplied by operator: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "No VALIDATE_CMD supplied; skipping validation command."
fi
echo

echo "== Planned change =="
printf 'would_switch: %s -> %s\n' "${CURRENT_LINK}" "${TARGET_RELEASE}"
if [[ "${SERVICE_ACTION}" != "none" ]]; then
  if [[ -z "${SERVICE}" ]]; then
    echo "SERVICE_ACTION=${SERVICE_ACTION} requested but SERVICE is empty; refusing." >&2
    exit 2
  fi
  printf 'would_%s_service: %s\n' "${SERVICE_ACTION}" "${SERVICE}"
fi
if [[ -n "${HEALTH_URL}" ]]; then
  printf 'would_probe_health_url: %s\n' "${HEALTH_URL}"
fi
echo

if [[ "${CONFIRM_DEPLOY}" != "${CONFIRM_TOKEN}" ]]; then
  echo "Plan only. No release switch, service reload/restart, or deployment change was performed."
  echo "To apply, rerun with CONFIRM_DEPLOY=${CONFIRM_TOKEN}."
  exit 0
fi

echo "Confirmation token accepted. Switching release symlink."
ln -sfn "${TARGET_RELEASE}" "${CURRENT_LINK}"
printf 'switched: %s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"

if [[ "${SERVICE_ACTION}" != "none" ]]; then
  echo
  echo "== Service ${SERVICE_ACTION} =="
  if command -v systemctl >/dev/null 2>&1; then
    if [[ "${SERVICE_ACTION}" == "reload" ]]; then
      systemctl reload "${SERVICE}"
    else
      systemctl restart "${SERVICE}"
    fi
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" "${SERVICE_ACTION}"
  else
    echo "No supported service manager found after switch. Manual service action may be required." >&2
    exit 1
  fi
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "== Post-switch health probe =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl not available; cannot run health probe." >&2
    exit 1
  fi
fi
