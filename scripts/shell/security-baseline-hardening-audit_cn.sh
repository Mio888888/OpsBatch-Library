#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-20}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

echo "信息：Security baseline hardening audit"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Host: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Platform: ${OS_NAME}"
echo "信息：This script is read-only and reports selected defensive baseline signals only."
echo

echo "信息：== Identity and privilege context =="
printf 'uid=%s user=%s groups=%s\n' "$(id -u 2>/dev/null || echo unknown)" "$(id -un 2>/dev/null || echo unknown)" "$(id -Gn 2>/dev/null || echo unknown)"
echo

echo "信息：== OS and update hints =="
case "${OS_NAME}" in
  Linux)
    if [[ -r /etc/os-release ]]; then
      awk -F= '/^(PRETTY_NAME|ID|VERSION_ID)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
    fi
    if command -v apt-get >/dev/null 2>&1; then
      echo "信息：apt-get available; run an operator-approved update check outside this script if needed."
    elif command -v dnf >/dev/null 2>&1; then
      echo "信息：dnf available; run an operator-approved update check outside this script if needed."
    elif command -v yum >/dev/null 2>&1; then
      echo "信息：yum available; run an operator-approved update check outside this script if needed."
    elif command -v zypper >/dev/null 2>&1; then
      echo "信息：zypper available; run an operator-approved update check outside this script if needed."
    else
      echo "信息：No common Linux package update tool found."
    fi
    ;;
  Darwin)
    if command -v sw_vers >/dev/null 2>&1; then
      sw_vers || true
    fi
    if command -v softwareupdate >/dev/null 2>&1; then
      echo "信息：softwareupdate available; use operator-approved softwareupdate --list when appropriate."
    fi
    ;;
  *)
    echo "不支持的平台-specific update hint for ${OS_NAME}.（Unsupported platform-specific update hint for ${OS_NAME}.）"
    ;;
esac
echo

echo "信息：== Kernel and network hardening keys =="
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
    echo "信息：No kernel hardening key list for ${OS_NAME}."
    ;;
esac
echo

echo "信息：== Logging and audit signals =="
if command -v systemctl >/dev/null 2>&1; then
  for unit in auditd journald rsyslog syslog; do
    systemctl is-active "${unit}" 2>/dev/null | awk -v unit="${unit}" '{ print unit ": " $0 }' || printf '%s: unavailable\n' "${unit}"
  done
elif command -v launchctl >/dev/null 2>&1; then
  launchctl list 2>/dev/null | awk -v limit="${LIMIT}" '/audit|syslog|logd/ { print; count++ } END { if (count == 0) print "No audit/syslog launchctl entries found in bounded check." }' || true
else
  echo "未找到受支持的 service manager found for logging/audit signals.（No supported service manager found for logging/audit signals.）"
fi
if command -v auditctl >/dev/null 2>&1; then
  auditctl -s 2>/dev/null || true
fi
echo

echo "信息：== Security configuration file metadata =="
for path in /etc/ssh/sshd_config /etc/sudoers /etc/pam.d /etc/login.defs /etc/pf.conf; do
  if [[ -e "${path}" ]]; then
    ls -ld "${path}" 2>/dev/null || true
  fi
done
