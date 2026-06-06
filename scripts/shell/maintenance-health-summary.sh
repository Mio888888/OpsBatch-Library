#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
SERVICE="${2:-${SERVICE:-}}"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "Target path not found: ${TARGET_PATH}" >&2
  exit 1
fi

echo "Maintenance health summary"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Kernel: $(uname -a)"
echo "Target path: ${TARGET_PATH}"
echo

echo "== Uptime =="
if command -v uptime >/dev/null 2>&1; then
  uptime || true
else
  echo "uptime command not available."
fi
echo

echo "== Disk usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || df -h || true
else
  echo "df command not available."
fi
echo

echo "== Memory summary =="
if command -v free >/dev/null 2>&1; then
  free -h || true
elif command -v vm_stat >/dev/null 2>&1; then
  vm_stat || true
else
  echo "No supported memory summary command found."
fi
echo

echo "== Top CPU processes =="
if command -v ps >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      ps -Ao pid,ppid,%cpu,%mem,comm -r | head -n 8 || true
      ;;
    *)
      ps -eo pid,ppid,pcpu,pmem,comm --sort=-pcpu | head -n 8 || ps -eo pid,ppid,pcpu,pmem,comm | head -n 8 || true
      ;;
  esac
else
  echo "ps command not available."
fi

if [[ -n "${SERVICE}" ]]; then
  echo
  echo "== Optional service status: ${SERVICE} =="
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active "${SERVICE}" || true
    systemctl status "${SERVICE}" --no-pager || true
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" status || true
  elif command -v pgrep >/dev/null 2>&1; then
    pgrep -fl "${SERVICE}" || echo "No matching process found for ${SERVICE}."
  else
    echo "No supported service status command found."
  fi
fi
