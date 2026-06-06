#!/usr/bin/env bash
set -euo pipefail

LOAD_WARN="${1:-${LOAD_WARN:-2.0}}"
LOAD_CRIT="${2:-${LOAD_CRIT:-4.0}}"
NORMALIZE_PER_CPU="${3:-${NORMALIZE_PER_CPU:-true}}"

is_number() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

compare_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'
}

unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

if ! is_number "${LOAD_WARN}" || ! is_number "${LOAD_CRIT}"; then
  unknown "LOAD_WARN and LOAD_CRIT must be numeric"
fi
if [[ "${NORMALIZE_PER_CPU}" != "true" && "${NORMALIZE_PER_CPU}" != "false" ]]; then
  unknown "NORMALIZE_PER_CPU must be true or false"
fi
if ! awk -v warn="${LOAD_WARN}" -v crit="${LOAD_CRIT}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "LOAD_WARN must be less than or equal to LOAD_CRIT"
fi

load_one=""
case "$(uname -s)" in
  Linux)
    if [[ -r /proc/loadavg ]]; then
      load_one="$(awk '{print $1}' /proc/loadavg)"
    fi
    ;;
  Darwin)
    if command -v sysctl >/dev/null 2>&1; then
      load_one="$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')"
    fi
    ;;
  *)
    ;;
esac

if [[ -z "${load_one}" ]] && command -v uptime >/dev/null 2>&1; then
  load_one="$(uptime | awk -F'load averages?: ' '{if (NF > 1) {split($2, a, /[, ]+/); print a[1]}}')"
fi

if [[ -z "${load_one}" ]] || ! is_number "${load_one}"; then
  unknown "could not determine 1-minute load average"
fi

cpu_count="1"
if command -v getconf >/dev/null 2>&1; then
  cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
elif command -v sysctl >/dev/null 2>&1; then
  cpu_count="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)"
fi
if ! [[ "${cpu_count}" =~ ^[1-9][0-9]*$ ]]; then
  cpu_count="1"
fi

value="${load_one}"
metric_label="1-minute load"
if [[ "${NORMALIZE_PER_CPU}" == "true" ]]; then
  value="$(awk -v load="${load_one}" -v cpus="${cpu_count}" 'BEGIN { printf "%.2f", load / cpus }')"
  metric_label="1-minute load per CPU"
fi

status="OK"
exit_code=0
if compare_ge "${value}" "${LOAD_CRIT}"; then
  status="CRITICAL"
  exit_code=2
elif compare_ge "${value}" "${LOAD_WARN}"; then
  status="WARNING"
  exit_code=1
fi

echo "${status} - ${metric_label}=${value} raw_load=${load_one} cpus=${cpu_count} warn=${LOAD_WARN} crit=${LOAD_CRIT}"
echo "Details: NORMALIZE_PER_CPU=${NORMALIZE_PER_CPU}; read-only load inspection only."
exit "${exit_code}"
