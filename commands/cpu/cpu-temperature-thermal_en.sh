#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sensors >/dev/null 2>&1; then
    sensors
  else
    echo "lm-sensors not installed; reading thermal zones if available."
    found=0
    for zone in /sys/class/thermal/thermal_zone*; do
      [ -d "$zone" ] || continue
      found=1
      name=$(cat "$zone/type" 2>/dev/null || echo "unknown")
      temp=$(cat "$zone/temp" 2>/dev/null || true)
      if [ -n "$temp" ]; then
        awk -v n="$name" -v t="$temp" 'BEGIN { printf "%s: %.1f°C\n", n, t / 1000 }'
      fi
    done
    [ "$found" -eq 1 ] || echo "No thermal zones found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v pmset >/dev/null 2>&1; then
    pmset -g therm 2>/dev/null || echo "Thermal details are not available on this macOS version."
  else
    echo "pmset not available."
  fi
  echo "Detailed macOS CPU package temperature usually requires third-party or privileged tools."
else
  echo "No supported CPU thermal command found."
fi
