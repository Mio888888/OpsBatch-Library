#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="${1:-${LOG_PATH:-}}"
LIMIT="${LIMIT:-25}"
SINCE_MINUTES="${SINCE_MINUTES:-1440}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ ! "${SINCE_MINUTES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：SINCE_MINUTES must be a positive integer." >&2
  exit 2
fi

if [[ -n "${LOG_PATH}" && ! -r "${LOG_PATH}" ]]; then
  echo "信息：LOG_PATH is not readable: ${LOG_PATH}" >&2
  exit 1
fi

echo "信息：Security suspicious activity indicators"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Host: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Log path: ${LOG_PATH:-<auto>}"
echo "信息：This script is read-only. Output may contain usernames, IPs, process names, and paths."
echo

echo "信息：== Processes executing from temporary paths =="
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
  echo "ps command 不可用.（ps command not available.）"
fi
echo

echo "信息：== Listening and established connection sample =="
if command -v ss >/dev/null 2>&1; then
  ss -tunap 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -i 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN|ESTABLISHED/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
else
  echo "未找到受支持的 network connection command found.（No supported network connection command found.）"
fi
echo

echo "信息：== Deleted-open-file hints =="
if command -v lsof >/dev/null 2>&1; then
  lsof +L1 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR == 0) print "No deleted-open-file output or permission denied."; if (NR > limit + 1) print "...output truncated..." }' || true
else
  echo "lsof 不可用.（lsof not available.）"
fi
echo

echo "信息：== Authentication log summary =="
if [[ -n "${LOG_PATH}" ]]; then
  tail -n "$((LIMIT * 20))" "${LOG_PATH}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
elif [[ "${OS_NAME}" == "Linux" ]] && command -v journalctl >/dev/null 2>&1; then
  journalctl --since "${SINCE_MINUTES} minutes ago" -u ssh -u sshd --no-pager 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
else
  for candidate in /var/log/auth.log /var/log/secure /var/log/system.log; do
    if [[ -r "${candidate}" ]]; then
      echo "信息：Using ${candidate}"
      tail -n "$((LIMIT * 20))" "${candidate}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
      break
    fi
  done
fi
