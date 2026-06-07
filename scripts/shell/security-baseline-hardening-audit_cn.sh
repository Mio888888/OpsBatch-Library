#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-20}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：安全基线加固审计"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：平台： ${OS_NAME}"
echo "信息：本脚本为只读，仅报告选定的防御基线信号。"
echo

echo "信息：== Identity and privilege context =="
printf 'uid=%s user=%s groups=%s\n' "$(id -u 2>/dev/null || echo 未知)" "$(id -un 2>/dev/null || echo 未知)" "$(id -Gn 2>/dev/null || echo 未知)"
echo

echo "信息：== OS and update hints =="
case "${OS_NAME}" in
  Linux)
    if [[ -r /etc/os-release ]]; then
      awk -F= '/^(PRETTY_NAME|ID|VERSION_ID)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
    fi
    if command -v apt-get >/dev/null 2>&1; then
      echo "信息：apt-get 可用；如有需要，请在本脚本外执行操作员批准的更新检查。"
    elif command -v dnf >/dev/null 2>&1; then
      echo "信息：dnf 可用；如有需要，请在本脚本外执行操作员批准的更新检查。"
    elif command -v yum >/dev/null 2>&1; then
      echo "信息：yum 可用；如有需要，请在本脚本外执行操作员批准的更新检查。"
    elif command -v zypper >/dev/null 2>&1; then
      echo "信息：zypper 可用；如有需要，请在本脚本外执行操作员批准的更新检查。"
    else
      echo "信息：未找到常见 Linux 软件包更新工具。"
    fi
    ;;
  Darwin)
    if command -v sw_vers >/dev/null 2>&1; then
      sw_vers || true
    fi
    if command -v softwareupdate >/dev/null 2>&1; then
      echo "信息：softwareupdate 可用；适当时请使用经操作员批准的 softwareupdate --list。"
    fi
    ;;
  *)
    echo "不支持的平台-specific update hint for ${OS_NAME}."
    ;;
esac
echo

echo "信息：== 内核与网络加固键 =="
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
        sysctl "${key}" 2>/dev/null || printf '%s: 不可用\n' "${key}"
      fi
    done
    ;;
  Darwin)
    for key in kern.securelevel net.inet.ip.forwarding net.inet6.ip6.forwarding; do
      sysctl "${key}" 2>/dev/null || printf '%s: 不可用\n' "${key}"
    done
    ;;
  *)
    echo "信息：没有 ${OS_NAME} 的内核加固键列表。"
    ;;
esac
echo

echo "信息：== 日志与审计信号 =="
if command -v systemctl >/dev/null 2>&1; then
  for unit in auditd journald rsyslog syslog; do
    systemctl is-active "${unit}" 2>/dev/null | awk -v unit="${unit}" '{ print unit ": " $0 }' || printf '%s: 不可用\n' "${unit}"
  done
elif command -v launchctl >/dev/null 2>&1; then
  launchctl list 2>/dev/null | awk -v limit="${LIMIT}" '/audit|syslog|logd/ { print; count++ } END { if (count == 0) print "No audit/syslog launchctl entries found in bounded check." }' || true
else
  echo "未找到用于日志/审计信号的受支持服务管理器。"
fi
if command -v auditctl >/dev/null 2>&1; then
  auditctl -s 2>/dev/null || true
fi
echo

echo "信息：== 安全配置文件元数据 =="
for path in /etc/ssh/sshd_config /etc/sudoers /etc/pam.d /etc/login.defs /etc/pf.conf; do
  if [[ -e "${path}" ]]; then
    ls -ld "${path}" 2>/dev/null || true
  fi
done
