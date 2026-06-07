#!/usr/bin/env bash
set -euo pipefail

echo "信息：== current user crontab =="
crontab -l 2>/dev/null || echo "信息：No readable current-user crontab."

echo
echo "信息：== system cron directories =="
for path in /etc/crontab /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
  [ -e "$path" ] && { echo "信息：-- $path --"; ls -la "$path" 2>/dev/null | head -80; } || true
done

if [ "$(uname -s)" = "Linux" ]; then
  if command -v systemctl >/dev/null 2>&1; then
    echo
    echo "信息：== enabled systemd units =="
    systemctl list-unit-files --state=enabled 2>/dev/null | head -120 || true
    echo
    echo "信息：== timers =="
    systemctl list-timers --all 2>/dev/null | head -120 || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "信息：== launch agents and daemons =="
  for path in /Library/LaunchAgents /Library/LaunchDaemons /System/Library/LaunchAgents /System/Library/LaunchDaemons "$HOME/Library/LaunchAgents"; do
    [ -d "$path" ] && { echo "信息：-- $path --"; ls -la "$path" 2>/dev/null | head -80; } || true
  done
fi
