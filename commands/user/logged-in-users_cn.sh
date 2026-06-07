#!/usr/bin/env bash
set -euo pipefail

echo "信息：当前用户: $(whoami 2>/dev/null || echo 未知)"
echo "信息：已登录会话:"
who 2>/dev/null || w -h 2>/dev/null || echo "未找到受支持的 会话命令。"
echo "信息：最近登录摘要:"
last -n 5 2>/dev/null || echo "信息：近期登录历史不可用。"
