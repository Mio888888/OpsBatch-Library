#!/usr/bin/env bash
set -euo pipefail

echo "== security update hints =="
echo "This command uses local package manager information where possible and does not install updates."

if command -v apt >/dev/null 2>&1; then
  echo "-- apt security-related upgradable entries --"
  apt list --upgradable 2>/dev/null | grep -Ei 'security|ubuntu[/-].*-security|debian-security' | sed -n '1,80p' || true
fi

if command -v dnf >/dev/null 2>&1; then
  echo "-- dnf updateinfo security --"
  dnf updateinfo list security 2>/dev/null | sed -n '1,80p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "-- yum updateinfo security --"
  yum updateinfo list security 2>/dev/null | sed -n '1,80p' || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "-- zypper security patches --"
  zypper --non-interactive list-patches --category security 2>/dev/null | sed -n '1,80p' || true
fi

if command -v apk >/dev/null 2>&1; then
  echo "-- apk audit note --"
  echo "Alpine security status usually requires comparing apk versions with advisory feeds; not querying network here."
fi

if command -v brew >/dev/null 2>&1; then
  echo "-- brew outdated casks/formulae (security triage input) --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
