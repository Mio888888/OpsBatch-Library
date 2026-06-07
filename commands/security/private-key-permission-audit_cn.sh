#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${SCAN_ROOT:-/etc/ssh}"
LIMIT="${LIMIT:-100}"

echo "正在扫描 疑似密钥文件元数据，扫描位置： $SCAN_ROOT. 本命令只打印元数据，不打印密钥内容。"
if [ ! -d "$SCAN_ROOT" ]; then
  echo "目录未找到: $SCAN_ROOT"
  exit 0
fi

echo
echo "信息：== 私钥候选文件元数据 =="
find "$SCAN_ROOT" -xdev -type f \( -name '*_key' -o -name '*.key' -o -name 'id_rsa' -o -name 'id_ed25519' -o -name 'id_ecdsa' \) -exec ls -l {} + 2>/dev/null | head -n "$LIMIT"

echo
echo "信息：== files with broad read permissions =="
find "$SCAN_ROOT" -xdev -type f \( -name '*_key' -o -name '*.key' -o -name 'id_rsa' -o -name 'id_ed25519' -o -name 'id_ecdsa' \) \( -perm -004 -o -perm -040 \) -print 2>/dev/null | head -n "$LIMIT"
