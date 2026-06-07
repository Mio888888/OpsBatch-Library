#!/usr/bin/env bash
set -euo pipefail

TOP_LIMIT="${TOP_LIMIT:-30}"

echo "信息：== 已建立远程连接计数 =="
if command -v ss >/dev/null 2>&1; then
  ss -tunp state established 2>/dev/null | awk 'NR>1 {print $5}' | sed 's/^\[//; s/\]$//; s/:[^:]*$//' | sort | uniq -c | sort -nr | head -n "$TOP_LIMIT"
elif command -v netstat >/dev/null 2>&1; then
  netstat -an 2>/dev/null | awk '/ESTABLISHED/ {print $5}' | sed 's/^\[//; s/\]$//; s/\.[0-9][0-9]*$//' | sort | uniq -c | sort -nr | head -n "$TOP_LIMIT"
else
  echo "未找到受支持的连接列举工具。"
fi

echo
echo "信息：== 非常见高风险服务端口连接 =="
if command -v ss >/dev/null 2>&1; then
  ss -tunp 2>/dev/null | grep -E ':(22|23|3389|5900|6379|9200|9300|11211|27017|3306|5432)[[:space:]]' | head -80 || true
elif command -v lsof >/dev/null 2>&1; then
  lsof -nP -i 2>/dev/null | grep -E ':(22|23|3389|5900|6379|9200|9300|11211|27017|3306|5432)' | head -80 || true
fi

echo
echo "信息：仅供审核：高连接数或敏感服务端口只是调查线索，不是入侵证明。"
