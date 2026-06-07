#!/usr/bin/env bash
set -euo pipefail

echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "FQDN: $(hostname -f 2>/dev/null || hostname 2>/dev/null || echo unknown)"
echo "Current user: $(whoami 2>/dev/null || id -un 2>/dev/null || echo unknown)"
echo "User id: $(id 2>/dev/null || echo unavailable)"
