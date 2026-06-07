#!/usr/bin/env bash
set -euo pipefail

TARGET_LOG_DIR="${TARGET_LOG_DIR:-/var/log}"
MIN_SIZE="${MIN_SIZE:-50M}"
MAX_DEPTH="${MAX_DEPTH:-3}"

echo "信息：== 日志增长候选项 =="
echo "信息：目录： $TARGET_LOG_DIR"
echo "信息：最小大小： $MIN_SIZE"

if [ ! -d "$TARGET_LOG_DIR" ]; then
  echo "信息：TARGET_LOG_DIR 不是目录: $TARGET_LOG_DIR"
  exit 0
fi

echo
echo "信息：-- 目录使用率 --"
du -sh "$TARGET_LOG_DIR" 2>/dev/null || true
if du -xh -d 1 "$TARGET_LOG_DIR" >/dev/null 2>&1; then
  du -xh -d 1 "$TARGET_LOG_DIR" 2>/dev/null | sort -hr | head -30 || true
else
  du -xh "$TARGET_LOG_DIR"/* 2>/dev/null | sort -hr | head -30 || true
fi

echo
echo "信息：-- 大型类日志文件 --"
if find "$TARGET_LOG_DIR" -xdev -maxdepth "$MAX_DEPTH" -type f -name '*.log' -size +"$MIN_SIZE" -print >/dev/null 2>&1; then
  find "$TARGET_LOG_DIR" -xdev -maxdepth "$MAX_DEPTH" -type f \
    \( -name '*.log' -o -name '*.log.*' -o -name '*.out' -o -name '*.err' -o -name 'messages*' -o -name 'syslog*' \) \
    -size +"$MIN_SIZE" -print 2>/dev/null | head -100
else
  echo "信息：此平台的 find 可能不支持 -maxdepth 或大小后缀 $MIN_SIZE；改为列出最大的类日志文件。"
  find "$TARGET_LOG_DIR" -xdev -type f \
    \( -name '*.log' -o -name '*.log.*' -o -name '*.out' -o -name '*.err' -o -name 'messages*' -o -name 'syslog*' \) \
    -print 2>/dev/null | head -200 | while IFS= read -r file; do
      du -h "$file" 2>/dev/null || true
    done | sort -hr | head -100
fi

echo
echo "信息：此命令只列出候选项，不会修改日志。"
