#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sensors >/dev/null 2>&1; then
    sensors
  else
    echo "信息：未安装 lm-sensors；如有 thermal zone 则读取。"
    found=0
    for zone in /sys/class/thermal/thermal_zone*; do
      [ -d "$zone" ] || continue
      found=1
      name=$(cat "$zone/type" 2>/dev/null || echo "信息：未知")
      temp=$(cat "$zone/temp" 2>/dev/null || true)
      if [ -n "$temp" ]; then
        awk -v n="$name" -v t="$temp" 'BEGIN { printf "%s: %.1f°C\n", n, t / 1000 }'
      fi
    done
    [ "$found" -eq 1 ] || echo "信息：未找到 thermal zone（热区）。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v pmset >/dev/null 2>&1; then
    pmset -g therm 2>/dev/null || echo "此 macOS 版本不提供散热详情。"
  else
    echo "pmset 不可用。"
  fi
  echo "详细的 macOS CPU 封装温度通常需要第三方工具或特权工具。"
else
  echo "未找到受支持的 CPU 散热命令。"
fi
