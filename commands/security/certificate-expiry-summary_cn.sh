#!/usr/bin/env bash
set -euo pipefail

CERT_PATH="${CERT_PATH:-}"
CERT_DIR="${CERT_DIR:-/etc/ssl /etc/pki/tls /etc/letsencrypt/live}"
LIMIT="${LIMIT:-80}"

check_cert() {
  cert="$1"
  [ -f "$cert" ] || return 0
  if command -v openssl >/dev/null 2>&1; then
    echo "信息：-- $cert --"
    openssl x509 -in "$cert" -noout -subject -issuer -dates -fingerprint -sha256 2>/dev/null || true
  else
    echo "openssl 未找到."
    return 1
  fi
}

if [ -n "$CERT_PATH" ]; then
  check_cert "$CERT_PATH"
  exit 0
fi

echo "信息：== 常见目录下的证书文件 =="
count=0
for dir in $CERT_DIR; do
  [ -d "$dir" ] || continue
  find "$dir" -type f \( -name '*.crt' -o -name '*.pem' -o -name '*.cer' \) -print 2>/dev/null | while IFS= read -r cert; do
    check_cert "$cert"
  done
  count=$((count + 1))
  [ "$count" -ge "$LIMIT" ] && break
done
