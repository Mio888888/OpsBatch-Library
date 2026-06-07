#!/usr/bin/env bash
set -euo pipefail

echo "信息：== package manager locks and transactions =="

echo "信息：-- running package manager processes --"
ps -eo pid,ppid,user,comm,args 2>/dev/null | grep -E '[a]pt|[d]pkg|[d]nf|[y]um|[r]pm|[p]acman|[a]pk|[z]ypper|[b]rew|[s]oftwareupdate' | sed -n '1,40p' || true

echo "信息：-- common lock files --"
for file in \
  /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend /var/cache/apt/archives/lock \
  /var/lib/rpm/.rpm.lock /var/lib/dnf/rpmdb_lock.pid /var/run/yum.pid \
  /var/lib/pacman/db.lck /var/lock/apk-tools.lock /var/run/zypp.pid; do
  [ -e "$file" ] || continue
  ls -l "$file" 2>/dev/null || true
  if command -v fuser >/dev/null 2>&1; then
    fuser "$file" 2>/dev/null || true
  elif command -v lsof >/dev/null 2>&1; then
    lsof "$file" 2>/dev/null | sed -n '1,10p' || true
  fi
done

if command -v dpkg >/dev/null 2>&1; then
  echo "信息：-- dpkg audit --"
  dpkg --audit 2>/dev/null || true
fi
if command -v dnf >/dev/null 2>&1; then
  echo "信息：-- dnf history recent --"
  dnf history list 2>/dev/null | sed -n '1,20p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "信息：-- yum history recent --"
  yum history list 2>/dev/null | sed -n '1,20p' || true
fi
