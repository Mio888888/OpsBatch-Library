#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：Inspecting PID=$pid. Override with PID=<pid> if needed."

echo
echo "信息：== ps summary =="
ps -p "$pid" -o pid,ppid,user,group,stat,pri,nice,%cpu,%mem,rss,vsz,etime,comm 2>/dev/null || echo "Process $pid 未找到 by ps.（Process $pid not found by ps.）"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/status" ]; then
    echo
    echo "信息：== /proc/$pid/status key fields =="
    grep -E '^(Name|Umask|State|Tgid|Ngid|Pid|PPid|TracerPid|Uid|Gid|FDSize|Groups|NStgid|NSpid|NSpgid|NSsid|Threads|SigQ|SigPnd|ShdPnd|SigBlk|SigIgn|SigCgt|CapInh|CapPrm|CapEff|CapBnd|CapAmb|NoNewPrivs|Seccomp):' "/proc/$pid/status" || true
  else
    echo "信息：/proc/$pid/status is not readable."
  fi

  echo
  echo "信息：== paths =="
  printf 'cwd: '; readlink "/proc/$pid/cwd" 2>/dev/null || echo "信息：not readable"
  printf 'exe: '; readlink "/proc/$pid/exe" 2>/dev/null || echo "信息：not readable"
  printf 'root: '; readlink "/proc/$pid/root" 2>/dev/null || echo "信息：not readable"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== open working directory / executable hints =="
  if command -v lsof >/dev/null 2>&1; then
    lsof -p "$pid" -a -d cwd,txt 2>/dev/null || echo "信息：cwd/txt details require permission or are unavailable."
  else
    echo "信息：Install lsof to inspect cwd/executable hints on macOS."
  fi
else
  echo "未找到受支持的 process detail command found.（No supported process detail command found.）"
fi
