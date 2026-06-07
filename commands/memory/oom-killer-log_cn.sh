#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pattern='out of memory|oom-killer|oom_kill|killed process|memory allocation failure'

  if command -v journalctl >/dev/null 2>&1; then
    echo "信息：== journalctl -k OOM entries =="
    journalctl -k --no-pager -n 2000 2>/dev/null | grep -Ei "$pattern" || echo "信息：No OOM entries found in recent kernel journal."
  else
    echo "信息：journalctl not installed."
  fi

  echo
  echo "信息：== dmesg OOM entries =="
  if command -v dmesg >/dev/null 2>&1; then
    dmesg -T 2>/dev/null | grep -Ei "$pattern" || dmesg 2>/dev/null | grep -Ei "$pattern" || echo "信息：No OOM entries found in dmesg or dmesg is restricted."
  else
    echo "信息：dmesg command not installed."
  fi
else
  echo "信息：OOM Killer log inspection in this command relies on Linux kernel logs."
fi
