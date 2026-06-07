#!/usr/bin/env bash
set -euo pipefail

FILE_LIST="${FILE_LIST:-/etc/passwd /etc/group /etc/hosts /etc/sudoers /etc/ssh/sshd_config}"

echo "信息：== file metadata and hashes =="
for path in $FILE_LIST; do
  if [ -e "$path" ]; then
    echo "信息：-- $path --"
    ls -ld "$path" 2>/dev/null || true
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$path" 2>/dev/null || true
    elif command -v shasum >/dev/null 2>&1; then
      shasum -a 256 "$path" 2>/dev/null || true
    else
      echo "信息：未找到 sha256 工具。"
    fi
  else
    echo "信息：缺失： $path"
  fi
done

echo
echo "请将 FILE_LIST 设置为以空格分隔、需要建立基线的文件白名单。除非输出处理流程已获批准，否则不要包含私钥。"
