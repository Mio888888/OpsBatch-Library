#!/usr/bin/env bash
set -euo pipefail

MOUNT_PATH="${1:-${MOUNT_PATH:-/}}"
EXPECTED_TYPE="${2:-${EXPECTED_TYPE:-}}"
FAIL_IF_READONLY="${3:-${FAIL_IF_READONLY:-true}}"

unknown() {
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ ! -e "${MOUNT_PATH}" ]]; then
  unknown "path does not exist: ${MOUNT_PATH}"
fi
if [[ "${FAIL_IF_READONLY}" != "true" && "${FAIL_IF_READONLY}" != "false" ]]; then
  unknown "FAIL_IF_READONLY must be true or false"
fi
if [[ "${MOUNT_PATH}" == -* ]]; then
  unknown "MOUNT_PATH must not start with '-'"
fi

if ! command -v df >/dev/null 2>&1; then
  unknown "df 命令不可用"
fi

mount_point="$(df -P "${MOUNT_PATH}" 2>/dev/null | awk 'NR==2 {print $6}')"
filesystem="$(df -P "${MOUNT_PATH}" 2>/dev/null | awk 'NR==2 {print $1}')"
if [[ -z "${mount_point}" ]]; then
  unknown "无法确定 ${MOUNT_PATH} 的挂载点"
fi

fs_type="未知"
mount_options="未知"
case "$(uname -s)" in
  Linux)
    if command -v findmnt >/dev/null 2>&1; then
      fs_type="$(findmnt -n -T "${MOUNT_PATH}" -o FSTYPE 2>/dev/null || echo 未知)"
      mount_options="$(findmnt -n -T "${MOUNT_PATH}" -o OPTIONS 2>/dev/null || echo 未知)"
    else
      mount_record="$(awk -v mp="${mount_point}" '$2 == mp {print}' /proc/mounts 2>/dev/null | head -n 1 || true)"
      if [[ -n "${mount_record}" ]]; then
        fs_type="$(awk '{print $3}' <<<"${mount_record}")"
        mount_options="$(awk '{print $4}' <<<"${mount_record}")"
      fi
    fi
    ;;
  Darwin)
    mount_record="$(mount | awk -v mp="${mount_point}" '$0 ~ " on " mp " " {print; exit}' || true)"
    if [[ -n "${mount_record}" ]]; then
      fs_type="$(printf '%s\n' "${mount_record}" | awk -F'[()]' '{print $2}' | awk -F',' '{gsub(/^ /, "", $1); print $1}')"
      mount_options="$(printf '%s\n' "${mount_record}" | awk -F'[()]' '{print $2}')"
    fi
    ;;
  *)
    ;;
esac

status="OK"
exit_code=0
reasons=()

if [[ -n "${EXPECTED_TYPE}" && "${fs_type}" != "${EXPECTED_TYPE}" ]]; then
  status="WARNING"
  exit_code=1
  reasons+=("fstype=${fs_type} 预期=${EXPECTED_TYPE}")
fi

if [[ "${FAIL_IF_READONLY}" == "true" ]] && [[ ",${mount_options}," == *,ro,* ]]; then
  status="CRITICAL"
  exit_code=2
  reasons+=("mount is read-only")
fi

reason_text="mount present"
if [[ ${#reasons[@]} -gt 0 ]]; then
  reason_text="$(IFS=', '; echo "信息：${reasons[*]}")"
fi

echo "信息：${status} - path=${MOUNT_PATH} mount=${mount_point} fs=${filesystem} type=${fs_type} (${reason_text})"
echo "信息：Mount options: ${mount_options}"
echo "信息：Disk summary:"
df -h "${MOUNT_PATH}" || true
exit "${exit_code}"
