#!/usr/bin/env bash
set -euo pipefail

SERVICE_FILTER="${1:-${SERVICE_FILTER:-}}"
LIMIT="${LIMIT:-20}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

echo "Inspection process and service inventory"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Service filter: ${SERVICE_FILTER:-<none>}"
echo "This script is read-only. Process command lines and service names may be sensitive."
echo

echo "== Top CPU processes =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,%cpu,%mem,user,comm -r | head -n "$((LIMIT + 1))" || true
      ;;
    *)
      ps -eo pid,ppid,pcpu,pmem,user,comm --sort=-pcpu 2>/dev/null | head -n "$((LIMIT + 1))" || ps -eo pid,ppid,pcpu,pmem,user,comm 2>/dev/null | head -n "$((LIMIT + 1))" || true
      ;;
  esac
else
  echo "ps command not available."
fi
echo

echo "== Top memory processes =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,%mem,%cpu,user,comm -m | head -n "$((LIMIT + 1))" || true
      ;;
    *)
      ps -eo pid,ppid,pmem,pcpu,user,comm --sort=-pmem 2>/dev/null | head -n "$((LIMIT + 1))" || ps -eo pid,ppid,pmem,pcpu,user,comm 2>/dev/null | head -n "$((LIMIT + 1))" || true
      ;;
  esac
else
  echo "ps command not available."
fi
echo

echo "== Service manager summary =="
if command -v systemctl >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    systemctl status "${SERVICE_FILTER}" --no-pager 2>/dev/null || echo "No systemctl status found for ${SERVICE_FILTER}."
  else
    systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "running_services_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
  fi
elif command -v service >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    service "${SERVICE_FILTER}" status 2>/dev/null || echo "No service status found for ${SERVICE_FILTER}."
  else
    service --status-all 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
  fi
elif command -v launchctl >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    launchctl print "system/${SERVICE_FILTER}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE_FILTER}" 2>/dev/null || echo "No matching launchctl service found."
  else
    launchctl list 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "launchctl_entries_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
  fi
else
  echo "No supported service manager command found."
fi
echo

echo "== Listening sockets =="
if command -v ss >/dev/null 2>&1; then
  ss -ltnup 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...output truncated..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
else
  echo "No supported listening socket command found."
fi
