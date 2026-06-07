#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ss >/dev/null 2>&1; then
    echo "信息：== top remote endpoints =="
    ss -Htun 2>/dev/null | awk '{ remote=$5; gsub(/^\[/, "", remote); gsub(/\]$/, "", remote); sub(/:[^:]*$/, "", remote); if (remote != "" && remote != "*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tuna 2>/dev/null | awk 'NR > 2 { remote=$5; sub(/:[^:]*$/, "", remote); if (remote != "" && remote != "*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  else
    echo "信息：Neither ss nor netstat is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "信息：== top remote endpoints =="
    netstat -an -f inet | awk 'NR > 2 { remote=$5; sub(/\.[^.]*$/, "", remote); if (remote != "" && remote != "*.*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  else
    echo "netstat 不可用.（netstat not available.）"
  fi
else
  echo "未找到受支持的 remote connection summary command found.（No supported remote connection summary command found.）"
fi
