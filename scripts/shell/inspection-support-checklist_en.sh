#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
OUTPUT_DIR="${2:-${OUTPUT_DIR:-}}"
LIMIT="${LIMIT:-25}"
OS_NAME="$(uname -s)"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "Target path not found: ${TARGET_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

echo "Inspection support checklist"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Target path: ${TARGET_PATH}"
echo "Output directory check: ${OUTPUT_DIR:-<not provided>}"
echo "This script is read-only and does not create support archives. Review all output before sharing."
echo

echo "== Preflight checklist =="
printf 'operator_context: collect incident/change ID separately; do not paste secrets into parameters\n'
printf 'platform: %s\n' "${OS_NAME}"
printf 'privilege: uid=%s user=%s\n' "$(id -u 2>/dev/null || echo unknown)" "$(id -un 2>/dev/null || echo unknown)"
if [[ -n "${OUTPUT_DIR}" ]]; then
  if [[ -d "${OUTPUT_DIR}" ]]; then
    printf 'output_dir: exists\n'
    if [[ -w "${OUTPUT_DIR}" ]]; then
      printf 'output_dir_writable: yes\n'
    else
      printf 'output_dir_writable: no\n'
    fi
  else
    printf 'output_dir: missing (no directory was created)\n'
  fi
fi
echo

echo "== Host summary =="
hostname 2>/dev/null || true
uname -a || true
if [[ "${OS_NAME}" == "Darwin" ]] && command -v sw_vers >/dev/null 2>&1; then
  sw_vers || true
elif [[ -r /etc/os-release ]]; then
  awk -F= '/^(PRETTY_NAME|NAME|VERSION)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
fi
echo

echo "== Capacity summary =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || true
fi
if command -v du >/dev/null 2>&1; then
  du -sh "${TARGET_PATH}" 2>/dev/null || echo "du summary unavailable for ${TARGET_PATH}."
fi
echo

echo "== Recent reboot or uptime context =="
if command -v uptime >/dev/null 2>&1; then
  uptime || true
fi
if command -v who >/dev/null 2>&1; then
  who -b 2>/dev/null || true
fi
echo

echo "== Tool availability for support collection =="
for tool in tar gzip zip sha256sum shasum openssl journalctl dmesg log show system_profiler sysctl lsof netstat ss ip ifconfig; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: available\n' "${tool}"
  else
    printf '%s: not available\n' "${tool}"
  fi
done
echo

echo "== Suggested bounded evidence topics =="
printf '%s\n' "1. OS/kernel and uptime summary"
printf '%s\n' "2. Disk capacity for the affected path"
printf '%s\n' "3. Service status for the affected service only"
printf '%s\n' "4. Recent application log excerpt with secrets redacted"
printf '%s\n' "5. Network listener/route summary if relevant"
printf '%s\n' "6. Package/version summary for affected components"
echo

echo "== Recent system log pointers =="
case "${OS_NAME}" in
  Linux)
    if command -v journalctl >/dev/null 2>&1; then
      journalctl --list-boots 2>/dev/null | tail -n "${LIMIT}" || true
    else
      for path in /var/log/syslog /var/log/messages /var/log/system.log; do
        if [[ -r "${path}" ]]; then
          printf 'readable_log: %s\n' "${path}"
        fi
      done
    fi
    ;;
  Darwin)
    if command -v log >/dev/null 2>&1; then
      echo "macOS unified log is available; use a narrow predicate/time window before collecting."
    fi
    ;;
  *)
    echo "No platform-specific log pointers for ${OS_NAME}."
    ;;
esac
