#!/usr/bin/env bash
set -euo pipefail

BACKUP_PATH="${1:-${BACKUP_PATH:-}}"
MANIFEST_FILE="${2:-${MANIFEST_FILE:-}}"
LIMIT="${LIMIT:-50}"

if [[ -z "${BACKUP_PATH}" ]]; then
  echo "请设置 BACKUP_PATH or pass a backup file/directory path to verify.（Set BACKUP_PATH or pass a backup file/directory path to verify.）" >&2
  exit 2
fi

if [[ ! -e "${BACKUP_PATH}" ]]; then
  echo "Backup path 未找到: ${BACKUP_PATH}（Backup path not found: ${BACKUP_PATH}）" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

echo "信息：Backup verification summary"
echo "信息：Backup path: ${BACKUP_PATH}"
echo "信息：Manifest file: ${MANIFEST_FILE:-<none>}"
echo "信息：This script is read-only and does not prune, delete, or repair backups."
echo

echo "信息：== Path summary =="
if [[ -d "${BACKUP_PATH}" ]]; then
  find "${BACKUP_PATH}" -xdev -type f -print 2>/dev/null | awk -v limit="${LIMIT}" '
    NR <= limit { print }
    END { printf "files_seen=%d\n", NR }
  '
  if command -v du >/dev/null 2>&1; then
    du -sh "${BACKUP_PATH}" 2>/dev/null || true
  fi
else
  ls -lh "${BACKUP_PATH}" || true
fi
echo

if [[ -n "${MANIFEST_FILE}" ]]; then
  if [[ ! -f "${MANIFEST_FILE}" ]]; then
    echo "Manifest file 未找到: ${MANIFEST_FILE}（Manifest file not found: ${MANIFEST_FILE}）" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD="sha256sum -c"
  elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum -a 256 -c"
  else
    echo "信息：No sha256 manifest checker found (sha256sum or shasum required)." >&2
    exit 1
  fi
  echo "信息：== SHA-256 manifest verification =="
  echo "信息：Command: ${HASH_CMD} ${MANIFEST_FILE}"
  (cd "$(dirname "${MANIFEST_FILE}")" && ${HASH_CMD} "$(basename "${MANIFEST_FILE}")")
elif [[ -f "${BACKUP_PATH}" ]]; then
  echo "信息：== SHA-256 digest =="
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${BACKUP_PATH}"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${BACKUP_PATH}"
  else
    echo "信息：No sha256 tool found (sha256sum or shasum required)."
  fi
else
  echo "信息：No manifest provided. Directory listing and size summary completed only."
fi
