#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-${TARGET_DIR:-.}}"
OLDER_THAN_DAYS="${2:-${OLDER_THAN_DAYS:-30}}"
LIMIT="${3:-${LIMIT:-50}}"

if [[ ! "${OLDER_THAN_DAYS}" =~ ^[0-9]+$ ]]; then
  echo "OLDER_THAN_DAYS must be a non-negative integer." >&2
  exit 2
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target directory not found: ${TARGET_DIR}" >&2
  exit 1
fi

echo "Directory maintenance candidate report"
echo "Target directory: ${TARGET_DIR}"
echo "Older than days: ${OLDER_THAN_DAYS}"
echo "Display limit: ${LIMIT}"
echo "This script is read-only and does not delete files."
echo

echo "== Filesystem usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_DIR}" || true
else
  echo "df command not available."
fi
echo

echo "== Directory size =="
if command -v du >/dev/null 2>&1; then
  du -sh "${TARGET_DIR}" 2>/dev/null || echo "Unable to summarize ${TARGET_DIR}; permissions may be restricted."
else
  echo "du command not available."
fi
echo

CANDIDATE_COUNT="$(find "${TARGET_DIR}" -xdev -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null | wc -l | tr -d ' ')" || CANDIDATE_COUNT="unknown"
echo "== Stale file candidates =="
echo "Candidate count: ${CANDIDATE_COUNT}"
echo "Showing up to ${LIMIT} candidate paths:"
find "${TARGET_DIR}" -xdev -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print }'
echo

echo "== Largest direct children =="
if command -v du >/dev/null 2>&1; then
  find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth 1 -print 2>/dev/null | while IFS= read -r child; do
    du -sh "${child}" 2>/dev/null || true
  done | sort -hr 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print }' || true
else
  echo "du command not available."
fi
