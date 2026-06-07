#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：正在检查 PID=$pid。需要时可用 PID=<pid> 覆盖。"

echo
echo "信息：== ps summary =="
ps -p "$pid" -o pid,ppid,user,group,stat,pri,nice,%cpu,%mem,rss,vsz,etime,comm 2>/dev/null || echo "ps 未找到进程 $pid。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/status" ]; then
    echo
    echo "信息：== /proc/$pid/status key fields =="
    grep -E '^(Name|Umask|State|Tgid|Ngid|Pid|PPid|TracerPid|Uid|Gid|FDSize|Groups|NStgid|NSpid|NSpgid|NSsid|Threads|SigQ|SigPnd|ShdPnd|SigBlk|SigIgn|SigCgt|CapInh|CapPrm|CapEff|CapBnd|CapAmb|NoNewPrivs|Seccomp):' "/proc/$pid/status" || true
  else
    echo "信息：/proc/$pid/status 不可读。"
  fi

  echo
  echo "信息：== paths =="
  printf 'cwd: '; readlink "/proc/$pid/cwd" 2>/dev/null || echo "信息：不可读"
  printf 'exe: '; readlink "/proc/$pid/exe" 2>/dev/null || echo "信息：不可读"
  printf 'root: '; readlink "/proc/$pid/root" 2>/dev/null || echo "信息：不可读"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== 打开的工作目录 / 可执行文件提示 =="
  if command -v lsof >/dev/null 2>&1; then
    lsof -p "$pid" -a -d cwd,txt 2>/dev/null || echo "信息：cwd/txt 详情需要权限或不可用。"
  else
    echo "信息：Install lsof to inspect cwd/executable hints on macOS."
  fi
else
  echo "未找到受支持的 process detail命令。"
fi
