#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-${TARGET_PATH:-/}}"
LIMIT="${LIMIT:-20}"

if [[ ! -e "${TARGET_PATH}" ]]; then
  echo "目标路径未找到: ${TARGET_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

OS_NAME="$(uname -s)"

echo "信息：Inspection system inventory"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：平台： ${OS_NAME}"
echo "信息：目标路径: ${TARGET_PATH}"
echo "信息：本脚本为只读。共享输出前请审核主机标识符。"
echo

echo "信息：== OS and kernel =="
case "${OS_NAME}" in
  Linux)
    if [[ -r /etc/os-release ]]; then
      awk -F= '/^(NAME|VERSION|ID|VERSION_ID)=/ { gsub(/^"|"$/, "", $2); print $1 "=" $2 }' /etc/os-release || true
    else
      echo "信息：/etc/os-release 不可读."
    fi
    ;;
  Darwin)
    if command -v sw_vers >/dev/null 2>&1; then
      sw_vers || true
    else
      echo "sw_vers command 不可用."
    fi
    ;;
  *)
    echo "当前平台不支持专用 OS 摘要；仅使用 uname。"
    ;;
esac
uname -a || true
echo

echo "信息：== Hardware summary =="
case "${OS_NAME}" in
  Linux)
    if command -v lscpu >/dev/null 2>&1; then
      lscpu | awk -F: '/^(Architecture|CPU\(s\)|Model name|Socket\(s\)|Core\(s\) per socket|Thread\(s\) per core):/ { gsub(/^[ \t]+/, "", $2); print $1 ": " $2 }' || true
    else
      echo "lscpu 不可用."
    fi
    if [[ -r /proc/meminfo ]]; then
      awk '/^(MemTotal|MemAvailable|SwapTotal):/ { print }' /proc/meminfo || true
    fi
    ;;
  Darwin)
    sysctl -n hw.model 2>/dev/null | awk '{ print "Model: " $0 }' || true
    sysctl -n hw.ncpu 2>/dev/null | awk '{ print "CPUs: " $0 }' || true
    sysctl -n hw.memsize 2>/dev/null | awk '{ printf "内存字节数: %s\n", $0 }' || true
    ;;
  *)
    echo "信息：未为 ${OS_NAME} 实现硬件摘要。"
    ;;
esac
echo

echo "信息：== 目标文件系统容量 =="
if command -v df >/dev/null 2>&1; then
  df -h "${TARGET_PATH}" || df -h || true
else
  echo "df command 不可用."
fi
echo

echo "信息：== Package manager availability =="
for tool in apt dnf yum rpm dpkg pacman zypper brew pkgutil; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: 可用，路径 %s\n' "${tool}" "$(command -v "${tool}")"
  else
    printf '%s: 不可用\n' "${tool}"
  fi
done
echo

echo "信息：== 已安装软件包摘要 =="
if command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -W -f='${binary:Package}\n' 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "已查看软件包数=%d\n", NR }' || true
elif command -v rpm >/dev/null 2>&1; then
  rpm -qa 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "已查看软件包数=%d\n", NR }' || true
elif command -v brew >/dev/null 2>&1; then
  brew list --versions 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "已查看软件包数=%d\n", NR }' || true
elif command -v pkgutil >/dev/null 2>&1; then
  pkgutil --pkgs 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "已查看软件包数=%d\n", NR }' || true
else
  echo "未找到受支持的 软件包清单命令。"
fi
echo

echo "信息：== Common operations tools =="
for tool in bash sh awk sed grep find tar gzip curl wget openssl ssh scp rsync systemctl service launchctl ip ifconfig netstat ss lsof jq yq kubectl helm; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: 可用\n' "${tool}"
  else
    printf '%s: 不可用\n' "${tool}"
  fi
done
