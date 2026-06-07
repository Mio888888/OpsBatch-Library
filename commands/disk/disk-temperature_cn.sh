#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"

if [ "$(uname -s)" = "Linux" ]; then
  if command -v smartctl >/dev/null 2>&1; then
    if [ -n "$TARGET_DEVICE" ]; then
      sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
    elif command -v lsblk >/dev/null 2>&1; then
      for disk in $(lsblk -dn -o NAME 2>/dev/null); do
        echo "信息：== /dev/$disk =="
        sudo smartctl -A "/dev/$disk" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
      done
    else
      echo "请设置 TARGET_DEVICE，例如 TARGET_DEVICE=/dev/sda。"
    fi
  else
    echo "信息：未安装 smartctl。请安装 smartmontools 读取磁盘温度。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS 磁盘温度通常需要 smartctl/smartmontools 或厂商工具。"
  command -v smartctl >/dev/null 2>&1 && [ -n "$TARGET_DEVICE" ] && smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
else
  echo "未找到受支持的 磁盘温度命令。"
fi
