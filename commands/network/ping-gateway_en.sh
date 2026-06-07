#!/usr/bin/env bash
set -euo pipefail

ping -c 4 ${GATEWAY:-192.168.1.1}
