#!/usr/bin/env bash
set -euo pipefail

echo "信息：== host identity =="
hostname 2>/dev/null || true
uname -a 2>/dev/null || true

echo
echo "信息：== system time =="
date 2>/dev/null || true
if command -v timedatectl >/dev/null 2>&1; then
  timedatectl status 2>/dev/null | head -40 || true
fi

echo
echo "信息：== current user and privilege context =="
id 2>/dev/null || true
umask 2>/dev/null || true

echo
echo "信息：== readable security-relevant configuration files =="
for path in /etc/passwd /etc/group /etc/sudoers /etc/ssh/sshd_config /etc/login.defs /etc/pam.d; do
  [ -e "$path" ] && ls -ld "$path" 2>/dev/null || true
done

echo
echo "信息：== kernel and package update hints =="
if [ "$(uname -s)" = "Linux" ]; then
  [ -r /proc/sys/kernel/randomize_va_space ] && printf 'aslr=%s\n' "$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null)"
  [ -r /proc/sys/net/ipv4/ip_forward ] && printf 'ipv4_forward=%s\n' "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)"
  if command -v apt >/dev/null 2>&1; then
    apt list --upgradable 2>/dev/null | head -40 || true
  elif command -v dnf >/dev/null 2>&1; then
    dnf check-update --security 2>/dev/null | head -40 || true
  elif command -v yum >/dev/null 2>&1; then
    yum check-update --security 2>/dev/null | head -40 || true
  else
    echo "未找到受支持的 package security update checker found.（No supported package security update checker found.）"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  sw_vers 2>/dev/null || true
  softwareupdate -l 2>/dev/null | head -80 || echo "信息：Cannot list macOS software updates."
else
  echo "不支持的平台 for baseline update hints.（Unsupported platform for baseline update hints.）"
fi
