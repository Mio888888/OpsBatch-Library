#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-20}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "LIMIT must be a positive integer." >&2
  exit 2
fi

echo "Security baseline hardening audit"
echo "Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host: $(hostname 2>/dev/null || echo unknown)"
echo "Platform: ${OS_NAME}"
echo "This script is read-only and reports selected defensive baseline signals only."
echo

echo "== Identity and privilege context =="
printf 'uid=%s user=%s groups=%s\n' "$(id -u 2>/dev/null || echo unknown)" "$(id -un 2>/dev/null || echo unknown)" "$(id -Gn 2>/dev/null || echo unknown)"
echo

echo "== OS and update hints =="
case "${OS_NAME}" in
  Linux)
    if [[ -r /etc/os-release ]]; then
      awk -F= '/^(PRETTY_NAME|ID|VERSION_ID)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
    fi
    if command -v apt-get >/dev/null 2>&1; then
      echo "apt-get available; run an operator-approved update check outside this script if needed."
    elif command -v dnf >/dev/null 2>&1; then
      echo "dnf available; run an operator-approved update check outside this script if needed."
    elif command -v yum >/dev/null 2>&1; then
      echo "yum available; run an operator-approved update check outside this script if needed."
    elif command -v zypper >/dev/null 2>&1; then
      echo "zypper available; run an operator-approved update check outside this script if needed."
    else
      echo "No common Linux package update tool found."
    fi
    ;;
  Darwin)
    if command -v sw_vers >/dev/null 2>&1; then
      sw_vers || true
    fi
    if command -v softwareupdate >/dev/null 2>&1; then
      echo "softwareupdate available; use operator-approved softwareupdate --list when appropriate."
    fi
    ;;
  *)
    echo "Unsupported platform-specific update hint for ${OS_NAME}."
    ;;
esac
echo

echo "== Kernel and network hardening keys =="
case "${OS_NAME}" in
  Linux)
    for key in \
      kernel.randomize_va_space \
      kernel.kptr_restrict \
      kernel.dmesg_restrict \
      fs.protected_hardlinks \
      fs.protected_symlinks \
      net.ipv4.ip_forward \
      net.ipv4.conf.all.rp_filter \
      net.ipv4.conf.all.accept_redirects \
      net.ipv6.conf.all.accept_redirects; do
      if command -v sysctl >/dev/null 2>&1; then
        sysctl "${key}" 2>/dev/null || printf '%s: unavailable\n' "${key}"
      fi
    done
    ;;
  Darwin)
    for key in kern.securelevel net.inet.ip.forwarding net.inet6.ip6.forwarding; do
      sysctl "${key}" 2>/dev/null || printf '%s: unavailable\n' "${key}"
    done
    ;;
  *)
    echo "No kernel hardening key list for ${OS_NAME}."
    ;;
esac
echo

echo "== Logging and audit signals =="
if command -v systemctl >/dev/null 2>&1; then
  for unit in auditd journald rsyslog syslog; do
    systemctl is-active "${unit}" 2>/dev/null | awk -v unit="${unit}" '{ print unit ": " $0 }' || printf '%s: unavailable\n' "${unit}"
  done
elif command -v launchctl >/dev/null 2>&1; then
  launchctl list 2>/dev/null | awk -v limit="${LIMIT}" '/audit|syslog|logd/ { print; count++ } END { if (count == 0) print "No audit/syslog launchctl entries found in bounded check." }' || true
else
  echo "No supported service manager found for logging/audit signals."
fi
if command -v auditctl >/dev/null 2>&1; then
  auditctl -s 2>/dev/null || true
fi
echo

echo "== Security configuration file metadata =="
for path in /etc/ssh/sshd_config /etc/sudoers /etc/pam.d /etc/login.defs /etc/pf.conf; do
  if [[ -e "${path}" ]]; then
    ls -ld "${path}" 2>/dev/null || true
  fi
done
