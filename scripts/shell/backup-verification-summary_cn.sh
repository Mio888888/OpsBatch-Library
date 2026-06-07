#!/usr/bin/env bash
set -euo pipefail

BACKUP_PATH="${1:-${BACKUP_PATH:-}}"
MANIFEST_FILE="${2:-${MANIFEST_FILE:-}}"
LIMIT="${LIMIT:-50}"

if [[ -z "${BACKUP_PATH}" ]]; then
  echo "请设置 BACKUP_PATH，或传入要验证的备份文件/目录路径。" >&2
  exit 2
fi

if [[ ! -e "${BACKUP_PATH}" ]]; then
  echo "备份路径未找到: ${BACKUP_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：Backup verification summary"
echo "信息：备份路径: ${BACKUP_PATH}"
echo "信息：Manifest file: ${MANIFEST_FILE:-<无>}"
echo "信息：本脚本为只读，不会清理、删除或修复备份。"
echo

echo "信息：== 路径摘要 =="
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
    echo "清单文件未找到: ${MANIFEST_FILE}" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD="sha256sum -c"
  elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum -a 256 -c"
  else
    echo "信息：未找到 sha256 清单校验工具（需要 sha256sum 或 shasum）。" >&2
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
    echo "信息：未找到 sha256 工具（需要 sha256sum 或 shasum）。"
  fi
else
  echo "信息：未提供清单文件。仅完成目录列表和大小摘要。"
fi
