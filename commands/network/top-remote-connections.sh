#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ss >/dev/null 2>&1; then
    echo "== top remote endpoints =="
    ss -Htun 2>/dev/null | awk '{ remote=$5; gsub(/^\[/, "", remote); gsub(/\]$/, "", remote); sub(/:[^:]*$/, "", remote); if (remote != "" && remote != "*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tuna 2>/dev/null | awk 'NR > 2 { remote=$5; sub(/:[^:]*$/, "", remote); if (remote != "" && remote != "*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  else
    echo "Neither ss nor netstat is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "== top remote endpoints =="
    netstat -an -f inet | awk 'NR > 2 { remote=$5; sub(/\.[^.]*$/, "", remote); if (remote != "" && remote != "*.*") count[remote]++ } END { for (remote in count) print count[remote], remote }' | sort -nr | head -20
  else
    echo "netstat not available."
  fi
else
  echo "No supported remote connection summary command found."
fi
