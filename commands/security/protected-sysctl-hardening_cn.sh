#!/usr/bin/env bash
set -euo pipefail

SYSCTL_KEY="${SYSCTL_KEY:-}"
SYSCTL_VALUE="${SYSCTL_VALUE:-}"
CONFIRM_SYSCTL="${CONFIRM_SYSCTL:-}"

if [ -z "$SYSCTL_KEY" ] || [ -z "$SYSCTL_VALUE" ]; then
  echo "拒绝执行： set SYSCTL_KEY and SYSCTL_VALUE explicitly, for example SYSCTL_KEY=net.ipv4.tcp_syncookies SYSCTL_VALUE=1."
  exit 0
fi

case "$SYSCTL_KEY" in
  kernel.randomize_va_space|kernel.kptr_restrict|kernel.dmesg_restrict|fs.protected_hardlinks|fs.protected_symlinks|fs.suid_dumpable|net.ipv4.ip_forward|net.ipv4.conf.all.rp_filter|net.ipv4.conf.default.rp_filter|net.ipv4.conf.all.accept_redirects|net.ipv4.conf.default.accept_redirects|net.ipv4.conf.all.send_redirects|net.ipv4.tcp_syncookies)
    ;;
  *)
    echo "拒绝执行： SYSCTL_KEY 不在此模板的允许列表中。"
    exit 0
    ;;
esac

echo "信息：== 计划 sysctl 变更 =="
sysctl "$SYSCTL_KEY" 2>/dev/null || true
printf '将执行： sysctl -w %s=%s\n' "$SYSCTL_KEY" "$SYSCTL_VALUE"

if [ "$CONFIRM_SYSCTL" != "APPLY_SYSCTL_VALUE" ]; then
  echo "仅试运行。 请设置 CONFIRM_SYSCTL=APPLY_SYSCTL_VALUE 在确认后 compatibility and persistence plan."
  exit 0
fi

if [ "$(uname -s)" != "Linux" ]; then
  echo "信息：此受保护 sysctl 模板仅在 Linux 上应用变更。"
  exit 0
fi

sudo sysctl -w "$SYSCTL_KEY=$SYSCTL_VALUE"
