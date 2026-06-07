#!/usr/bin/env bash
set -euo pipefail

echo "Current user: $(whoami 2>/dev/null || echo unknown)"
echo "Logged-in sessions:"
who 2>/dev/null || w -h 2>/dev/null || echo "No supported session command found."
echo "Recent login summary:"
last -n 5 2>/dev/null || echo "Recent login history unavailable."
