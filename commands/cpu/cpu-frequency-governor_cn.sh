#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v cpupower >/dev/null 2>&1; then
    cpupower frequency-info
  else
    echo "信息：== 频率调节策略 =="
    if ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1; then
      for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        printf '%s: ' "$file"
        cat "$file"
      done | head -40
    else
      echo "信息：未找到 cpufreq governor 文件。"
    fi

    echo
    echo "信息：== 当前频率 =="
    if ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq >/dev/null 2>&1; then
      for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        printf '%s kHz: ' "$file"
        cat "$file"
      done | head -40
    elif command -v lscpu >/dev/null 2>&1; then
      lscpu | grep -E 'CPU MHz|CPU max MHz|CPU min MHz|Model name' || true
    else
      echo "信息：未找到 CPU 频率来源。"
    fi
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.cpufrequency hw.cpufrequency_min hw.cpufrequency_max 2>/dev/null || true
  echo "信息：Apple Silicon 可能不会通过 sysctl 暴露固定 CPU 频率。"
else
  echo "未找到受支持的 CPU 频率命令。"
fi
