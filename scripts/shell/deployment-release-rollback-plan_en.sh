#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${1:-${APP_DIR:-}}"
RELEASES_DIR="${2:-${RELEASES_DIR:-}}"
CURRENT_LINK="${CURRENT_LINK:-}"
CANDIDATE_RELEASE="${CANDIDATE_RELEASE:-}"
LIMIT="${LIMIT:-10}"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ -n "${APP_DIR}" && ! -d "${APP_DIR}" ]]; then
  echo "APP_DIR does not exist or is not a directory: ${APP_DIR}" >&2
  exit 1
fi

if [[ -z "${RELEASES_DIR}" && -n "${APP_DIR}" ]]; then
  RELEASES_DIR="${APP_DIR}/releases"
fi

if [[ -z "${CURRENT_LINK}" && -n "${APP_DIR}" ]]; then
  CURRENT_LINK="${APP_DIR}/current"
fi

echo "Deployment release and rollback plan"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "App dir: ${APP_DIR:-<not provided>}"
echo "Releases dir: ${RELEASES_DIR:-<not provided>}"
echo "Current link: ${CURRENT_LINK:-<not provided>}"
echo "Candidate release: ${CANDIDATE_RELEASE:-<not provided>}"
echo "This script is read-only and does not switch symlinks or delete releases."
echo

echo "== Current release =="
if [[ -n "${CURRENT_LINK}" ]]; then
  if [[ -L "${CURRENT_LINK}" ]]; then
    printf '%s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"
  elif [[ -e "${CURRENT_LINK}" ]]; then
    echo "Current path exists but is not a symlink: ${CURRENT_LINK}"
  else
    echo "Current link does not exist: ${CURRENT_LINK}"
  fi
else
  echo "No CURRENT_LINK or APP_DIR provided."
fi
echo

echo "== Recent releases =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "${LIMIT}" || true
else
  echo "Releases directory missing or not provided."
fi
echo

echo "== Candidate release checks =="
if [[ -n "${CANDIDATE_RELEASE}" ]]; then
  if [[ -d "${CANDIDATE_RELEASE}" ]]; then
    ls -ld "${CANDIDATE_RELEASE}" 2>/dev/null || true
  elif [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}/${CANDIDATE_RELEASE}" ]]; then
    ls -ld "${RELEASES_DIR}/${CANDIDATE_RELEASE}" 2>/dev/null || true
  else
    echo "Candidate release not found as absolute path or under releases dir."
  fi
else
  echo "No CANDIDATE_RELEASE provided."
fi
echo

echo "== Rollback candidates =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  current_target=""
  if [[ -n "${CURRENT_LINK}" && -L "${CURRENT_LINK}" ]]; then
    current_target="$(readlink "${CURRENT_LINK}")"
  fi
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "$((LIMIT + 1))" | while IFS= read -r release; do
    if [[ "${release}" == "${current_target}" || "$(basename "${release}")" == "$(basename "${current_target}")" ]]; then
      printf 'current: %s\n' "${release}"
    else
      printf 'candidate: %s\n' "${release}"
    fi
  done
else
  echo "No rollback candidates available."
fi
echo

echo "== Safe rollout checklist =="
printf '%s\n' "1. Verify artifact checksum/signature before staging."
printf '%s\n' "2. Validate configuration in the candidate release."
printf '%s\n' "3. Record current symlink target and backup prerequisites."
printf '%s\n' "4. Switch current symlink only with explicit confirmation in a protected script."
printf '%s\n' "5. Run bounded health checks and keep rollback candidate available."
printf '%s\n' "6. Clean old releases only after successful validation and separate approval."
