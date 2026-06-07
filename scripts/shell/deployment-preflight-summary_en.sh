#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${1:-${APP_DIR:-}}"
ARTIFACT_PATH="${2:-${ARTIFACT_PATH:-}}"
SERVICE="${3:-${SERVICE:-}}"
HEALTH_URL="${4:-${HEALTH_URL:-}}"
CHECKSUM_FILE="${CHECKSUM_FILE:-}"
RELEASES_DIR="${RELEASES_DIR:-}"
VALIDATE_CMD="${VALIDATE_CMD:-}"
LIMIT="${LIMIT:-10}"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

echo "Deployment preflight summary"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "App dir: ${APP_DIR:-<not provided>}"
echo "Artifact path: ${ARTIFACT_PATH:-<not provided>}"
echo "Checksum file: ${CHECKSUM_FILE:-<not provided>}"
echo "Releases dir: ${RELEASES_DIR:-<not provided>}"
echo "Service: ${SERVICE:-<not provided>}"
echo "Health URL: ${HEALTH_URL:-<not provided>}"
echo "This script is read-only and does not deploy, restart, migrate, or switch symlinks."
echo

echo "== Required tool availability =="
for tool in bash tar gzip openssl curl shasum sha256sum systemctl service launchctl; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: available\n' "${tool}"
  else
    printf '%s: not available\n' "${tool}"
  fi
done
echo

echo "== Path checks =="
for path in "${APP_DIR}" "${ARTIFACT_PATH}" "${CHECKSUM_FILE}" "${RELEASES_DIR}"; do
  if [[ -z "${path}" ]]; then
    continue
  fi
  if [[ -e "${path}" ]]; then
    ls -ld "${path}" 2>/dev/null || true
  else
    printf 'missing: %s\n' "${path}"
  fi
done
echo

echo "== Artifact checksum preview =="
if [[ -n "${ARTIFACT_PATH}" && -f "${ARTIFACT_PATH}" ]]; then
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${ARTIFACT_PATH}"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${ARTIFACT_PATH}"
  else
    echo "No sha256 tool found."
  fi
else
  echo "No artifact file provided for digest preview."
fi
if [[ -n "${CHECKSUM_FILE}" ]]; then
  if [[ -f "${CHECKSUM_FILE}" ]]; then
    echo "Checksum file exists; run protected deploy or dedicated verification with operator approval."
  else
    echo "Checksum file path was provided but does not exist."
  fi
fi
echo

echo "== Release directory summary =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "${LIMIT}" || true
else
  echo "No releases directory provided or directory missing."
fi
if [[ -n "${APP_DIR}" && -L "${APP_DIR}/current" ]]; then
  printf 'current_symlink: %s -> %s\n' "${APP_DIR}/current" "$(readlink "${APP_DIR}/current")"
fi
echo

echo "== Service status =="
if [[ -n "${SERVICE}" ]]; then
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active "${SERVICE}" || true
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" status || true
  elif command -v launchctl >/dev/null 2>&1; then
    launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "No matching launchctl service found."
  else
    echo "No supported service manager found."
  fi
else
  echo "No service provided."
fi
echo

echo "== Optional validation command =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "Running read-only validation command supplied by operator: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "No VALIDATE_CMD provided."
fi
echo

echo "== Optional health URL probe =="
if [[ -n "${HEALTH_URL}" ]]; then
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time 10 --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}" || true
  else
    echo "curl not available."
  fi
else
  echo "No HEALTH_URL provided."
fi
