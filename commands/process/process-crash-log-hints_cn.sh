#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-}"
pattern="${PROCESS_PATTERN:-}"
echo "信息：Inspecting crash hints. Optional: PID=<pid> or PROCESS_PATTERN=<name>."

echo
echo "信息：== target process hint =="
if [ -n "$pid" ]; then
  ps -p "$pid" -o pid,ppid,user,stat,etime,comm,args 2>/dev/null || echo "Process $pid 未找到 by ps; it may have already exited.（Process $pid not found by ps; it may have already exited.）"
elif [ -n "$pattern" ]; then
  ps aux 2>/dev/null | grep -i "$pattern" | grep -v grep | head -20 || echo "信息：No running process matched PROCESS_PATTERN=$pattern."
else
  echo "请设置 PID or PROCESS_PATTERN to focus the log search. 正在显示 generic recent crash hints.（Set PID or PROCESS_PATTERN to focus the log search. Showing generic recent crash hints.）"
fi

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "信息：== kernel crash / oom hints =="
  if command -v journalctl >/dev/null 2>&1; then
    journalctl -k -n 120 --no-pager 2>/dev/null | grep -Ei 'segfault|core dumped|oom|killed process|blocked for more than|hung task' | tail -40 || true
  fi
  dmesg 2>/dev/null | grep -Ei 'segfault|core dumped|oom|killed process|blocked for more than|hung task' | tail -40 || true

  echo
  echo "信息：== coredumpctl hints =="
  if command -v coredumpctl >/dev/null 2>&1; then
    coredumpctl list --no-pager 2>/dev/null | tail -30 || true
  else
    echo "coredumpctl 未找到.（coredumpctl not found.）"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== macOS diagnostic report directories =="
  ls -lt "$HOME/Library/Logs/DiagnosticReports" 2>/dev/null | head -20 || true
  ls -lt /Library/Logs/DiagnosticReports 2>/dev/null | head -20 || true
  echo
  echo "信息：Use PROCESS_PATTERN=<name> and inspect matching .crash/.ips files in the diagnostic report directories."
else
  echo "未找到受支持的 crash hint command found.（No supported crash hint command found.）"
fi
