#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-30}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

echo "信息：Security SSH and firewall audit"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Host: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Platform: ${OS_NAME}"
echo "信息：This script is read-only. SSH and firewall policy output may expose access-control details."
echo

echo "信息：== SSH daemon process and listener hints =="
if command -v pgrep >/dev/null 2>&1; then
  pgrep -fl 'sshd|ssh' 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No ssh-related process found by pgrep."; if (NR > limit) print "...output truncated..." }' || true
else
  echo "pgrep command 不可用.（pgrep command not available.）"
fi
if command -v ss >/dev/null 2>&1; then
  ss -ltnp 2>/dev/null | awk '/:22[[:space:]]|sshd/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk '/:22|sshd/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN/ && /\.22|:22/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
fi
echo

echo "信息：== Selected sshd_config keys =="
SSHD_CONFIG="/etc/ssh/sshd_config"
if [[ -r "${SSHD_CONFIG}" ]]; then
  awk 'BEGIN { IGNORECASE=1 } /^[[:space:]]*(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|AuthorizedKeysFile|AllowUsers|AllowGroups|DenyUsers|DenyGroups|X11Forwarding|ClientAliveInterval|LoginGraceTime)[[:space:]]+/ { print }' "${SSHD_CONFIG}" | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No selected active keys found."; if (NR > limit) print "...output truncated..." }' || true
else
  echo "信息：${SSHD_CONFIG} is not readable or not present."
fi
if command -v sshd >/dev/null 2>&1; then
  echo
  echo "信息：== sshd effective selected keys =="
  sshd -T 2>/dev/null | awk '/^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|x11forwarding|clientaliveinterval|logingracetime)[[:space:]]/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
fi
echo

echo "信息：== Firewall status hints =="
case "${OS_NAME}" in
  Linux)
    if command -v ufw >/dev/null 2>&1; then
      ufw status verbose 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    fi
    if command -v firewall-cmd >/dev/null 2>&1; then
      firewall-cmd --state 2>/dev/null | awk '{ print "firewalld_state=" $0 }' || true
      firewall-cmd --list-all 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || true
    fi
    if command -v iptables >/dev/null 2>&1; then
      iptables -S 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "iptables_rules_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
    fi
    ;;
  Darwin)
    if command -v pfctl >/dev/null 2>&1; then
      pfctl -s info 2>/dev/null || echo "信息：pfctl info unavailable; elevated privileges may be required."
    else
      echo "pfctl 不可用.（pfctl not available.）"
    fi
    ;;
  *)
    echo "信息：No firewall checks implemented for ${OS_NAME}."
    ;;
esac
