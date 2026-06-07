#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-${TARGET_DIR:-}}"
OLDER_THAN_DAYS="${2:-${OLDER_THAN_DAYS:-7}}"
CONFIRM_DELETE="${3:-${CONFIRM_DELETE:-}}"
MAX_DEPTH="${4:-${MAX_DEPTH:-2}}"
LIMIT="${LIMIT:-50}"
CONFIRM_TOKEN="DELETE_TEMP_CANDIDATES"

if [[ -z "${TARGET_DIR}" ]]; then
  echo "请设置 TARGET_DIR，或传入要列出临时/过期清理候选的目标目录。"
  echo "信息：没有删除任何文件。"
  exit 0
fi

if [[ ! "${OLDER_THAN_DAYS}" =~ ^[0-9]+$ ]]; then
  echo "信息：OLDER_THAN_DAYS 必须是非负整数。" >&2
  exit 2
fi

if [[ ! "${MAX_DEPTH}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：MAX_DEPTH 必须是正整数。" >&2
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

case "${TARGET_DIR}" in
  /|/bin|/sbin|/usr|/usr/bin|/usr/sbin|/System|/System/*)
    echo "信息：拒绝操作过宽或系统关键目录: ${TARGET_DIR}" >&2
    exit 2
    ;;
esac

list_candidates() {
  find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth "${MAX_DEPTH}" -type f -mtime +"${OLDER_THAN_DAYS}" -print 2>/dev/null
}

CANDIDATE_COUNT="$(list_candidates | wc -l | tr -d ' ')" || CANDIDATE_COUNT="未知"

echo "受保护的临时/过期文件清理计划"
echo "信息：目标目录: ${TARGET_DIR}"
echo "信息：Older than days: ${OLDER_THAN_DAYS}"
echo "信息：Max search depth: ${MAX_DEPTH}"
echo "信息：候选数量: ${CANDIDATE_COUNT}"
echo "正在显示最多 ${LIMIT} candidates:"
list_candidates | awk -v limit="${LIMIT}" 'NR <= limit { print }'
echo

if [[ "${CONFIRM_DELETE}" != "${CONFIRM_TOKEN}" ]]; then
  echo "仅试运行。 没有删除任何文件。"
  echo "信息：要交互式删除候选项，请重新运行并设置 CONFIRM_DELETE=${CONFIRM_TOKEN}."
  exit 0
fi

echo "信息：确认令牌已接受。正在使用 rm -i 交互式删除候选项。"
while IFS= read -r -d '' candidate; do
  rm -i "${candidate}"
done < <(find "${TARGET_DIR}" -xdev -mindepth 1 -maxdepth "${MAX_DEPTH}" -type f -mtime +"${OLDER_THAN_DAYS}" -print0 2>/dev/null)
