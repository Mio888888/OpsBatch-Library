#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
LIMIT="${LIMIT:-30}"
OS_NAME="$(uname -s)"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "Target path not found: ${TARGET_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

echo "Inspection network and disk inventory"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Target path: ${TARGET_PATH}"
echo "This script is read-only. Network and path output may be sensitive."
echo

echo "== Network interfaces =="
case "${OS_NAME}" in
  Linux)
    if command -v ip >/dev/null 2>&1; then
      ip -brief address show 2>/dev/null || true
    elif command -v ifconfig >/dev/null 2>&1; then
      ifconfig 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    else
      echo "Neither ip nor ifconfig is available."
    fi
    ;;
  Darwin)
    if command -v ifconfig >/dev/null 2>&1; then
      ifconfig 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    else
      echo "ifconfig is not available."
    fi
    ;;
  *)
    echo "Unsupported platform for network interface inventory: ${OS_NAME}"
    ;;
esac
echo

echo "== Routes =="
case "${OS_NAME}" in
  Linux)
    if command -v ip >/dev/null 2>&1; then
      ip route show 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    elif command -v netstat >/dev/null 2>&1; then
      netstat -rn 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    else
      echo "No supported route command found."
    fi
    ;;
  Darwin)
    if command -v netstat >/dev/null 2>&1; then
      netstat -rn 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    else
      echo "netstat is not available."
    fi
    ;;
  *)
    echo "Unsupported platform for route inventory: ${OS_NAME}"
    ;;
esac
echo

echo "== DNS summary =="
if [[ -r /etc/resolv.conf ]]; then
  awk '/^nameserver|^search|^domain/ { print }' /etc/resolv.conf 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No resolver entries found."; if (NR > limit) print "...output truncated..." }' || true
elif command -v scutil >/dev/null 2>&1; then
  scutil --dns 2>/dev/null | awk '/nameserver\[[0-9]+\]|search domain\[[0-9]+\]/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No resolver entries found."; if (NR > limit) print "...output truncated..." }' || true
else
  echo "No DNS summary source found."
fi
echo

echo "== Disk usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || df -h || true
else
  echo "df command not available."
fi
echo

echo "== Mounts =="
if command -v mount >/dev/null 2>&1; then
  mount 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "mounts_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
else
  echo "mount command not available."
fi
echo

echo "== Block devices or disk identifiers =="
if command -v lsblk >/dev/null 2>&1; then
  lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS 2>/dev/null || lsblk 2>/dev/null || true
elif command -v diskutil >/dev/null 2>&1; then
  diskutil list 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
else
  echo "No supported block-device inventory command found."
fi
