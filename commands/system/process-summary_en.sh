#!/usr/bin/env bash
set -euo pipefail

echo "Process count: $(ps -A -o pid= 2>/dev/null | wc -l | tr -d ' ')"
echo "Top processes by CPU:"
ps aux | sort -nrk 3 | head -10
echo "Top processes by memory:"
ps aux | sort -nrk 4 | head -10
