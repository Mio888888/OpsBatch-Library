#!/usr/bin/env bash
set -euo pipefail

echo "信息：Process count: $(ps -A -o pid= 2>/dev/null | wc -l | tr -d ' ')"
echo "信息：Top processes by CPU:"
ps aux | sort -nrk 3 | head -10
echo "信息：Top processes by memory:"
ps aux | sort -nrk 4 | head -10
