#!/usr/bin/env bash
set -euo pipefail

MEM_WARN="${1:-${MEM_WARN:-80}}"
MEM_CRIT="${2:-${MEM_CRIT:-90}}"
SWAP_WARN="${3:-${SWAP_WARN:-50}}"
SWAP_CRIT="${4:-${SWAP_CRIT:-80}}"

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

for value in "${MEM_WARN}" "${MEM_CRIT}" "${SWAP_WARN}" "${SWAP_CRIT}"; do
  if ! is_percent "${value}"; then
    unknown "thresholds must be numeric percentages between 0 and 100"
  fi
done
if ! awk -v warn="${MEM_WARN}" -v crit="${MEM_CRIT}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "MEM_WARN must be less than or equal to MEM_CRIT"
fi
if ! awk -v warn="${SWAP_WARN}" -v crit="${SWAP_CRIT}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "SWAP_WARN must be less than or equal to SWAP_CRIT"
fi

mem_used_pct=""
swap_used_pct="0"
mem_detail=""
swap_detail=""

case "$(uname -s)" in
  Linux)
    if [[ -r /proc/meminfo ]]; then
      mem_total="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
      mem_available="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"
      swap_total="$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)"
      swap_free="$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)"
      if [[ -n "${mem_total}" && -n "${mem_available}" && "${mem_total}" -gt 0 ]]; then
        mem_used_pct="$(awk -v total="${mem_total}" -v avail="${mem_available}" 'BEGIN { printf "%.1f", ((total - avail) / total) * 100 }')"
        mem_detail="MemTotal=${mem_total}KiB MemAvailable=${mem_available}KiB"
      fi
      if [[ -n "${swap_total}" && "${swap_total}" -gt 0 ]]; then
        swap_used_pct="$(awk -v total="${swap_total}" -v free="${swap_free}" 'BEGIN { printf "%.1f", ((total - free) / total) * 100 }')"
        swap_detail="SwapTotal=${swap_total}KiB SwapFree=${swap_free}KiB"
      else
        swap_detail="SwapTotal=0KiB"
      fi
    fi
    ;;
  Darwin)
    if command -v vm_stat >/dev/null 2>&1 && command -v sysctl >/dev/null 2>&1; then
      page_size="$(vm_stat | awk '/page size of/ {print $8}' | tr -d '.')"
      total_bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
      free_pages="$(vm_stat | awk -F: '/Pages free/ {gsub(/[^0-9]/, "", $2); print $2}')"
      inactive_pages="$(vm_stat | awk -F: '/Pages inactive/ {gsub(/[^0-9]/, "", $2); print $2}')"
      speculative_pages="$(vm_stat | awk -F: '/Pages speculative/ {gsub(/[^0-9]/, "", $2); print $2}')"
      page_size="${page_size:-4096}"
      free_pages="${free_pages:-0}"
      inactive_pages="${inactive_pages:-0}"
      speculative_pages="${speculative_pages:-0}"
      if [[ "${total_bytes}" -gt 0 ]]; then
        mem_used_pct="$(awk -v total="${total_bytes}" -v ps="${page_size}" -v free="${free_pages}" -v inactive="${inactive_pages}" -v speculative="${speculative_pages}" 'BEGIN { available=(free+inactive+speculative)*ps; used=total-available; if (used < 0) used=0; printf "%.1f", (used/total)*100 }')"
        mem_detail="MemTotal=${total_bytes}B approximate_available_from_vm_stat"
      fi
      swap_line="$(sysctl -n vm.swapusage 2>/dev/null || true)"
      if [[ -n "${swap_line}" ]]; then
        swap_used_mb="$(printf '%s\n' "${swap_line}" | awk '{for (i=1; i<=NF; i++) if ($i == "used") {value=$(i+2); gsub(/M/, "", value); print value}}')"
        swap_total_mb="$(printf '%s\n' "${swap_line}" | awk '{for (i=1; i<=NF; i++) if ($i == "total") {value=$(i+2); gsub(/M/, "", value); print value}}')"
        if [[ -n "${swap_used_mb}" && -n "${swap_total_mb}" ]] && awk -v t="${swap_total_mb}" 'BEGIN { exit (t > 0) ? 0 : 1 }'; then
          swap_used_pct="$(awk -v used="${swap_used_mb}" -v total="${swap_total_mb}" 'BEGIN { printf "%.1f", (used/total)*100 }')"
          swap_detail="${swap_line}"
        else
          swap_used_pct="0"
          swap_detail="${swap_line}"
        fi
      fi
    fi
    ;;
  *)
    ;;
esac

if [[ -z "${mem_used_pct}" ]]; then
  unknown "could not determine memory usage on this platform"
fi

status="OK"
exit_code=0
reasons=()
if compare_ge "${mem_used_pct}" "${MEM_CRIT}"; then
  status="CRITICAL"
  exit_code=2
  reasons+=("memory=${mem_used_pct}%>=${MEM_CRIT}%")
elif compare_ge "${mem_used_pct}" "${MEM_WARN}"; then
  status="WARNING"
  exit_code=1
  reasons+=("memory=${mem_used_pct}%>=${MEM_WARN}%")
fi

if compare_ge "${swap_used_pct}" "${SWAP_CRIT}"; then
  status="CRITICAL"
  exit_code=2
  reasons+=("swap=${swap_used_pct}%>=${SWAP_CRIT}%")
elif [[ "${exit_code}" -lt 2 ]] && compare_ge "${swap_used_pct}" "${SWAP_WARN}"; then
  status="WARNING"
  exit_code=1
  reasons+=("swap=${swap_used_pct}%>=${SWAP_WARN}%")
fi

reason_text="within thresholds"
if [[ ${#reasons[@]} -gt 0 ]]; then
  reason_text="$(IFS=', '; echo "信息：${reasons[*]}")"
fi

echo "信息：${status} - memory_used=${mem_used_pct}% swap_used=${swap_used_pct}% (${reason_text})"
echo "信息：Memory detail: ${mem_detail}"
echo "Swap detail: ${swap_detail:-不可用 or not configured}（Swap detail: ${swap_detail:-not available or not configured}）"
exit "${exit_code}"
