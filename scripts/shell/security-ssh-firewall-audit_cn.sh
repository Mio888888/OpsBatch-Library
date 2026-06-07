#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-30}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：Security SSH and firewall audit"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：平台： ${OS_NAME}"
echo "信息：本脚本为只读。SSH 和防火墙策略输出可能暴露访问控制详情。"
echo

echo "信息：== SSH daemon process and listener hints =="
if command -v pgrep >/dev/null 2>&1; then
  pgrep -fl 'sshd|ssh' 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No ssh-related process found by pgrep."; if (NR > limit) print "...输出已截断..." }' || true
else
  echo "pgrep command 不可用."
fi
if command -v ss >/dev/null 2>&1; then
  ss -ltnp 2>/dev/null | awk '/:22[[:space:]]|sshd/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk '/:22|sshd/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN/ && /\.22|:22/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
fi
echo

echo "信息：== 选定 sshd_config 键 =="
SSHD_CONFIG="/etc/ssh/sshd_config"
if [[ -r "${SSHD_CONFIG}" ]]; then
  awk 'BEGIN { IGNORECASE=1 } /^[[:space:]]*(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|AuthorizedKeysFile|AllowUsers|AllowGroups|DenyUsers|DenyGroups|X11Forwarding|ClientAliveInterval|LoginGraceTime)[[:space:]]+/ { print }' "${SSHD_CONFIG}" | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No 选中的有效键 found."; if (NR > limit) print "...输出已截断..." }' || true
else
  echo "信息：${SSHD_CONFIG} is 不可读 or not present."
fi
if command -v sshd >/dev/null 2>&1; then
  echo
  echo "信息：== sshd 生效选定键 =="
  sshd -T 2>/dev/null | awk '/^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|x11forwarding|clientaliveinterval|logingracetime)[[:space:]]/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
fi
echo

echo "信息：== 防火墙状态提示 =="
case "${OS_NAME}" in
  Linux)
    if command -v ufw >/dev/null 2>&1; then
      ufw status verbose 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    fi
    if command -v firewall-cmd >/dev/null 2>&1; then
      firewall-cmd --state 2>/dev/null | awk '{ print "firewalld_state=" $0 }' || true
      firewall-cmd --list-all 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    fi
    if command -v iptables >/dev/null 2>&1; then
      iptables -S 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "iptables_rules_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
    fi
    ;;
  Darwin)
    if command -v pfctl >/dev/null 2>&1; then
      pfctl -s info 2>/dev/null || echo "信息：pfctl 信息不可用；可能需要更高权限。"
    else
      echo "pfctl 不可用."
    fi
    ;;
  *)
    echo "信息：未实现 ${OS_NAME} 的防火墙检查。"
    ;;
esac
