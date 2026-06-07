#!/usr/bin/env bash
set -euo pipefail

echo "信息：== security update hints =="
echo "信息：This command uses local package manager information where possible and does not install updates."

if command -v apt >/dev/null 2>&1; then
  echo "信息：-- apt security-related upgradable entries --"
  apt list --upgradable 2>/dev/null | grep -Ei 'security|ubuntu[/-].*-security|debian-security' | sed -n '1,80p' || true
fi

if command -v dnf >/dev/null 2>&1; then
  echo "信息：-- dnf updateinfo security --"
  dnf updateinfo list security 2>/dev/null | sed -n '1,80p' || true
elif command -v yum >/dev/null 2>&1; then
  echo "信息：-- yum updateinfo security --"
  yum updateinfo list security 2>/dev/null | sed -n '1,80p' || true
fi

if command -v zypper >/dev/null 2>&1; then
  echo "信息：-- zypper security patches --"
  zypper --non-interactive list-patches --category security 2>/dev/null | sed -n '1,80p' || true
fi

if command -v apk >/dev/null 2>&1; then
  echo "信息：-- apk audit note --"
  echo "Alpine security status usually 需要 comparing apk versions with advisory feeds; not querying network here.（Alpine security status usually requires comparing apk versions with advisory feeds; not querying network here.）"
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew outdated casks/formulae (security triage input) --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
