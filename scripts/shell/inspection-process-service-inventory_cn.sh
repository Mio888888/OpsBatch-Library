#!/usr/bin/env bash
set -euo pipefail

SERVICE_FILTER="${1:-${SERVICE_FILTER:-}}"
LIMIT="${LIMIT:-20}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：进程与服务巡检清单"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：服务过滤器: ${SERVICE_FILTER:-<无>}"
echo "信息：本脚本为只读。进程命令行和服务名称可能包含敏感信息。"
echo

echo "信息：== Top CPU processes =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,%cpu,%mem,user,comm -r | head -n "$((LIMIT + 1))" || true
      ;;
    *)
      ps -eo pid,ppid,pcpu,pmem,user,comm --sort=-pcpu 2>/dev/null | head -n "$((LIMIT + 1))" || ps -eo pid,ppid,pcpu,pmem,user,comm 2>/dev/null | head -n "$((LIMIT + 1))" || true
      ;;
  esac
else
  echo "ps command 不可用."
fi
echo

echo "信息：== Top memory processes =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,%mem,%cpu,user,comm -m | head -n "$((LIMIT + 1))" || true
      ;;
    *)
      ps -eo pid,ppid,pmem,pcpu,user,comm --sort=-pmem 2>/dev/null | head -n "$((LIMIT + 1))" || ps -eo pid,ppid,pmem,pcpu,user,comm 2>/dev/null | head -n "$((LIMIT + 1))" || true
      ;;
  esac
else
  echo "ps command 不可用."
fi
echo

echo "信息：== 服务管理器摘要 =="
if command -v systemctl >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    systemctl status "${SERVICE_FILTER}" --no-pager 2>/dev/null || echo "信息：未找到 ${SERVICE_FILTER} 的 systemctl 状态。"
  else
    systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "running_services_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
  fi
elif command -v service >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    service "${SERVICE_FILTER}" status 2>/dev/null || echo "信息：未找到 ${SERVICE_FILTER} 的 service 状态。"
  else
    service --status-all 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
  fi
elif command -v launchctl >/dev/null 2>&1; then
  if [[ -n "${SERVICE_FILTER}" ]]; then
    launchctl print "system/${SERVICE_FILTER}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE_FILTER}" 2>/dev/null || echo "未找到匹配的 launchctl 服务。"
  else
    launchctl list 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "launchctl_entries_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
  fi
else
  echo "未找到受支持的 服务管理器命令。"
fi
echo

echo "信息：== 监听套接字 =="
if command -v ss >/dev/null 2>&1; then
  ss -ltnup 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...输出已截断..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...输出已截断..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
else
  echo "未找到受支持的监听套接字命令。"
fi
