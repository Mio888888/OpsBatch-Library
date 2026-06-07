#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
LIMIT="${LIMIT:-30}"
OS_NAME="$(uname -s)"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "目标路径未找到: ${TARGET_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：Inspection network and disk inventory"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：目标路径: ${TARGET_PATH}"
echo "信息：本脚本为只读。网络和路径输出可能包含敏感信息。"
echo

echo "信息：== Network interfaces =="
case "${OS_NAME}" in
  Linux)
    if command -v ip >/dev/null 2>&1; then
      ip -brief address show 2>/dev/null || true
    elif command -v ifconfig >/dev/null 2>&1; then
      ifconfig 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    else
      echo "信息：ip 和 ifconfig 均不可用。"
    fi
    ;;
  Darwin)
    if command -v ifconfig >/dev/null 2>&1; then
      ifconfig 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    else
      echo "ifconfig 不可用。"
    fi
    ;;
  *)
    echo "不支持的平台 for network interface inventory: ${OS_NAME}"
    ;;
esac
echo

echo "信息：== Routes =="
case "${OS_NAME}" in
  Linux)
    if command -v ip >/dev/null 2>&1; then
      ip route show 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    elif command -v netstat >/dev/null 2>&1; then
      netstat -rn 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    else
      echo "未找到受支持的 route命令。"
    fi
    ;;
  Darwin)
    if command -v netstat >/dev/null 2>&1; then
      netstat -rn 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
    else
      echo "netstat 不可用。"
    fi
    ;;
  *)
    echo "不支持的平台 for route inventory: ${OS_NAME}"
    ;;
esac
echo

echo "信息：== DNS summary =="
if [[ -r /etc/resolv.conf ]]; then
  awk '/^nameserver|^search|^domain/ { print }' /etc/resolv.conf 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No 解析器条目 found."; if (NR > limit) print "...输出已截断..." }' || true
elif command -v scutil >/dev/null 2>&1; then
  scutil --dns 2>/dev/null | awk '/nameserver\[[0-9]+\]|search domain\[[0-9]+\]/ { print }' | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR == 0) print "No 解析器条目 found."; if (NR > limit) print "...输出已截断..." }' || true
else
  echo "信息：未找到 DNS 摘要来源。"
fi
echo

echo "信息：== Disk usage =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || df -h || true
else
  echo "df command 不可用."
fi
echo

echo "信息：== Mounts =="
if command -v mount >/dev/null 2>&1; then
  mount 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "mounts_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
else
  echo "mount command 不可用."
fi
echo

echo "信息：== Block devices or disk identifiers =="
if command -v lsblk >/dev/null 2>&1; then
  lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS 2>/dev/null || lsblk 2>/dev/null || true
elif command -v diskutil >/dev/null 2>&1; then
  diskutil list 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || true
else
  echo "未找到受支持的 block-device inventory命令。"
fi
