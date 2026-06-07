#!/usr/bin/env bash
set -euo pipefail

echo "== Linux auditd / auditctl =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    sudo auditctl -s 2>/dev/null || auditctl -s 2>/dev/null || true
    echo
    echo "== audit rules summary =="
    sudo auditctl -l 2>/dev/null | head -120 || auditctl -l 2>/dev/null | head -120 || true
  else
    echo "auditctl not found."
  fi

  if command -v ausearch >/dev/null 2>&1; then
    echo
    echo "== recent audit anomalies =="
    sudo ausearch -m USER_AUTH,USER_LOGIN,USER_ACCT,USER_CMD,AVC -ts recent 2>/dev/null | tail -80 || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "== macOS audit control files =="
  for path in /etc/security/audit_control /etc/security/audit_user; do
    [ -r "$path" ] && { echo "-- $path --"; grep -Ev '^[[:space:]]*(#|$)' "$path" 2>/dev/null | head -80; } || true
  done
else
  echo "Unsupported platform for audit framework status."
fi
