#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：正在检查 PID=$pid 的 cgroup 成员关系。需要时可用 PID=<pid> 覆盖。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/cgroup" ]; then
    echo "信息：== /proc/$pid/cgroup =="
    cat "/proc/$pid/cgroup"
    echo
    echo "信息：== container hints =="
    grep -E 'docker|kubepods|containerd|crio|libpod|lxc' "/proc/$pid/cgroup" || echo "信息：cgroup 路径中未找到常见容器运行时关键字。"
  else
    echo "Process $pid 未找到 or /proc/$pid/cgroup is 不可读."
  fi
else
  echo "信息：cgroup 是 Linux 专属能力；当前平台无 cgroup 信息： $(uname -s)."
fi
