#!/usr/bin/env bash
set -euo pipefail

echo "信息：Current user: $(whoami 2>/dev/null || echo unknown)"
echo "信息：Logged-in sessions:"
who 2>/dev/null || w -h 2>/dev/null || echo "未找到受支持的 session command found.（No supported session command found.）"
echo "信息：Recent login summary:"
last -n 5 2>/dev/null || echo "信息：Recent login history unavailable."
