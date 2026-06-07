#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
USAGE_WARN="${2:-${USAGE_WARN:-80}}"
USAGE_CRIT="${3:-${USAGE_CRIT:-90}}"
INODE_WARN="${4:-${INODE_WARN:-80}}"
INODE_CRIT="${5:-${INODE_CRIT:-90}}"

is_percent() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]] && awk -v n="$1" 'BEGIN { exit (n >= 0 && n <= 100) ? 0 : 1 }'
}

compare_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'
}

unknown() {
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ ! -e "${TARGET_PATH}" ]]; then
  unknown "target path does not exist: ${TARGET_PATH}"
fi
if [[ "${TARGET_PATH}" == -* ]]; then
  unknown "TARGET_PATH must not start with '-'"
fi

for value in "${USAGE_WARN}" "${USAGE_CRIT}" "${INODE_WARN}" "${INODE_CRIT}"; do
  if ! is_percent "${value}"; then
    unknown "thresholds must be numeric percentages between 0 and 100"
  fi
done
if ! awk -v warn="${USAGE_WARN}" -v crit="${USAGE_CRIT}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "USAGE_WARN must be less than or equal to USAGE_CRIT"
fi
if ! awk -v warn="${INODE_WARN}" -v crit="${INODE_CRIT}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "INODE_WARN must be less than or equal to INODE_CRIT"
fi

if ! command -v df >/dev/null 2>&1; then
  unknown "df command is not available"
fi

disk_line="$(df -P "${TARGET_PATH}" 2>/dev/null | awk 'NR==2 {print}')"
if [[ -z "${disk_line}" ]]; then
  unknown "could not read disk usage for ${TARGET_PATH}"
fi

filesystem="$(awk '{print $1}' <<<"${disk_line}")"
used_pct="$(awk '{gsub(/%/, "", $5); print $5}' <<<"${disk_line}")"
mount_point="$(awk '{print $6}' <<<"${disk_line}")"

inode_pct=""
inode_line="$(df -Pi "${TARGET_PATH}" 2>/dev/null | awk 'NR==2 {print}' || true)"
if [[ -n "${inode_line}" ]]; then
  inode_pct="$(awk '{gsub(/%/, "", $5); print $5}' <<<"${inode_line}")"
fi
if [[ -z "${inode_pct}" || "${inode_pct}" == "-" ]]; then
  inode_pct="0"
fi

status="OK"
exit_code=0
reasons=()
if compare_ge "${used_pct}" "${USAGE_CRIT}"; then
  status="CRITICAL"
  exit_code=2
  reasons+=("disk=${used_pct}%>=${USAGE_CRIT}%")
elif compare_ge "${used_pct}" "${USAGE_WARN}"; then
  status="WARNING"
  exit_code=1
  reasons+=("disk=${used_pct}%>=${USAGE_WARN}%")
fi

if compare_ge "${inode_pct}" "${INODE_CRIT}"; then
  status="CRITICAL"
  exit_code=2
  reasons+=("inode=${inode_pct}%>=${INODE_CRIT}%")
elif [[ "${exit_code}" -lt 2 ]] && compare_ge "${inode_pct}" "${INODE_WARN}"; then
  status="WARNING"
  exit_code=1
  reasons+=("inode=${inode_pct}%>=${INODE_WARN}%")
fi

reason_text="within thresholds"
if [[ ${#reasons[@]} -gt 0 ]]; then
  reason_text="$(IFS=', '; echo "信息：${reasons[*]}")"
fi

echo "信息：${status} - path=${TARGET_PATH} mount=${mount_point} disk_used=${used_pct}% inode_used=${inode_pct}% (${reason_text})"
echo "信息：Filesystem: ${filesystem}"
echo "信息：Disk detail:"
df -h "${TARGET_PATH}" || true
echo "信息：Inode detail:"
df -ih "${TARGET_PATH}" 2>/dev/null || df -Pi "${TARGET_PATH}" || true
exit "${exit_code}"
