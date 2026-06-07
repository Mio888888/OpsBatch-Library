#!/usr/bin/env bash
set -euo pipefail

echo "PATH entries:"
printf '%s\n' "$PATH" | tr ':' '\n'
echo "Selected environment variables:"
env | sort | grep -E '^(SHELL|USER|HOME|LANG|LC_|TERM|PATH|PWD)=' || true
