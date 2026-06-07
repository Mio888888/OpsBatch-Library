#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${1:-${TARGET_HOST:-example.com}}"
TARGET_PORT="${2:-${TARGET_PORT:-443}}"
WARN_DAYS="${3:-${WARN_DAYS:-30}}"
CRIT_DAYS="${4:-${CRIT_DAYS:-7}}"
TIMEOUT_SECONDS="${5:-${TIMEOUT_SECONDS:-5}}"

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

unknown() {
  echo "信息：UNKNOWN - $1"
  exit 3
}

if [[ -z "${TARGET_HOST}" ]]; then
  unknown "TARGET_HOST must not be empty"
fi
if [[ "${TARGET_HOST}" == -* ]]; then
  unknown "TARGET_HOST must not start with '-'"
fi
if ! is_positive_int "${TARGET_PORT}" || [[ "${TARGET_PORT}" -gt 65535 ]]; then
  unknown "TARGET_PORT must be an integer between 1 and 65535"
fi
if ! is_positive_int "${WARN_DAYS}" || ! is_positive_int "${CRIT_DAYS}" || ! is_positive_int "${TIMEOUT_SECONDS}"; then
  unknown "WARN_DAYS, CRIT_DAYS, and TIMEOUT_SECONDS must be positive integers"
fi
if [[ "${TIMEOUT_SECONDS}" -gt 30 ]]; then
  unknown "TIMEOUT_SECONDS must be 30 or less for a bounded TLS probe"
fi
if [[ "${WARN_DAYS}" -lt "${CRIT_DAYS}" ]]; then
  unknown "WARN_DAYS must be greater than or equal to CRIT_DAYS"
fi
if ! command -v openssl >/dev/null 2>&1; then
  unknown "openssl command is required"
fi

run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT_SECONDS}" "$@"
  else
    "$@"
  fi
}

cert_text="$(run_with_timeout openssl s_client -servername "${TARGET_HOST}" -connect "${TARGET_HOST}:${TARGET_PORT}" -showcerts </dev/null 2>/dev/null | openssl x509 -noout -enddate -subject -issuer 2>/dev/null || true)"
if [[ -z "${cert_text}" ]]; then
  echo "信息：CRITICAL - tls ${TARGET_HOST}:${TARGET_PORT} certificate could not be read"
  exit 2
fi

not_after="$(printf '%s\n' "${cert_text}" | awk -F= '/^notAfter=/ {print substr($0, index($0, "=")+1)}')"
subject="$(printf '%s\n' "${cert_text}" | awk -F= '/^subject=/ {print substr($0, index($0, "=")+1)}')"
issuer="$(printf '%s\n' "${cert_text}" | awk -F= '/^issuer=/ {print substr($0, index($0, "=")+1)}')"

if [[ -z "${not_after}" ]]; then
  unknown "certificate notAfter field was not found"
fi

end_epoch=""
if date -u -d "${not_after}" +%s >/dev/null 2>&1; then
  end_epoch="$(date -u -d "${not_after}" +%s)"
elif date -u -j -f "%b %e %T %Y %Z" "${not_after}" +%s >/dev/null 2>&1; then
  end_epoch="$(date -u -j -f "%b %e %T %Y %Z" "${not_after}" +%s)"
fi
if [[ -z "${end_epoch}" ]]; then
  unknown "could not parse certificate expiry date: ${not_after}"
fi

now_epoch="$(date -u +%s)"
days_left="$(awk -v end="${end_epoch}" -v now="${now_epoch}" 'BEGIN { printf "%d", (end - now) / 86400 }')"

status="OK"
exit_code=0
if [[ "${days_left}" -lt 0 ]]; then
  status="CRITICAL"
  exit_code=2
elif [[ "${days_left}" -le "${CRIT_DAYS}" ]]; then
  status="CRITICAL"
  exit_code=2
elif [[ "${days_left}" -le "${WARN_DAYS}" ]]; then
  status="WARNING"
  exit_code=1
fi

echo "信息：${status} - tls ${TARGET_HOST}:${TARGET_PORT} expires_in=${days_left}d warn=${WARN_DAYS}d crit=${CRIT_DAYS}d"
echo "信息：Not after: ${not_after}"
echo "信息：Subject: ${subject:-unknown}"
echo "信息：Issuer: ${issuer:-unknown}"
exit "${exit_code}"
