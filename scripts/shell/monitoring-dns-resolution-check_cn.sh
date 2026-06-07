#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${1:-${TARGET_HOST:-example.com}}"
DNS_SERVER="${2:-${DNS_SERVER:-}}"
TIMEOUT_SECONDS="${3:-${TIMEOUT_SECONDS:-5}}"
LATENCY_WARN_MS="${4:-${LATENCY_WARN_MS:-500}}"
LATENCY_CRIT_MS="${5:-${LATENCY_CRIT_MS:-1000}}"

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

is_nonnegative_number() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

compare_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'
}

now_ms() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import time; print(int(time.time() * 1000))'
  else
    awk -v seconds="$(date +%s)" 'BEGIN { printf "%.0f", seconds * 1000 }'
  fi
}

unknown() {
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ -z "${TARGET_HOST}" ]]; then
  unknown "TARGET_HOST must not be empty"
fi
if [[ "${TARGET_HOST}" == -* || "${DNS_SERVER}" == -* ]]; then
  unknown "TARGET_HOST and DNS_SERVER must not start with '-'"
fi
if ! is_positive_int "${TIMEOUT_SECONDS}" || ! is_nonnegative_number "${LATENCY_WARN_MS}" || ! is_nonnegative_number "${LATENCY_CRIT_MS}"; then
  unknown "timeout and latency thresholds must be numeric"
fi
if [[ "${TIMEOUT_SECONDS}" -gt 30 ]]; then
  unknown "为保证 DNS 探测有界，TIMEOUT_SECONDS 必须不超过 30"
fi
if ! awk -v warn="${LATENCY_WARN_MS}" -v crit="${LATENCY_CRIT_MS}" 'BEGIN { exit (warn <= crit) ? 0 : 1 }'; then
  unknown "LATENCY_WARN_MS must be less than or equal to LATENCY_CRIT_MS"
fi

start_ms="$(now_ms)"
answers=""
method=""

if command -v dig >/dev/null 2>&1; then
  method="dig"
  server_arg=()
  if [[ -n "${DNS_SERVER}" ]]; then
    server_arg=("@${DNS_SERVER}")
  fi
  answers="$(dig +time="${TIMEOUT_SECONDS}" +tries=1 +short "${server_arg[@]}" "${TARGET_HOST}" A 2>/dev/null | head -n 5 || true)"
elif command -v nslookup >/dev/null 2>&1; then
  method="nslookup"
  if [[ -n "${DNS_SERVER}" ]]; then
    answers="$(nslookup "${TARGET_HOST}" "${DNS_SERVER}" 2>/dev/null | awk '/^Name:/ {found=1} found && /^Address: / {print $2}' | head -n 5 || true)"
  else
    answers="$(nslookup "${TARGET_HOST}" 2>/dev/null | awk '/^Name:/ {found=1} found && /^Address: / {print $2}' | head -n 5 || true)"
  fi
elif command -v host >/dev/null 2>&1; then
  method="host"
  if [[ -n "${DNS_SERVER}" ]]; then
    answers="$(host "${TARGET_HOST}" "${DNS_SERVER}" 2>/dev/null | awk '/has address/ {print $4}' | head -n 5 || true)"
  else
    answers="$(host "${TARGET_HOST}" 2>/dev/null | awk '/has address/ {print $4}' | head -n 5 || true)"
  fi
elif command -v getent >/dev/null 2>&1; then
  method="getent"
  answers="$(getent hosts "${TARGET_HOST}" 2>/dev/null | awk '{print $1}' | head -n 5 || true)"
else
  unknown "dig, nslookup, host, or getent is required"
fi

end_ms="$(now_ms)"
elapsed_ms="$(awk -v start="${start_ms}" -v end="${end_ms}" 'BEGIN { printf "%.0f", end - start }')"

if [[ -z "${answers}" ]]; then
  echo "信息：CRITICAL - dns ${TARGET_HOST} 使用 ${method} 未返回 A 记录"
  exit 2
fi

status="OK"
exit_code=0
reason="resolved"
if compare_ge "${elapsed_ms}" "${LATENCY_CRIT_MS}"; then
  status="CRITICAL"
  exit_code=2
  reason="latency=${elapsed_ms}ms>=${LATENCY_CRIT_MS}ms"
elif compare_ge "${elapsed_ms}" "${LATENCY_WARN_MS}"; then
  status="WARNING"
  exit_code=1
  reason="latency=${elapsed_ms}ms>=${LATENCY_WARN_MS}ms"
fi

echo "信息：${status} - dns ${TARGET_HOST} answers=$(printf '%s' "${answers}" | wc -l | tr -d ' ') latency=${elapsed_ms}ms (${reason})"
echo "信息：Resolver: ${DNS_SERVER:-system default}; method=${method}; timeout=${TIMEOUT_SECONDS}s"
echo "信息：Sample answers:"
printf '%s\n' "${answers}"
exit "${exit_code}"
