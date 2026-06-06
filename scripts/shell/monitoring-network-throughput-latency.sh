#!/usr/bin/env bash
set -euo pipefail

INTERFACE="${1:-${INTERFACE:-}}"
SAMPLE_INTERVAL="${2:-${SAMPLE_INTERVAL:-1}}"
PING_HOST="${3:-${PING_HOST:-example.com}}"
PING_COUNT="${4:-${PING_COUNT:-3}}"
LATENCY_WARN_MS="${5:-${LATENCY_WARN_MS:-100}}"
LATENCY_CRIT_MS="${6:-${LATENCY_CRIT_MS:-300}}"

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

is_nonnegative_number() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

compare_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'
}

unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

if ! is_positive_int "${SAMPLE_INTERVAL}" || [[ "${SAMPLE_INTERVAL}" -gt 10 ]]; then
  unknown "SAMPLE_INTERVAL must be an integer between 1 and 10"
fi
if ! is_positive_int "${PING_COUNT}" || [[ "${PING_COUNT}" -gt 10 ]]; then
  unknown "PING_COUNT must be an integer between 1 and 10"
fi
if ! is_nonnegative_number "${LATENCY_WARN_MS}" || ! is_nonnegative_number "${LATENCY_CRIT_MS}"; then
  unknown "latency thresholds must be numeric"
fi
if [[ -n "${PING_HOST}" ]] && [[ "${PING_HOST}" == -* ]]; then
  unknown "PING_HOST must not start with '-'"
fi
if ! awk -v warn="${LATENCY_WARN_MS}" -v crit="${LATENCY_CRIT_MS}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "LATENCY_WARN_MS must be less than or equal to LATENCY_CRIT_MS"
fi

pick_default_interface() {
  case "$(uname -s)" in
    Linux)
      awk -F: 'NR > 2 {gsub(/ /, "", $1); if ($1 != "lo") {print $1; exit}}' /proc/net/dev 2>/dev/null || true
      ;;
    Darwin)
      netstat -ib 2>/dev/null | awk 'NR > 1 && $1 != "lo0" {print $1; exit}' || true
      ;;
    *)
      ;;
  esac
}

read_bytes() {
  local iface="$1"
  case "$(uname -s)" in
    Linux)
      awk -F'[: ]+' -v iface="${iface}" '$2 == iface {print $3, $11}' /proc/net/dev 2>/dev/null
      ;;
    Darwin)
      netstat -ib 2>/dev/null | awk -v iface="${iface}" '$1 == iface {rx+=$7; tx+=$10} END {if (rx != "" || tx != "") print rx+0, tx+0}'
      ;;
    *)
      return 1
      ;;
  esac
}

if [[ -z "${INTERFACE}" ]]; then
  INTERFACE="$(pick_default_interface)"
fi
if [[ -z "${INTERFACE}" ]]; then
  unknown "could not determine a network interface"
fi

first="$(read_bytes "${INTERFACE}" || true)"
if [[ -z "${first}" ]]; then
  unknown "could not read byte counters for interface ${INTERFACE}"
fi
rx1="$(awk '{print $1}' <<<"${first}")"
tx1="$(awk '{print $2}' <<<"${first}")"
sleep "${SAMPLE_INTERVAL}"
second="$(read_bytes "${INTERFACE}" || true)"
if [[ -z "${second}" ]]; then
  unknown "could not read second byte sample for interface ${INTERFACE}"
fi
rx2="$(awk '{print $1}' <<<"${second}")"
tx2="$(awk '{print $2}' <<<"${second}")"

rx_bps="$(awk -v a="${rx1}" -v b="${rx2}" -v interval="${SAMPLE_INTERVAL}" 'BEGIN { delta=b-a; if (delta < 0) delta=0; printf "%.0f", delta/interval }')"
tx_bps="$(awk -v a="${tx1}" -v b="${tx2}" -v interval="${SAMPLE_INTERVAL}" 'BEGIN { delta=b-a; if (delta < 0) delta=0; printf "%.0f", delta/interval }')"

latency_ms=""
packet_loss="unknown"
if command -v ping >/dev/null 2>&1 && [[ -n "${PING_HOST}" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ping_output="$(ping -c "${PING_COUNT}" -W 1000 "${PING_HOST}" 2>/dev/null || true)"
  else
    ping_output="$(ping -c "${PING_COUNT}" -W 1 "${PING_HOST}" 2>/dev/null || true)"
  fi
  packet_loss="$(printf '%s\n' "${ping_output}" | awk -F', ' '/packet loss/ {for (i=1; i<=NF; i++) if ($i ~ /packet loss/) {gsub(/% packet loss/, "", $i); print $i}}')"
  latency_ms="$(printf '%s\n' "${ping_output}" | awk -F'=' '/(round-trip|rtt)/ {split($2, values, "/"); gsub(/^ /, "", values[2]); print values[2]}')"
fi

status="OK"
exit_code=0
reason="network sample collected"
if [[ -n "${latency_ms}" ]]; then
  if compare_ge "${latency_ms}" "${LATENCY_CRIT_MS}"; then
    status="CRITICAL"
    exit_code=2
    reason="latency=${latency_ms}ms>=${LATENCY_CRIT_MS}ms"
  elif compare_ge "${latency_ms}" "${LATENCY_WARN_MS}"; then
    status="WARNING"
    exit_code=1
    reason="latency=${latency_ms}ms>=${LATENCY_WARN_MS}ms"
  fi
else
  status="WARNING"
  exit_code=1
  reason="latency unavailable; throughput sample only"
fi

echo "${status} - interface=${INTERFACE} rx=${rx_bps}B/s tx=${tx_bps}B/s ping_host=${PING_HOST} latency=${latency_ms:-unknown}ms loss=${packet_loss:-unknown}% (${reason})"
echo "Details: sampled byte counters for ${SAMPLE_INTERVAL}s; ping count=${PING_COUNT}; no packet capture or interface changes."
exit "${exit_code}"
