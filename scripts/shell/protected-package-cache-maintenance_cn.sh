#!/usr/bin/env bash
set -euo pipefail

CACHE_TARGET="${1:-${CACHE_TARGET:-}}"
CONFIRM_CLEAN="${2:-${CONFIRM_CLEAN:-}}"
CONFIRM_TOKEN="CLEAN_PACKAGE_CACHE"

if [[ -z "${CACHE_TARGET}" ]]; then
  echo "请设置 CACHE_TARGET，或传入一个软件包管理器目标：apt、dnf、yum、pacman、zypper 或 brew。"
  echo "信息：未执行软件包缓存清理。"
  exit 0
fi

case "${CACHE_TARGET}" in
  apt|dnf|yum|pacman|zypper|brew) ;;
  *)
    echo "信息：不支持的 CACHE_TARGET: ${CACHE_TARGET}" >&2
    echo "信息：支持的目标：apt、dnf、yum、pacman、zypper、brew" >&2
    exit 2
    ;;
esac

echo "受保护 package/cache maintenance plan"
echo "信息：Cache target: ${CACHE_TARGET}"
echo "默认操作：仅显示缓存信息"
echo "信息：真实清理可能移除缓存软件包，并减少离线回滚/重装选项。"
echo

show_cache_size() {
  case "${CACHE_TARGET}" in
    apt)
      du -sh /var/cache/apt 2>/dev/null || echo "信息：无法读取 /var/cache/apt。"
      ;;
    dnf)
      du -sh /var/cache/dnf 2>/dev/null || echo "信息：无法读取 /var/cache/dnf。"
      ;;
    yum)
      du -sh /var/cache/yum 2>/dev/null || echo "信息：无法读取 /var/cache/yum。"
      ;;
    pacman)
      du -sh /var/cache/pacman/pkg 2>/dev/null || echo "信息：无法读取 /var/cache/pacman/pkg。"
      ;;
    zypper)
      du -sh /var/cache/zypp 2>/dev/null || echo "信息：无法读取 /var/cache/zypp。"
      ;;
    brew)
      if command -v brew >/dev/null 2>&1; then
        brew --cache | while IFS= read -r cache_dir; do
          du -sh "${cache_dir}" 2>/dev/null || echo "信息：无法读取 ${cache_dir}。"
        done
        brew cleanup -n || true
      else
        echo "brew command 不可用."
      fi
      ;;
  esac
}

echo "信息：== Cache size / cleanup preview =="
show_cache_size
echo

if [[ "${CONFIRM_CLEAN}" != "${CONFIRM_TOKEN}" ]]; then
  echo "信息：仅预览。未执行软件包缓存清理。"
  echo "信息：要清理所选缓存，请重新运行并设置 CONFIRM_CLEAN=${CONFIRM_TOKEN}."
  exit 0
fi

case "${CACHE_TARGET}" in
  apt)
    command -v apt-get >/dev/null 2>&1 || { echo "apt-get 不可用." >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 apt-get autoclean。"
    apt-get autoclean
    ;;
  dnf)
    command -v dnf >/dev/null 2>&1 || { echo "dnf 不可用." >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 dnf clean packages。"
    dnf clean packages
    ;;
  yum)
    command -v yum >/dev/null 2>&1 || { echo "yum 不可用." >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 yum clean packages。"
    yum clean packages
    ;;
  pacman)
    command -v paccache >/dev/null 2>&1 || { echo "paccache 不可用; 请安装 pacman-contrib 以执行受保护的缓存清理。" >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 paccache -r。"
    paccache -r
    ;;
  zypper)
    command -v zypper >/dev/null 2>&1 || { echo "zypper 不可用." >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 zypper clean。"
    zypper clean
    ;;
  brew)
    command -v brew >/dev/null 2>&1 || { echo "brew 不可用." >&2; exit 1; }
    echo "信息：确认令牌已接受。正在运行 brew cleanup。"
    brew cleanup
    ;;
esac
