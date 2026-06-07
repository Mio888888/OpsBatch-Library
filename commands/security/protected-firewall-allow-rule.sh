#!/usr/bin/env bash
set -euo pipefail

TARGET_PORT="${TARGET_PORT:-}"
TARGET_PROTO="${TARGET_PROTO:-tcp}"
TARGET_SOURCE="${TARGET_SOURCE:-}"
CONFIRM_FIREWALL_ALLOW="${CONFIRM_FIREWALL_ALLOW:-}"

if [ -z "$TARGET_PORT" ] || [ -z "$TARGET_SOURCE" ]; then
  echo "Refusing to run: set TARGET_PORT and TARGET_SOURCE explicitly, for example TARGET_PORT=22 TARGET_SOURCE=192.0.2.10/32."
  exit 0
fi

case "$TARGET_PORT" in
  *[!0-9]*|'') echo "Refusing to run: TARGET_PORT must be numeric."; exit 0 ;;
esac

echo "== planned firewall allow rule =="
printf 'port=%s protocol=%s source=%s\n' "$TARGET_PORT" "$TARGET_PROTO" "$TARGET_SOURCE"
echo "Dry-run: this template prefers narrow source-scoped allow rules, not broad public exposure."

if [ "$CONFIRM_FIREWALL_ALLOW" != "APPLY_FIREWALL_ALLOW" ]; then
  echo "Dry-run only. Set CONFIRM_FIREWALL_ALLOW=APPLY_FIREWALL_ALLOW after confirming maintenance window, source CIDR and rollback path."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow from "$TARGET_SOURCE" to any port "$TARGET_PORT" proto "$TARGET_PROTO"
  elif command -v firewall-cmd >/dev/null 2>&1; then
    echo "firewalld rich-rule candidate:"
    sudo firewall-cmd --add-rich-rule="rule family='ipv4' source address='$TARGET_SOURCE' port port='$TARGET_PORT' protocol='$TARGET_PROTO' accept"
  else
    echo "No supported firewall management tool found. Review nft/iptables manually."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS pf rule changes are not applied by this generic template. Review /etc/pf.conf manually."
else
  echo "Unsupported platform for firewall allow remediation."
fi
