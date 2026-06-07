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
  echo "信息：ACTION must be deploy or rollback." >&2
  exit 2
fi

if [[ ! "${SERVICE_ACTION}" =~ ^(none|reload|restart)$ ]]; then
  echo "信息：SERVICE_ACTION must be none, reload, or restart." >&2
  exit 2
fi

if [[ ! "${TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：TIMEOUT must be a positive integer." >&2
  exit 2
fi

if (( TIMEOUT > 60 )); then
  echo "信息：TIMEOUT is capped at 60 seconds." >&2
  TIMEOUT=60
fi

echo "受保护 deployment release switch plan（Protected deployment release switch plan）"
echo "信息：Action: ${ACTION}"
echo "信息：Current link: ${CURRENT_LINK:-<missing>}"
echo "信息：Target release: ${TARGET_RELEASE:-<missing>}"
echo "信息：Validation command: ${VALIDATE_CMD:-<none>}"
echo "信息：Service/action: ${SERVICE:-<none>}/${SERVICE_ACTION}"
echo "信息：Health URL: ${HEALTH_URL:-<none>}"
echo "默认操作： plan and validation only（Default action: plan and validation only）"
echo "Switching releases or restarting services 可能中断 active workloads.（Switching releases or restarting services may interrupt active workloads.）"
echo

if [[ -z "${CURRENT_LINK}" || -z "${TARGET_RELEASE}" ]]; then
  echo "请设置 CURRENT_LINK and TARGET_RELEASE, or pass them as the first two arguments.（Set CURRENT_LINK and TARGET_RELEASE, or pass them as the first two arguments.）"
  echo "信息：No deployment change was performed."
  exit 0
fi

if [[ ! -d "${TARGET_RELEASE}" ]]; then
  echo "Target release directory 未找到: ${TARGET_RELEASE}（Target release directory not found: ${TARGET_RELEASE}）" >&2
  exit 1
fi

if [[ -e "${CURRENT_LINK}" && ! -L "${CURRENT_LINK}" ]]; then
  echo "信息：Current link path exists but is not a symlink; refusing to replace: ${CURRENT_LINK}" >&2
  exit 1
fi

echo "信息：== Current state =="
if [[ -L "${CURRENT_LINK}" ]]; then
  printf '%s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"
else
  echo "信息：Current link does not exist yet."
fi
ls -ld "${TARGET_RELEASE}" 2>/dev/null || true
echo

echo "信息：== Validation =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "信息：Running validation command supplied by operator: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "信息：No VALIDATE_CMD supplied; skipping validation command."
fi
echo

echo "信息：== Planned change =="
printf 'would_switch: %s -> %s\n' "${CURRENT_LINK}" "${TARGET_RELEASE}"
if [[ "${SERVICE_ACTION}" != "none" ]]; then
  if [[ -z "${SERVICE}" ]]; then
    echo "信息：SERVICE_ACTION=${SERVICE_ACTION} requested but SERVICE is empty; refusing." >&2
    exit 2
  fi
  printf 'would_%s_service: %s\n' "${SERVICE_ACTION}" "${SERVICE}"
fi
if [[ -n "${HEALTH_URL}" ]]; then
  printf 'would_probe_health_url: %s\n' "${HEALTH_URL}"
fi
echo

if [[ "${CONFIRM_DEPLOY}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：Plan only. No release switch, service reload/restart, or deployment change was performed."
  echo "信息：To apply, rerun with CONFIRM_DEPLOY=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：Confirmation token accepted. Switching release symlink."
ln -sfn "${TARGET_RELEASE}" "${CURRENT_LINK}"
printf 'switched: %s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"

if [[ "${SERVICE_ACTION}" != "none" ]]; then
  echo
  echo "信息：== Service ${SERVICE_ACTION} =="
  if command -v systemctl >/dev/null 2>&1; then
    if [[ "${SERVICE_ACTION}" == "reload" ]]; then
      systemctl reload "${SERVICE}"
    else
      systemctl restart "${SERVICE}"
    fi
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" "${SERVICE_ACTION}"
  else
    echo "未找到受支持的 service manager found after switch. Manual service action may be required.（No supported service manager found after switch. Manual service action may be required.）" >&2
    exit 1
  fi
fi

if [[ -n "${HEALTH_URL}" ]]; then
  echo
  echo "信息：== Post-switch health probe =="
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time "${TIMEOUT}" --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}"
  else
    echo "curl 不可用; cannot run health probe.（curl not available; cannot run health probe.）" >&2
    exit 1
  fi
fi
