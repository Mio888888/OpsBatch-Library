#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
OUTPUT_DIR="${2:-${OUTPUT_DIR:-}}"
LIMIT="${LIMIT:-25}"
OS_NAME="$(uname -s)"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "目标路径未找到: ${TARGET_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：Inspection support checklist"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：目标路径: ${TARGET_PATH}"
echo "信息：输出目录检查: ${OUTPUT_DIR:-<未提供>}"
echo "信息：本脚本为只读，不会创建支持归档。共享前请审核所有输出。"
echo

echo "信息：== Preflight checklist =="
printf '操作员上下文：请单独收集事件/变更 ID；不要在参数中粘贴密钥\n'
printf '平台： %s\n' "${OS_NAME}"
printf 'privilege: uid=%s user=%s\n' "$(id -u 2>/dev/null || echo 未知)" "$(id -un 2>/dev/null || echo 未知)"
if [[ -n "${OUTPUT_DIR}" ]]; then
  if [[ -d "${OUTPUT_DIR}" ]]; then
    printf '输出目录：存在\n'
    if [[ -w "${OUTPUT_DIR}" ]]; then
      printf '输出目录可写：是\n'
    else
      printf '输出目录可写：否\n'
    fi
  else
    printf '输出目录：缺失（未创建目录）\n'
  fi
fi
echo

echo "信息：== Host summary =="
hostname 2>/dev/null || true
uname -a || true
if [[ "${OS_NAME}" == "Darwin" ]] && command -v sw_vers >/dev/null 2>&1; then
  sw_vers || true
elif [[ -r /etc/os-release ]]; then
  awk -F= '/^(PRETTY_NAME|NAME|VERSION)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
fi
echo

echo "信息：== Capacity summary =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || true
fi
if command -v du >/dev/null 2>&1; then
  du -sh "${TARGET_PATH}" 2>/dev/null || echo "信息：du 摘要不可用： ${TARGET_PATH}."
fi
echo

echo "信息：== 最近重启或运行时长上下文 =="
if command -v uptime >/dev/null 2>&1; then
  uptime || true
fi
if command -v who >/dev/null 2>&1; then
  who -b 2>/dev/null || true
fi
echo

echo "信息：== 支持信息收集工具可用性 =="
for tool in tar gzip zip sha256sum shasum openssl journalctl dmesg log show system_profiler sysctl lsof netstat ss ip ifconfig; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: 可用\n' "${tool}"
  else
    printf '%s: 不可用\n' "${tool}"
  fi
done
echo

echo "信息：== 建议的有界证据主题 =="
printf '%s\n' "1. OS/内核和运行时长摘要"
printf '%s\n' "2. 受影响路径的磁盘容量"
printf '%s\n' "3. 仅受影响服务的状态"
printf '%s\n' "4. 最近应用日志摘录（已脱敏）"
printf '%s\n' "5. 如相关，提供网络监听/路由摘要"
printf '%s\n' "6. 受影响组件的软件包/版本摘要"
echo

echo "信息：== 最近系统日志指针 =="
case "${OS_NAME}" in
  Linux)
    if command -v journalctl >/dev/null 2>&1; then
      journalctl --list-boots 2>/dev/null | tail -n "${LIMIT}" || true
    else
      for path in /var/log/syslog /var/log/messages /var/log/system.log; do
        if [[ -r "${path}" ]]; then
          printf '可读日志: %s\n' "${path}"
        fi
      done
    fi
    ;;
  Darwin)
    if command -v log >/dev/null 2>&1; then
      echo "信息：macOS unified log 可用；收集前请使用较窄的 predicate/时间窗口。"
    fi
    ;;
  *)
    echo "信息：没有 ${OS_NAME} 的平台特定日志指引。"
    ;;
esac
