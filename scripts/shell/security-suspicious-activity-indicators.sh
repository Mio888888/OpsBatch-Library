#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="${1:-${LOG_PATH:-}}"
LIMIT="${LIMIT:-25}"
SINCE_MINUTES="${SINCE_MINUTES:-1440}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ ! "${SINCE_MINUTES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "SINCE_MINUTES must be a positive integer." >&2
  exit 2
fi

if [[ -n "${LOG_PATH}" && ! -r "${LOG_PATH}" ]]; then
  echo "LOG_PATH is not readable: ${LOG_PATH}" >&2
  exit 1
fi

echo "Security suspicious activity indicators"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Log path: ${LOG_PATH:-<auto>}"
echo "This script is read-only. Output may contain usernames, IPs, process names, and paths."
echo

echo "== Processes executing from temporary paths =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,user,etime,command 2>/dev/null | awk '/\/tmp\/|\/var\/tmp\/|\/private\/tmp\// { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "temp_path_processes_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
      ;;
    *)
      ps -eo pid,ppid,user,etimes,args 2>/dev/null | awk '/\/tmp\/|\/var\/tmp\/|\/dev\/shm\// { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "temp_path_processes_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
      ;;
  esac
else
  echo "ps command not available."
fi
echo

echo "== Listening and established connection sample =="
if command -v ss >/dev/null 2>&1; then
  ss -tunap 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -i 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN|ESTABLISHED/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
else
  echo "No supported network connection command found."
fi
echo

echo "== Deleted-open-file hints =="
if command -v lsof >/dev/null 2>&1; then
  lsof +L1 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR == 0) print "No deleted-open-file output or permission denied."; if (NR > limit + 1) print "...output truncated..." }' || true
else
  echo "lsof not available."
fi
echo

echo "== Authentication log summary =="
if [[ -n "${LOG_PATH}" ]]; then
  tail -n "$((LIMIT * 20))" "${LOG_PATH}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
elif [[ "${OS_NAME}" == "Linux" ]] && command -v journalctl >/dev/null 2>&1; then
  journalctl --since "${SINCE_MINUTES} minutes ago" -u ssh -u sshd --no-pager 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
else
  for candidate in /var/log/auth.log /var/log/secure /var/log/system.log; do
    if [[ -r "${candidate}" ]]; then
      echo "Using ${candidate}"
      tail -n "$((LIMIT * 20))" "${candidate}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
      break
    fi
  done
fi
