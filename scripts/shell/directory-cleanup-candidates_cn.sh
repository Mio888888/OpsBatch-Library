#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-${TARGET_DIR:-.}}"
OLDER_THAN_DAYS="${2:-${OLDER_THAN_DAYS:-30}}"
LIMIT="${3:-${LIMIT:-50}}"

if [[ ! "${OLDER_THAN_DAYS}" =~ ^[0-9]+$ ]]; then
  echo "信息：OLDER_THAN_DAYS 必须是非负整数。" >&2
  exit 2
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "目标目录未找到: ${TARGET_DIR}" >&2
  exit 1
fi

echo "信息：目录维护候选报告"
echo "信息：目标目录: ${TARGET_DIR}"
echo "信息：Older than days: ${OLDER_THAN_DAYS}"
echo "信息：Display limit: ${LIMIT}"
echo "信息：本脚本为只读，不会删除文件。"
echo

echo "信息：== Filesystem usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_DIR}" || true
else
  echo "df command 不可用."
fi
echo

echo "信息：== 目录大小 =="
if command -v du >/dev/null 2>&1; then
  du -sh "${TARGET_DIR}" 2>/dev/null || echo "信息：无法汇总 ${TARGET_DIR}；权限可能受限。"
else
  echo "du command 不可用."
fi
echo

CANDIDATE_COUNT="$(find "${TARGET_DIR}" -xdev -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null | wc -l | tr -d ' ')" || CANDIDATE_COUNT="未知"
echo "信息：== Stale file candidates =="
echo "信息：候选数量: ${CANDIDATE_COUNT}"
echo "正在显示最多 ${LIMIT} 个候选路径:"
find "${TARGET_DIR}" -xdev -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print }'
echo

echo "信息：== Largest direct children =="
if command -v du >/dev/null 2>&1; then
  find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth 1 -print 2>/dev/null | while IFS= read -r child; do
    du -sh "${child}" 2>/dev/null || true
  done | sort -hr 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print }' || true
else
  echo "du command 不可用."
fi
