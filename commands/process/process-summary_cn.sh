#!/usr/bin/env bash
set -euo pipefail

echo "信息：== process counts =="
total=$(ps -e -o pid= 2>/dev/null | wc -l | tr -d ' ')
echo "信息：total_processes=${total:-unknown}"

echo
echo "信息：== process states =="
if [ "$(uname -s)" = "Linux" ]; then
  ps -eo stat= 2>/dev/null | awk '{state=substr($1,1,1); count[state]++} END {for (s in count) print s, count[s]}' | sort || true
else
  ps -axo stat= 2>/dev/null | awk '{state=substr($1,1,1); count[state]++} END {for (s in count) print s, count[s]}' | sort || true
fi

echo
echo "信息：== top CPU processes =="
if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,comm,%cpu,%mem,etime | { IFS= read -r header; printf '%s\n' "$header"; sort -nrk 5 | head -10; }
elif ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu >/dev/null 2>&1; then
  ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu | head -11
else
  ps aux | sort -nrk 3 | head -10
fi

echo
echo "信息：== top memory processes =="
if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,comm,%cpu,%mem,rss,etime | { IFS= read -r header; printf '%s\n' "$header"; sort -nrk 6 | head -10; }
elif ps -eo pid,ppid,user,comm,%cpu,%mem,rss,etime --sort=-%mem >/dev/null 2>&1; then
  ps -eo pid,ppid,user,comm,%cpu,%mem,rss,etime --sort=-%mem | head -11
else
  ps aux | sort -nrk 4 | head -10
fi
