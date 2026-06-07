#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sensors >/dev/null 2>&1; then
    sensors
  else
    echo "信息：lm-sensors not installed; reading thermal zones if available."
    found=0
    for zone in /sys/class/thermal/thermal_zone*; do
      [ -d "$zone" ] || continue
      found=1
      name=$(cat "$zone/type" 2>/dev/null || echo "信息：unknown")
      temp=$(cat "$zone/temp" 2>/dev/null || true)
      if [ -n "$temp" ]; then
        awk -v n="$name" -v t="$temp" 'BEGIN { printf "%s: %.1f°C\n", n, t / 1000 }'
      fi
    done
    [ "$found" -eq 1 ] || echo "信息：No thermal zones found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v pmset >/dev/null 2>&1; then
    pmset -g therm 2>/dev/null || echo "Thermal details are 不可用 on this macOS version.（Thermal details are not available on this macOS version.）"
  else
    echo "pmset 不可用.（pmset not available.）"
  fi
  echo "Detailed macOS CPU package temperature usually 需要 third-party or privileged tools.（Detailed macOS CPU package temperature usually requires third-party or privileged tools.）"
else
  echo "未找到受支持的 CPU thermal command found.（No supported CPU thermal command found.）"
fi
