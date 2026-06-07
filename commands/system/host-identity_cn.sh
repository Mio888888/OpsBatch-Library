#!/usr/bin/env bash
set -euo pipefail

echo "信息：Hostname: $(hostname 2>/dev/null || echo 未知)"
echo "信息：FQDN: $(hostname -f 2>/dev/null || hostname 2>/dev/null || echo 未知)"
echo "信息：当前用户: $(whoami 2>/dev/null || id -un 2>/dev/null || echo 未知)"
echo "信息：用户 ID: $(id 2>/dev/null || echo 不可用)"
