#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="${SSHD_CONFIG:-}"
CONFIRM_SSH_HARDEN="${CONFIRM_SSH_HARDEN:-}"

echo "== candidate SSH hardening lines =="
cat <<'EOF'
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
EOF

if [ -z "$SSHD_CONFIG" ]; then
  echo "Refusing to run: set SSHD_CONFIG explicitly, for example SSHD_CONFIG=/etc/ssh/sshd_config."
  exit 0
fi

if [ ! -f "$SSHD_CONFIG" ]; then
  echo "Refusing to run: target file not found: $SSHD_CONFIG"
  exit 0
fi

echo
echo "== target metadata =="
ls -l "$SSHD_CONFIG" 2>/dev/null || true
echo "Dry-run: would append a dated backup path and review candidate settings for $SSHD_CONFIG."

if [ "$CONFIRM_SSH_HARDEN" != "APPLY_SSH_HARDENING" ]; then
  echo "Dry-run only. Set CONFIRM_SSH_HARDEN=APPLY_SSH_HARDENING after confirming console access, rollback, and service reload plan."
  exit 0
fi

backup="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
sudo cp "$SSHD_CONFIG" "$backup"
sudo tee -a "$SSHD_CONFIG" >/dev/null <<'EOF'

# OpsBatch protected hardening example - review before keeping in production
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
EOF
echo "Updated $SSHD_CONFIG. Backup: $backup. Validate with sshd -t before reloading sshd."
