#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="${SSHD_CONFIG:-/etc/ssh/sshd_config}"

echo "信息：== ssh server process and listener hints =="
if command -v ps >/dev/null 2>&1; then
  ps aux 2>/dev/null | grep '[s]shd' | head -20 || true
fi
if command -v ss >/dev/null 2>&1; then
  ss -tulpen 2>/dev/null | grep -Ei ':(22|ssh)[[:space:]]' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | grep -Ei 'sshd|:22' || true
fi

echo
echo "信息：== sshd 生效配置关键字 from $SSHD_CONFIG =="
if [ -r "$SSHD_CONFIG" ]; then
  grep -Eiv '^[[:space:]]*(#|$)' "$SSHD_CONFIG" 2>/dev/null | grep -Ei '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|PermitEmptyPasswords|AllowUsers|AllowGroups|DenyUsers|DenyGroups|Port|ListenAddress|X11Forwarding|AllowTcpForwarding|ClientAliveInterval|MaxAuthTries|LoginGraceTime)[[:space:]]' || true
else
  echo "无法读取 $SSHD_CONFIG。需要时请将 SSHD_CONFIG 设置为替代文件。"
fi

if command -v sshd >/dev/null 2>&1; then
  echo
  echo "信息：== sshd -T 选定生效值 =="
  sshd -T 2>/dev/null | grep -Ei '^(permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|x11forwarding|allowtcpforwarding|maxauthtries|logingracetime|clientaliveinterval|port) ' || echo "无法运行 sshd -T; 可能存在权限或配置问题."
fi
