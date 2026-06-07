#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-}"
pattern="${PROCESS_PATTERN:-}"
echo "信息：正在检查崩溃线索。可选：PID=<pid> 或 PROCESS_PATTERN=<name>。"

echo
echo "信息：== 目标进程提示 =="
if [ -n "$pid" ]; then
  ps -p "$pid" -o pid,ppid,user,stat,etime,comm,args 2>/dev/null || echo "ps 未找到进程 $pid；该进程可能已退出。"
elif [ -n "$pattern" ]; then
  ps aux 2>/dev/null | grep -i "$pattern" | grep -v grep | head -20 || echo "信息：没有运行中的进程匹配 PROCESS_PATTERN=$pattern。"
else
  echo "请设置 PID 或 PROCESS_PATTERN 来聚焦日志搜索。正在显示 通用近期崩溃提示."
fi

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "信息：== kernel crash / oom hints =="
  if command -v journalctl >/dev/null 2>&1; then
    journalctl -k -n 120 --no-pager 2>/dev/null | grep -Ei 'segfault|core dumped|oom|killed process|blocked for more than|hung task' | tail -40 || true
  fi
  dmesg 2>/dev/null | grep -Ei 'segfault|core dumped|oom|killed process|blocked for more than|hung task' | tail -40 || true

  echo
  echo "信息：== coredumpctl 提示 =="
  if command -v coredumpctl >/dev/null 2>&1; then
    coredumpctl list --no-pager 2>/dev/null | tail -30 || true
  else
    echo "coredumpctl 未找到."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== macOS diagnostic report directories =="
  ls -lt "$HOME/Library/Logs/DiagnosticReports" 2>/dev/null | head -20 || true
  ls -lt /Library/Logs/DiagnosticReports 2>/dev/null | head -20 || true
  echo
  echo "信息：请使用 PROCESS_PATTERN=<name>，并检查诊断报告目录中匹配的 .crash/.ips 文件。"
else
  echo "未找到受支持的 crash hint命令。"
fi
