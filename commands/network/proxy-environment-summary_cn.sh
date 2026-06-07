#!/usr/bin/env bash
set -euo pipefail

echo "信息：== proxy-related environment variables =="
env | grep -Ei '^(http_proxy|https_proxy|all_proxy|no_proxy|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)=' | sort || echo "信息：No proxy environment variables found."

if [ "$(uname -s)" = "Darwin" ] && command -v scutil >/dev/null 2>&1; then
  echo
  echo "信息：== macOS proxy configuration summary =="
  scutil --proxy
fi
