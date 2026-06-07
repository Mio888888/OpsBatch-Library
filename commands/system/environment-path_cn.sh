#!/usr/bin/env bash
set -euo pipefail

echo "信息：PATH entries:"
printf '%s\n' "$PATH" | tr ':' '\n'
echo "信息：Selected environment variables:"
env | sort | grep -E '^(SHELL|USER|HOME|LANG|LC_|TERM|PATH|PWD)=' || true
