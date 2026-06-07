#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"

echo "信息：== 常见 Web 服务器日志 =="
found="false"
for file in \
  /var/log/nginx/error.log \
  /var/log/nginx/access.log \
  /var/log/apache2/error.log \
  /var/log/apache2/access.log \
  /var/log/httpd/error_log \
  /var/log/httpd/access_log; do
  if [ -f "$file" ]; then
    found="true"
    echo
    echo "信息：-- $file --"
    tail -n "$LINES" "$file" 2>/dev/null || echo "无法读取 $file; 请检查权限。"
  fi
done

if [ "$found" != "true" ]; then
  echo "未找到常见的 Nginx/Apache 日志文件。自定义路径请设置 LOG_FILE 并使用 application-log-tail 命令。"
fi
