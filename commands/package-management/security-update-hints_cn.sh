#!/usr/bin/env bash
set -euo pipefail

echo "信息：== security update hints =="
echo "信息：此命令尽量使用本地软件包管理器信息，不会安装更新。"

if command -v apt >/dev/null 2>&1; then
  echo "信息：-- apt 安全相关可升级条目 --"
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
  echo "Alpine 安全状态通常需要将 apk 版本与公告源比较；此处不查询网络。"
fi

if command -v brew >/dev/null 2>&1; then
  echo "信息：-- brew 过期 cask/formula（安全分诊输入） --"
  HOMEBREW_NO_AUTO_UPDATE=1 brew outdated 2>/dev/null | sed -n '1,80p' || true
fi
