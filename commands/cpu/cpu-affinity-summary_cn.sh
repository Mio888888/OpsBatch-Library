#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v taskset >/dev/null 2>&1; then
    echo "信息：== 当前 Shell 亲和性 =="
    taskset -pc $$
    echo
    echo "信息：== CPU 占用较高进程的亲和性 =="
    ps -eo pid,comm,%cpu --sort=-%cpu | head -11 | while read -r pid comm cpu; do
      if [ "$pid" = "PID" ]; then
        printf '%-8s %-24s %-8s %s\n' "PID" "COMMAND" "%CPU" "AFFINITY"
        continue
      fi
      affinity=$(taskset -pc "$pid" 2>/dev/null | sed 's/.*: //')
      printf '%-8s %-24s %-8s %s\n' "$pid" "$comm" "$cpu" "$affinity"
    done
  else
    echo "信息：未安装 taskset；无法使用此命令检查 Linux CPU 亲和性。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：macOS 不提供 taskset 风格的内置亲和性检查命令。"
  ps -axo pid,comm,%cpu | sort -nrk 3 | head -10
else
  echo "未找到受支持的 CPU 亲和性命令。"
fi
