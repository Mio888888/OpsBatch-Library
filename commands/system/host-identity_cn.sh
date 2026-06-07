#!/usr/bin/env bash
set -euo pipefail

echo "信息：Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "信息：FQDN: $(hostname -f 2>/dev/null || hostname 2>/dev/null || echo unknown)"
echo "信息：Current user: $(whoami 2>/dev/null || id -un 2>/dev/null || echo unknown)"
echo "信息：User id: $(id 2>/dev/null || echo unavailable)"
