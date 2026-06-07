#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"

echo "信息：== common web server logs =="
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
    tail -n "$LINES" "$file" 2>/dev/null || echo "无法读取 $file; check permissions.（Cannot read $file; check permissions.）"
  fi
done

if [ "$found" != "true" ]; then
  echo "No common Nginx/Apache log file found. 请设置 LOG_FILE and use the application-log-tail command for custom paths.（No common Nginx/Apache log file found. Set LOG_FILE and use the application-log-tail command for custom paths.）"
fi
