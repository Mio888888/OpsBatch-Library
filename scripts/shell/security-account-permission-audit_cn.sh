#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${1:-${SCAN_ROOT:-${HOME:-/tmp}}}"
LIMIT="${LIMIT:-30}"
OS_NAME="$(uname -s)"

if [[ ! -d "${SCAN_ROOT}" ]]; then
  echo "信息：SCAN_ROOT must be an existing directory: ${SCAN_ROOT}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

echo "信息：Security account and permission audit"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Host: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Scan root: ${SCAN_ROOT}"
echo "信息：This script is read-only. It prints account names, group names, and file metadata but not file contents."
echo

echo "信息：== Privileged accounts =="
if [[ -r /etc/passwd ]]; then
  awk -F: '$3 == 0 { print "uid0_user=" $1 " home=" $6 " shell=" $7 }' /etc/passwd || true
else
  echo "信息：/etc/passwd not readable."
fi
echo

echo "信息：== Administrative groups =="
for group in sudo wheel admin; do
  if command -v getent >/dev/null 2>&1; then
    getent group "${group}" 2>/dev/null || true
  elif [[ -r /etc/group ]]; then
    awk -F: -v group="${group}" '$1 == group { print }' /etc/group || true
  elif command -v dscl >/dev/null 2>&1 && [[ "${OS_NAME}" == "Darwin" ]]; then
    dscl . -read "/Groups/${group}" GroupMembership 2>/dev/null || true
  fi
done
echo

echo "信息：== Login shells summary =="
if [[ -r /etc/passwd ]]; then
  awk -F: '$7 !~ /(nologin|false)$/ { print $1 ":" $6 ":" $7 }' /etc/passwd | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "interactive_like_accounts_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
else
  echo "信息：/etc/passwd not readable."
fi
echo

echo "信息：== World-writable paths under scan root =="
find "${SCAN_ROOT}" -xdev -type d -perm -0002 -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "world_writable_dirs_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
echo

echo "信息：== Setuid and setgid files under scan root =="
find "${SCAN_ROOT}" -xdev -type f \( -perm -4000 -o -perm -2000 \) -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "privileged_files_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
echo

echo "信息：== SSH authorized key file metadata =="
find "${SCAN_ROOT}" -xdev -path '*/.ssh/authorized_keys' -type f -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "authorized_keys_files_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' | while IFS= read -r key_file; do
  case "${key_file}" in
    authorized_keys_files_seen=*|...output*)
      echo "信息：${key_file}"
      ;;
    *)
      ls -l "${key_file}" 2>/dev/null || true
      ;;
  esac
done
