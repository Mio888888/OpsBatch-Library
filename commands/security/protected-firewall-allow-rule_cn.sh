#!/usr/bin/env bash
set -euo pipefail

TARGET_PORT="${TARGET_PORT:-}"
TARGET_PROTO="${TARGET_PROTO:-tcp}"
TARGET_SOURCE="${TARGET_SOURCE:-}"
CONFIRM_FIREWALL_ALLOW="${CONFIRM_FIREWALL_ALLOW:-}"

if [ -z "$TARGET_PORT" ] || [ -z "$TARGET_SOURCE" ]; then
  echo "拒绝执行： set TARGET_PORT and TARGET_SOURCE explicitly, for example TARGET_PORT=22 TARGET_SOURCE=192.0.2.10/32."
  exit 0
fi

case "$TARGET_PORT" in
  *[!0-9]*|'') echo "拒绝执行： TARGET_PORT 必须为数字。"; exit 0 ;;
esac

echo "信息：== 计划防火墙放行规则 =="
printf 'port=%s protocol=%s source=%s\n' "$TARGET_PORT" "$TARGET_PROTO" "$TARGET_SOURCE"
echo "试运行：此模板优先使用限定来源范围的放行规则，而不是宽泛公开暴露。"

if [ "$CONFIRM_FIREWALL_ALLOW" != "APPLY_FIREWALL_ALLOW" ]; then
  echo "仅试运行。 请设置 CONFIRM_FIREWALL_ALLOW=APPLY_FIREWALL_ALLOW 在确认后 维护窗口、来源 CIDR 和回滚路径后。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow from "$TARGET_SOURCE" to any port "$TARGET_PORT" proto "$TARGET_PROTO"
  elif command -v firewall-cmd >/dev/null 2>&1; then
    echo "信息：firewalld rich-rule 候选规则:"
    sudo firewall-cmd --add-rich-rule="rule family='ipv4' source address='$TARGET_SOURCE' port port='$TARGET_PORT' protocol='$TARGET_PROTO' accept"
  else
    echo "未找到受支持的防火墙管理工具。请手动审核 nft/iptables。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：此通用模板不会应用 macOS pf 规则变更。请手动审核 /etc/pf.conf。"
else
  echo "当前平台不支持防火墙放行修复。"
fi
