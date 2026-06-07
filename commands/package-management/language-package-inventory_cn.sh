#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "信息：== language ecosystem 软件包清单 (limit: $LIMIT) =="

if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
  PIP_BIN="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)"
  echo "信息：-- pip packages --"
  "$PIP_BIN" list 2>/dev/null | sed -n '1,80p' || true
  echo "信息：-- pip outdated check note --"
  echo "信息：未运行 pip list --outdated，因为它可能查询软件包索引。"
else
  echo "pip 未找到"
fi

if command -v npm >/dev/null 2>&1; then
  echo "信息：-- npm global packages --"
  npm list -g --depth=0 2>/dev/null | sed -n '1,80p' || true
  echo "信息：-- npm project packages --"
  if [ -r package.json ]; then
    npm list --depth=0 2>/dev/null | sed -n '1,80p' || true
  else
    echo "信息：当前目录中没有 package.json；跳过项目软件包列表。"
  fi
else
  echo "npm 未找到"
fi
