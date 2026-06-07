#!/usr/bin/env bash
set -euo pipefail
# 中文说明：此脚本与英文版本保持相同执行逻辑，仅保留中文本地化说明。

ping -c 4 ${GATEWAY:-192.168.1.1}
