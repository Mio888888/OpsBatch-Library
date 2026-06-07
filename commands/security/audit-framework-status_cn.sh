#!/usr/bin/env bash
set -euo pipefail

echo "信息：== Linux auditd / auditctl =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    sudo auditctl -s 2>/dev/null || auditctl -s 2>/dev/null || true
    echo
    echo "信息：== audit rules summary =="
    sudo auditctl -l 2>/dev/null | head -120 || auditctl -l 2>/dev/null | head -120 || true
  else
    echo "auditctl 未找到."
  fi

  if command -v ausearch >/dev/null 2>&1; then
    echo
    echo "信息：== 最近审计异常 =="
    sudo ausearch -m USER_AUTH,USER_LOGIN,USER_ACCT,USER_CMD,AVC -ts recent 2>/dev/null | tail -80 || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== macOS audit control files =="
  for path in /etc/security/audit_control /etc/security/audit_user; do
    [ -r "$path" ] && { echo "信息：-- $path --"; grep -Ev '^[[:space:]]*(#|$)' "$path" 2>/dev/null | head -80; } || true
  done
else
  echo "此平台不支持审计框架状态检查。"
fi
