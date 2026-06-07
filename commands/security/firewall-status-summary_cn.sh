#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ufw >/dev/null 2>&1; then
    echo "信息：== ufw status =="
    sudo ufw status verbose 2>/dev/null || ufw status verbose 2>/dev/null || true
  fi

  if command -v firewall-cmd >/dev/null 2>&1; then
    echo
    echo "信息：== firewalld status =="
    firewall-cmd --state 2>/dev/null || true
    firewall-cmd --list-all 2>/dev/null || true
  fi

  if command -v nft >/dev/null 2>&1; then
    echo
    echo "信息：== nftables ruleset summary =="
    sudo nft list ruleset 2>/dev/null | head -120 || nft list ruleset 2>/dev/null | head -120 || true
  elif command -v iptables >/dev/null 2>&1; then
    echo
    echo "信息：== iptables rules summary =="
    sudo iptables -S 2>/dev/null | head -120 || iptables -S 2>/dev/null | head -120 || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v /usr/libexec/ApplicationFirewall/socketfilterfw >/dev/null 2>&1; then
    echo "信息：== application firewall =="
    /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --getblockall 2>/dev/null || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null || true
  fi

  if command -v pfctl >/dev/null 2>&1; then
    echo
    echo "信息：== pf status =="
    sudo pfctl -s info 2>/dev/null || pfctl -s info 2>/dev/null || true
  fi
else
  echo "未找到受支持的 firewall status命令。"
fi
