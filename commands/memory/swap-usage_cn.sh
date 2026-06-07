#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== free -h =="
  if command -v free >/dev/null 2>&1; then
    free -h
  else
    echo "信息：free not installed."
  fi

  echo
  echo "信息：== swapon --show =="
  if command -v swapon >/dev/null 2>&1; then
    swapon --show 2>/dev/null || echo "swapon output is 不可用.（swapon output is not available.）"
  else
    echo "信息：swapon command not installed."
  fi

  if [ -r /proc/meminfo ]; then
    echo
    echo "信息：== /proc/meminfo swap fields =="
    grep -E '^(SwapTotal|SwapFree|SwapCached):' /proc/meminfo || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== sysctl vm.swapusage =="
  sysctl vm.swapusage 2>/dev/null || echo "vm.swapusage is 不可用.（vm.swapusage is not available.）"

  if command -v vm_stat >/dev/null 2>&1; then
    echo
    echo "信息：== vm_stat pageins/pageouts =="
    vm_stat | grep -E 'Pageins|Pageouts|Swapins|Swapouts' || true
  fi
else
  echo "未找到受支持的 swap usage command found.（No supported swap usage command found.）"
fi
