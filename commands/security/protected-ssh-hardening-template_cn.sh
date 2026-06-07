#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="${SSHD_CONFIG:-}"
CONFIRM_SSH_HARDEN="${CONFIRM_SSH_HARDEN:-}"

echo "信息：== SSH 加固候选行 =="
cat <<'EOF'
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
EOF

if [ -z "$SSHD_CONFIG" ]; then
  echo "拒绝执行： set SSHD_CONFIG explicitly, for example SSHD_CONFIG=/etc/ssh/sshd_config."
  exit 0
fi

if [ ! -f "$SSHD_CONFIG" ]; then
  echo "拒绝执行： 目标文件未找到: $SSHD_CONFIG"
  exit 0
fi

echo
echo "信息：== 目标元数据 =="
ls -l "$SSHD_CONFIG" 2>/dev/null || true
echo "试运行： 将追加带日期的备份路径，并审核候选配置： $SSHD_CONFIG."

if [ "$CONFIRM_SSH_HARDEN" != "APPLY_SSH_HARDENING" ]; then
  echo "仅试运行。 请设置 CONFIRM_SSH_HARDEN=APPLY_SSH_HARDENING 在确认后 控制台访问、回滚和服务重载计划后。"
  exit 0
fi

backup="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
sudo cp "$SSHD_CONFIG" "$backup"
sudo tee -a "$SSHD_CONFIG" >/dev/null <<'EOF'

# 中文说明：OpsBatch protected hardening example - review before keeping in production
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
EOF
echo "信息：已更新 $SSHD_CONFIG。备份：$backup。重新加载 sshd 前请用 sshd -t 验证。"
