#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
LOCK_FIX_ACTION="${LOCK_FIX_ACTION:-audit}"
TARGET_LOCK_FIX_SCOPE="${TARGET_LOCK_FIX_SCOPE:-}"
TARGET_LOCK_FILE="${TARGET_LOCK_FILE:-}"
CONFIRM_LOCK_FIX="${CONFIRM_LOCK_FIX:-}"

if [ "$PACKAGE_MANAGER" = "auto" ]; then
  if command -v dpkg >/dev/null 2>&1; then PACKAGE_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1; then PACKAGE_MANAGER="dnf"
  elif command -v yum >/dev/null 2>&1; then PACKAGE_MANAGER="yum"
  elif command -v pacman >/dev/null 2>&1; then PACKAGE_MANAGER="pacman"
  elif command -v apk >/dev/null 2>&1; then PACKAGE_MANAGER="apk"
  elif command -v zypper >/dev/null 2>&1; then PACKAGE_MANAGER="zypper"
  else PACKAGE_MANAGER="unsupported"; fi
fi

echo "信息：== 受保护软件包锁/事务修复计划 =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：LOCK_FIX_ACTION=$LOCK_FIX_ACTION"
echo "信息：TARGET_LOCK_FIX_SCOPE=$TARGET_LOCK_FIX_SCOPE"
echo "信息：TARGET_LOCK_FILE=$TARGET_LOCK_FILE"
echo
echo "信息：Active package manager processes:"
ps -eo pid,ppid,user,comm,args 2>/dev/null | grep -E '[a]pt|[d]pkg|[d]nf|[y]um|[r]pm|[p]acman|[a]pk|[z]ypper' | sed -n '1,40p' || true

if [ -n "$TARGET_LOCK_FILE" ] && [ -e "$TARGET_LOCK_FILE" ]; then
  ls -l "$TARGET_LOCK_FILE" 2>/dev/null || true
  if command -v lsof >/dev/null 2>&1; then lsof "$TARGET_LOCK_FILE" 2>/dev/null | sed -n '1,20p' || true; fi
fi

case "$PACKAGE_MANAGER" in
  apt) dpkg --audit 2>/dev/null || true; echo "信息：确认没有活动进程后的潜在修复：sudo dpkg --configure -a" ;;
  dnf) dnf history list 2>/dev/null | sed -n '1,20p' || true; echo "信息：潜在修复：sudo dnf history sync，或备份后运行 sudo rpm --rebuilddb" ;;
  yum) yum history list 2>/dev/null | sed -n '1,20p' || true; echo "信息：潜在修复: sudo yum-complete-transaction 如果可用则运行；或在备份后恢复 rpmdb" ;;
  pacman) echo "信息：确认没有活动进程后的潜在修复：sudo rm /var/lib/pacman/db.lck" ;;
  apk) echo "信息：确认没有活动进程后的潜在修复：移除过期 apk 锁，并仅在审核后重新运行 apk fix" ;;
  zypper) echo "信息：确认没有活动进程后的潜在修复：sudo zypper ps；检查 /var/run/zypp.pid" ;;
  *) echo "信息：不支持的软件包管理器；仅执行审计。" ;;
esac

if [ -z "$TARGET_LOCK_FIX_SCOPE" ]; then
  echo
  echo "信息：拒绝自动修复：请显式设置 TARGET_LOCK_FIX_SCOPE，例如 TARGET_LOCK_FIX_SCOPE=dpkg-configure 或 TARGET_LOCK_FIX_SCOPE=pacman-lock-file。"
  echo "请设置 LOCK_FIX_ACTION and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK 仅在确认没有活动的软件包管理器进程且备份可用后。"
  exit 0
fi

if [ "$CONFIRM_LOCK_FIX" != "FIX_PACKAGE_LOCK" ]; then
  echo
  echo "仅试运行。 请设置 TARGET_LOCK_FIX_SCOPE, LOCK_FIX_ACTION, and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK 仅在确认没有活动的软件包管理器进程且备份可用后。"
  exit 0
fi

case "$PACKAGE_MANAGER:$LOCK_FIX_ACTION:$TARGET_LOCK_FIX_SCOPE" in
  apt:configure:dpkg-configure) sudo dpkg --configure -a ;;
  pacman:remove-lock:pacman-lock-file)
    if [ "$TARGET_LOCK_FILE" != "/var/lib/pacman/db.lck" ]; then
      echo "信息：除非 TARGET_LOCK_FILE=/var/lib/pacman/db.lck，否则拒绝移除 pacman 锁。"
      exit 0
    fi
    sudo rm -i "$TARGET_LOCK_FILE"
    ;;
  *) echo "信息：此 PACKAGE_MANAGER/LOCK_FIX_ACTION 组合没有自动修复；请手动执行已复核的恢复步骤。" ;;
esac
