#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== selected sysctl hardening parameters =="
  for key in \
    kernel.randomize_va_space \
    kernel.kptr_restrict \
    kernel.dmesg_restrict \
    fs.protected_hardlinks \
    fs.protected_symlinks \
    fs.suid_dumpable \
    net.ipv4.ip_forward \
    net.ipv4.conf.all.rp_filter \
    net.ipv4.conf.default.rp_filter \
    net.ipv4.conf.all.accept_redirects \
    net.ipv4.conf.default.accept_redirects \
    net.ipv4.conf.all.send_redirects \
    net.ipv4.tcp_syncookies; do
    sysctl "$key" 2>/dev/null || true
  done

  echo
  echo "信息：== loaded security modules hints =="
  [ -r /sys/kernel/security/lsm ] && cat /sys/kernel/security/lsm 2>/dev/null || true
  command -v sestatus >/dev/null 2>&1 && sestatus 2>/dev/null || true
  command -v aa-status >/dev/null 2>&1 && sudo aa-status 2>/dev/null || aa-status 2>/dev/null || true
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== macOS security status hints =="
  csrutil status 2>/dev/null || echo "信息：csrutil status unavailable outside Recovery or unsupported context."
  spctl --status 2>/dev/null || true
  fdesetup status 2>/dev/null || true
else
  echo "不支持的平台 for kernel hardening summary.（Unsupported platform for kernel hardening summary.）"
fi
