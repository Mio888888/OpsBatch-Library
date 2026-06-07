#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="${1:-${LOG_PATH:-}}"
LIMIT="${LIMIT:-25}"
SINCE_MINUTES="${SINCE_MINUTES:-1440}"
OS_NAME="$(uname -s)"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

if [[ ! "${SINCE_MINUTES}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：SINCE_MINUTES 必须是正整数。" >&2
  exit 2
fi

if [[ -n "${LOG_PATH}" && ! -r "${LOG_PATH}" ]]; then
  echo "信息：LOG_PATH is 不可读: ${LOG_PATH}" >&2
  exit 1
fi

echo "信息：Security suspicious activity indicators"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：日志路径: ${LOG_PATH:-<auto>}"
echo "信息：本脚本为只读。输出可能包含用户名、IP、进程名和路径。"
echo

echo "信息：== 从临时路径执行的进程 =="
if command -v ps >/dev/null 2>&1; then
  case "${OS_NAME}" in
    Darwin)
      ps -Ao pid,ppid,user,etime,command 2>/dev/null | awk '/\/tmp\/|\/var\/tmp\/|\/private\/tmp\// { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "temp_path_processes_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
      ;;
    *)
      ps -eo pid,ppid,user,etimes,args 2>/dev/null | awk '/\/tmp\/|\/var\/tmp\/|\/dev\/shm\// { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "temp_path_processes_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
      ;;
  esac
else
  echo "ps command 不可用."
fi
echo

echo "信息：== 监听和已建立连接样本 =="
if command -v ss >/dev/null 2>&1; then
  ss -tunap 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...输出已截断..." }' || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -i 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR > limit + 1) print "...输出已截断..." }' || true
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/LISTEN|ESTABLISHED/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
else
  echo "未找到受支持的 network connection命令。"
fi
echo

echo "信息：== 已删除但仍打开文件提示 =="
if command -v lsof >/dev/null 2>&1; then
  lsof +L1 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit + 1 { print } END { if (NR == 0) print "No deleted-open-file output or permission denied."; if (NR > limit + 1) print "...输出已截断..." }' || true
else
  echo "lsof 不可用."
fi
echo

echo "信息：== Authentication log summary =="
if [[ -n "${LOG_PATH}" ]]; then
  tail -n "$((LIMIT * 20))" "${LOG_PATH}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
elif [[ "${OS_NAME}" == "Linux" ]] && command -v journalctl >/dev/null 2>&1; then
  journalctl --since "${SINCE_MINUTES} minutes ago" -u ssh -u sshd --no-pager 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
else
  for candidate in /var/log/auth.log /var/log/secure /var/log/system.log; do
    if [[ -r "${candidate}" ]]; then
      echo "信息：正在使用 ${candidate}"
      tail -n "$((LIMIT * 20))" "${candidate}" 2>/dev/null | awk 'BEGIN { IGNORECASE=1 } /failed|failure|invalid|accepted|session opened|sudo/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "auth_events_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
      break
    fi
  done
fi
