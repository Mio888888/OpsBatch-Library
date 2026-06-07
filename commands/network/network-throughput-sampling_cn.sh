#!/usr/bin/env bash
set -euo pipefail

SAMPLE_SECONDS="${SAMPLE_SECONDS:-5}"

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sar >/dev/null 2>&1; then
    sar -n DEV 1 "$SAMPLE_SECONDS"
  elif command -v ifstat >/dev/null 2>&1; then
    ifstat 1 "$SAMPLE_SECONDS"
  elif [ -r /proc/net/dev ]; then
    echo "信息：== /proc/net/dev before =="
    cat /proc/net/dev
    echo
    echo "信息：第二次采样前等待 ${SAMPLE_SECONDS}s..."
    sleep "$SAMPLE_SECONDS"
    echo
    echo "信息：== /proc/net/dev after =="
    cat /proc/net/dev
    echo
    echo "信息：请安装 sysstat 或 ifstat 以计算每秒速率。"
  else
    echo "未找到受支持的 吞吐量采样来源。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v nettop >/dev/null 2>&1; then
    nettop -L 1 -P -x -n 2>/dev/null | head -80 || true
  elif command -v netstat >/dev/null 2>&1; then
    echo "信息：== interface counters before =="
    netstat -ib
    echo
    echo "信息：第二次采样前等待 ${SAMPLE_SECONDS}s..."
    sleep "$SAMPLE_SECONDS"
    echo
    echo "信息：== interface counters after =="
    netstat -ib
  else
    echo "未找到受支持的 macOS 吞吐量命令。"
  fi
else
  echo "未找到受支持的 吞吐量采样命令。"
fi
