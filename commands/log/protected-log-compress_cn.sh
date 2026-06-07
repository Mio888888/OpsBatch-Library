#!/usr/bin/env bash
set -euo pipefail

TARGET_LOG_DIR="${TARGET_LOG_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"
CONFIRM_COMPRESS="${CONFIRM_COMPRESS:-}"

if [ -z "$TARGET_LOG_DIR" ]; then
  echo "拒绝执行： 请显式设置 TARGET_LOG_DIR，例如 TARGET_LOG_DIR=/var/log/myapp。"
  exit 0
fi

if [ ! -d "$TARGET_LOG_DIR" ]; then
  echo "信息：TARGET_LOG_DIR 不是目录: $TARGET_LOG_DIR"
  exit 0
fi

echo "信息：== $TARGET_LOG_DIR 中早于 $OLDER_THAN_DAYS 天的未压缩轮转日志候选项 =="
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.[0-9]*' -o -name '*.out.[0-9]*' -o -name '*.err.[0-9]*' -o -name '*.old' \) \
  ! -name '*.gz' ! -name '*.zip' ! -name '*.xz' ! -name '*.bz2' \
  -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100

if [ "$CONFIRM_COMPRESS" != "COMPRESS_OLD_LOGS" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_COMPRESS=COMPRESS_OLD_LOGS ，在复核备份、保留策略和活动写入者后 gzip 压缩匹配的轮转文件。"
  exit 0
fi

echo
echo "信息：正在压缩匹配的旧轮转日志。使用前请复核活动写入者和保留策略。"
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.[0-9]*' -o -name '*.out.[0-9]*' -o -name '*.err.[0-9]*' -o -name '*.old' \) \
  ! -name '*.gz' ! -name '*.zip' ! -name '*.xz' ! -name '*.bz2' \
  -mtime +"$OLDER_THAN_DAYS" -exec gzip -v {} \;
