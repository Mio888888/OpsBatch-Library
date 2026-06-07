#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if ps -eLo pid,tid,ppid,user,comm,pcpu,pmem,stat --sort=-pcpu >/dev/null 2>&1; then
    ps -eLo pid,tid,ppid,user,comm,pcpu,pmem,stat --sort=-pcpu | head -15
  elif command -v top >/dev/null 2>&1; then
    top -H -bn1 | head -30
  else
    echo "未找到受支持的 Linux thread CPU command found.（No supported Linux thread CPU command found.）"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v top >/dev/null 2>&1; then
  echo "macOS top shows process CPU and thread counts; detailed per-thread CPU usually 需要 Instruments or privileged tools.（macOS top shows process CPU and thread counts; detailed per-thread CPU usually requires Instruments or privileged tools.）"
  top -l 1 | head -30
else
  echo "未找到受支持的 thread CPU command found.（No supported thread CPU command found.）"
fi
