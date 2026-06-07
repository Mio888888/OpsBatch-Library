#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-${TARGET_DIR:-}}"
OLDER_THAN_DAYS="${2:-${OLDER_THAN_DAYS:-7}}"
CONFIRM_DELETE="${3:-${CONFIRM_DELETE:-}}"
MAX_DEPTH="${4:-${MAX_DEPTH:-2}}"
LIMIT="${LIMIT:-50}"
CONFIRM_TOKEN="DELETE_TEMP_CANDIDATES"

if [[ -z "${TARGET_DIR}" ]]; then
  echo "请设置 TARGET_DIR or pass a target directory to list temporary/stale cleanup candidates.（Set TARGET_DIR or pass a target directory to list temporary/stale cleanup candidates.）"
  echo "信息：No files were deleted."
  exit 0
fi

if [[ ! "${OLDER_THAN_DAYS}" =~ ^[0-9]+$ ]]; then
  echo "信息：OLDER_THAN_DAYS must be a non-negative integer." >&2
  exit 2
fi

if [[ ! "${MAX_DEPTH}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：MAX_DEPTH must be a positive integer." >&2
  exit 2
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target directory 未找到: ${TARGET_DIR}（Target directory not found: ${TARGET_DIR}）" >&2
  exit 1
fi

case "${TARGET_DIR}" in
  /|/bin|/sbin|/usr|/usr/bin|/usr/sbin|/System|/System/*)
    echo "信息：Refusing to operate on broad or system-critical directory: ${TARGET_DIR}" >&2
    exit 2
    ;;
esac

list_candidates() {
  find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth "${MAX_DEPTH}" -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null
}

CANDIDATE_COUNT="$(list_candidates | wc -l | tr -d ' ')" || CANDIDATE_COUNT="unknown"

echo "受保护 temp/stale-file cleanup plan（Protected temp/stale-file cleanup plan）"
echo "信息：Target directory: ${TARGET_DIR}"
echo "信息：Older than days: ${OLDER_THAN_DAYS}"
echo "信息：Max search depth: ${MAX_DEPTH}"
echo "信息：Candidate count: ${CANDIDATE_COUNT}"
echo "正在显示 up to ${LIMIT} candidates:（Showing up to ${LIMIT} candidates:）"
list_candidates | awk -v limit="${LIMIT}" 'NR <= limit { print }'
echo

if [[ "${CONFIRM_DELETE}" != "${CONFIRM_TOKEN}" ]]; then
  echo "仅试运行。 No files were deleted.（Dry-run only. No files were deleted.）"
  echo "信息：To delete candidates interactively, rerun with CONFIRM_DELETE=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：Confirmation token accepted. Deleting candidates interactively with rm -i."
while IFS= read -r -d '' candidate; do
  rm -i "${candidate}"
done < <(find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth "${MAX_DEPTH}" -type f -mtime +"${OLDER_THAN_DAYS}" -print0 2>/dev/null)
