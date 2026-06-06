#!/usr/bin/env bash
set -euo pipefail

CACHE_TARGET="${1:-${CACHE_TARGET:-}}"
CONFIRM_CLEAN="${2:-${CONFIRM_CLEAN:-}}"
CONFIRM_TOKEN="CLEAN_PACKAGE_CACHE"

if [[ -z "${CACHE_TARGET}" ]]; then
  echo "Set CACHE_TARGET or pass one package manager target: apt, dnf, yum, pacman, zypper, or brew."
  echo "No package cache cleanup was performed."
  exit 0
fi

case "${CACHE_TARGET}" in
  apt|dnf|yum|pacman|zypper|brew) ;;
  *)
    echo "Unsupported CACHE_TARGET: ${CACHE_TARGET}" >&2
    echo "Supported targets: apt, dnf, yum, pacman, zypper, brew" >&2
    exit 2
    ;;
esac

echo "Protected package/cache maintenance plan"
echo "Cache target: ${CACHE_TARGET}"
echo "Default action: display cache information only"
echo "Real cleanup may remove cached packages and reduce offline rollback/reinstall options."
echo

show_cache_size() {
  case "${CACHE_TARGET}" in
    apt)
      du -sh /var/cache/apt 2>/dev/null || echo "Unable to read /var/cache/apt."
      ;;
    dnf)
      du -sh /var/cache/dnf 2>/dev/null || echo "Unable to read /var/cache/dnf."
      ;;
    yum)
      du -sh /var/cache/yum 2>/dev/null || echo "Unable to read /var/cache/yum."
      ;;
    pacman)
      du -sh /var/cache/pacman/pkg 2>/dev/null || echo "Unable to read /var/cache/pacman/pkg."
      ;;
    zypper)
      du -sh /var/cache/zypp 2>/dev/null || echo "Unable to read /var/cache/zypp."
      ;;
    brew)
      if command -v brew >/dev/null 2>&1; then
        brew --cache | while IFS= read -r cache_dir; do
          du -sh "${cache_dir}" 2>/dev/null || echo "Unable to read ${cache_dir}."
        done
        brew cleanup -n || true
      else
        echo "brew command not available."
      fi
      ;;
  esac
}

echo "== Cache size / cleanup preview =="
show_cache_size
echo

if [[ "${CONFIRM_CLEAN}" != "${CONFIRM_TOKEN}" ]]; then
  echo "Preview only. No package cache cleanup was performed."
  echo "To clean the selected cache, rerun with CONFIRM_CLEAN=${CONFIRM_TOKEN}."
  exit 0
fi

case "${CACHE_TARGET}" in
  apt)
    command -v apt-get >/dev/null 2>&1 || { echo "apt-get not available." >&2; exit 1; }
    echo "Confirmation token accepted. Running apt-get autoclean."
    apt-get autoclean
    ;;
  dnf)
    command -v dnf >/dev/null 2>&1 || { echo "dnf not available." >&2; exit 1; }
    echo "Confirmation token accepted. Running dnf clean packages."
    dnf clean packages
    ;;
  yum)
    command -v yum >/dev/null 2>&1 || { echo "yum not available." >&2; exit 1; }
    echo "Confirmation token accepted. Running yum clean packages."
    yum clean packages
    ;;
  pacman)
    command -v paccache >/dev/null 2>&1 || { echo "paccache not available; install pacman-contrib for guarded cache cleanup." >&2; exit 1; }
    echo "Confirmation token accepted. Running paccache -r."
    paccache -r
    ;;
  zypper)
    command -v zypper >/dev/null 2>&1 || { echo "zypper not available." >&2; exit 1; }
    echo "Confirmation token accepted. Running zypper clean."
    zypper clean
    ;;
  brew)
    command -v brew >/dev/null 2>&1 || { echo "brew not available." >&2; exit 1; }
    echo "Confirmation token accepted. Running brew cleanup."
    brew cleanup
    ;;
esac
