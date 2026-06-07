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

echo "信息：== protected package lock/transaction fix plan =="
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
  apt) dpkg --audit 2>/dev/null || true; echo "信息：Potential fix after no active process: sudo dpkg --configure -a" ;;
  dnf) dnf history list 2>/dev/null | sed -n '1,20p' || true; echo "信息：Potential fix: sudo dnf history sync or sudo rpm --rebuilddb after backup" ;;
  yum) yum history list 2>/dev/null | sed -n '1,20p' || true; echo "信息：Potential fix: sudo yum-complete-transaction if available, or rpmdb recovery after backup" ;;
  pacman) echo "信息：Potential fix after no active process: sudo rm /var/lib/pacman/db.lck" ;;
  apk) echo "信息：Potential fix after no active process: remove stale apk lock and rerun apk fix only after review" ;;
  zypper) echo "信息：Potential fix after no active process: sudo zypper ps; inspect /var/run/zypp.pid" ;;
  *) echo "信息：Unsupported package manager; audit only." ;;
esac

if [ -z "$TARGET_LOCK_FIX_SCOPE" ]; then
  echo
  echo "信息：Refusing automated repair: set TARGET_LOCK_FIX_SCOPE explicitly, for example TARGET_LOCK_FIX_SCOPE=dpkg-configure or TARGET_LOCK_FIX_SCOPE=pacman-lock-file."
  echo "请设置 LOCK_FIX_ACTION and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK only after proving no package manager process is active and backups are available.（Set LOCK_FIX_ACTION and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK only after proving no package manager process is active and backups are available.）"
  exit 0
fi

if [ "$CONFIRM_LOCK_FIX" != "FIX_PACKAGE_LOCK" ]; then
  echo
  echo "仅试运行。 请设置 TARGET_LOCK_FIX_SCOPE, LOCK_FIX_ACTION, and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK only after proving no package manager process is active and backups are available.（Dry-run only. Set TARGET_LOCK_FIX_SCOPE, LOCK_FIX_ACTION, and CONFIRM_LOCK_FIX=FIX_PACKAGE_LOCK only after proving no package manager process is active and backups are available.）"
  exit 0
fi

case "$PACKAGE_MANAGER:$LOCK_FIX_ACTION:$TARGET_LOCK_FIX_SCOPE" in
  apt:configure:dpkg-configure) sudo dpkg --configure -a ;;
  pacman:remove-lock:pacman-lock-file)
    if [ "$TARGET_LOCK_FILE" != "/var/lib/pacman/db.lck" ]; then
      echo "信息：Refusing pacman lock removal unless TARGET_LOCK_FILE=/var/lib/pacman/db.lck"
      exit 0
    fi
    sudo rm -i "$TARGET_LOCK_FILE"
    ;;
  *) echo "信息：No automated fix for this PACKAGE_MANAGER/LOCK_FIX_ACTION combination; perform the reviewed recovery manually." ;;
esac
