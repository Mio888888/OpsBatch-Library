#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v cpupower >/dev/null 2>&1; then
    cpupower frequency-info
  else
    echo "== Scaling governor =="
    if ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1; then
      for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        printf '%s: ' "$file"
        cat "$file"
      done | head -40
    else
      echo "No cpufreq governor files found."
    fi

    echo
    echo "== Current frequency =="
    if ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq >/dev/null 2>&1; then
      for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        printf '%s kHz: ' "$file"
        cat "$file"
      done | head -40
    elif command -v lscpu >/dev/null 2>&1; then
      lscpu | grep -E 'CPU MHz|CPU max MHz|CPU min MHz|Model name' || true
    else
      echo "No CPU frequency source found."
    fi
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.cpufrequency hw.cpufrequency_min hw.cpufrequency_max 2>/dev/null || true
  echo "Apple Silicon may not expose fixed CPU frequency via sysctl."
else
  echo "No supported CPU frequency command found."
fi
