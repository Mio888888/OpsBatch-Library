#!/usr/bin/env bash
set -euo pipefail

DAYS_BACK="${1:-${DAYS_BACK:-1}}"
MAX_EVENTS="${2:-${MAX_EVENTS:-20}}"

if [[ ! "${DAYS_BACK}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：DAYS_BACK must be a positive integer." >&2
  exit 2
fi

if [[ ! "${MAX_EVENTS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：MAX_EVENTS must be a positive integer." >&2
  exit 2
fi

POWERSHELL=""
if command -v pwsh >/dev/null 2>&1; then
  POWERSHELL="$(command -v pwsh)"
elif command -v powershell.exe >/dev/null 2>&1; then
  POWERSHELL="$(command -v powershell.exe)"
elif command -v powershell >/dev/null 2>&1; then
  POWERSHELL="$(command -v powershell)"
fi

if [[ -z "${POWERSHELL}" ]]; then
  echo "PowerShell executable 未找到. Run this shell script from a Windows host with pwsh or Windows PowerShell available.（PowerShell executable not found. Run this shell script from a Windows host with pwsh or Windows PowerShell available.）" >&2
  exit 1
fi

echo "信息：Windows maintenance status summary"
echo "信息：Days back: ${DAYS_BACK}"
echo "信息：Max events: ${MAX_EVENTS}"
echo "信息：This script is read-only and does not install updates, clear logs, restart services, or modify tasks."
echo

"${POWERSHELL}" -NoProfile -Command '
param([int]$DaysBack, [int]$MaxEvents)
$ErrorActionPreference = "SilentlyContinue"
$services = "wuauserv", "bits", "cryptsvc"
$serviceStatus = foreach ($name in $services) {
  $svc = Get-Service -Name $name
  if ($svc) {
    [PSCustomObject]@{ Type = "Service"; Name = $svc.Name; DisplayName = $svc.DisplayName; Status = [string]$svc.Status }
  } else {
    [PSCustomObject]@{ Type = "Service"; Name = $name; DisplayName = ""; Status = "NotFound" }
  }
}
$startTime = (Get-Date).AddDays(-1 * $DaysBack)
$events = Get-WinEvent -FilterHashtable @{ LogName = "System"; StartTime = $startTime } -MaxEvents $MaxEvents | ForEach-Object {
  [PSCustomObject]@{ Type = "Event"; TimeCreated = $_.TimeCreated; ProviderName = $_.ProviderName; Id = $_.Id; LevelDisplayName = $_.LevelDisplayName }
}
$tasks = Get-ScheduledTask | Select-Object -First 20 | ForEach-Object {
  [PSCustomObject]@{ Type = "ScheduledTask"; TaskName = $_.TaskName; TaskPath = $_.TaskPath; State = [string]$_.State }
}
[PSCustomObject]@{
  GeneratedAt = (Get-Date).ToUniversalTime().ToString("o")
  Services = @($serviceStatus)
  RecentSystemEvents = @($events)
  ScheduledTaskSample = @($tasks)
} | ConvertTo-Json -Depth 5
' "${DAYS_BACK}" "${MAX_EVENTS}"
