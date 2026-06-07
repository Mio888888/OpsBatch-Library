#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
SERVICE="${2:-${SERVICE:-}}"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "目标路径未找到: ${TARGET_PATH}" >&2
  exit 1
fi

echo "信息：维护健康摘要"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：Kernel: $(uname -a)"
echo "信息：目标路径: ${TARGET_PATH}"
echo

echo "信息：== Uptime =="
if command -v uptime >/dev/null 2>&1; then
  uptime || true
else
  echo "uptime command 不可用."
fi
echo

echo "信息：== Disk usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || df -h || true
else
  echo "df command 不可用."
fi
echo

echo "信息：== Memory summary =="
if command -v free >/dev/null 2>&1; then
  free -h || true
elif command -v vm_stat >/dev/null 2>&1; then
  vm_stat || true
else
  echo "未找到受支持的 内存摘要命令。"
fi
echo

echo "信息：== Top CPU processes =="
if command -v ps >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      ps -Ao pid,ppid,%cpu,%mem,comm -r | head -n 8 || true
      ;;
    *)
      ps -eo pid,ppid,pcpu,pmem,comm --sort=-pcpu | head -n 8 || ps -eo pid,ppid,pcpu,pmem,comm | head -n 8 || true
      ;;
  esac
else
  echo "ps command 不可用."
fi

if [[ -n "${SERVICE}" ]]; then
  echo
  echo "信息：== 可选服务状态: ${SERVICE} =="
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active "${SERVICE}" || true
    systemctl status "${SERVICE}" --no-pager || true
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" status || true
  elif command -v pgrep >/dev/null 2>&1; then
    pgrep -fl "${SERVICE}" || echo "未找到匹配进程: ${SERVICE}."
  else
    echo "未找到受支持的 service status命令。"
  fi
fi
