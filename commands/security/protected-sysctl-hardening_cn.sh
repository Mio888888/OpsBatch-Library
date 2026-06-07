#!/usr/bin/env bash
set -euo pipefail

SYSCTL_KEY="${SYSCTL_KEY:-}"
SYSCTL_VALUE="${SYSCTL_VALUE:-}"
CONFIRM_SYSCTL="${CONFIRM_SYSCTL:-}"

if [ -z "$SYSCTL_KEY" ] || [ -z "$SYSCTL_VALUE" ]; then
  echo "拒绝执行： set SYSCTL_KEY and SYSCTL_VALUE explicitly, for example SYSCTL_KEY=net.ipv4.tcp_syncookies SYSCTL_VALUE=1.（Refusing to run: set SYSCTL_KEY and SYSCTL_VALUE explicitly, for example SYSCTL_KEY=net.ipv4.tcp_syncookies SYSCTL_VALUE=1.）"
  exit 0
fi

case "$SYSCTL_KEY" in
  kernel.randomize_va_space|kernel.kptr_restrict|kernel.dmesg_restrict|fs.protected_hardlinks|fs.protected_symlinks|fs.suid_dumpable|net.ipv4.ip_forward|net.ipv4.conf.all.rp_filter|net.ipv4.conf.default.rp_filter|net.ipv4.conf.all.accept_redirects|net.ipv4.conf.default.accept_redirects|net.ipv4.conf.all.send_redirects|net.ipv4.tcp_syncookies)
    ;;
  *)
    echo "拒绝执行： SYSCTL_KEY is not in the allowlist for this template.（Refusing to run: SYSCTL_KEY is not in the allowlist for this template.）"
    exit 0
    ;;
esac

echo "信息：== planned sysctl change =="
sysctl "$SYSCTL_KEY" 2>/dev/null || true
printf 'Would run: sysctl -w %s=%s\n' "$SYSCTL_KEY" "$SYSCTL_VALUE"

if [ "$CONFIRM_SYSCTL" != "APPLY_SYSCTL_VALUE" ]; then
  echo "仅试运行。 请设置 CONFIRM_SYSCTL=APPLY_SYSCTL_VALUE 在确认后 compatibility and persistence plan.（Dry-run only. Set CONFIRM_SYSCTL=APPLY_SYSCTL_VALUE after confirming compatibility and persistence plan.）"
  exit 0
fi

if [ "$(uname -s)" != "Linux" ]; then
  echo "信息：This protected sysctl template only applies changes on Linux."
  exit 0
fi

sudo sysctl -w "$SYSCTL_KEY=$SYSCTL_VALUE"
