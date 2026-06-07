#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${1:-${SCAN_ROOT:-${HOME:-/tmp}}}"
CERT_PATH="${2:-${CERT_PATH:-}}"
LIMIT="${LIMIT:-30}"

if [[ ! -d "${SCAN_ROOT}" ]]; then
  echo "信息：SCAN_ROOT 必须是已存在目录: ${SCAN_ROOT}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

if [[ -n "${CERT_PATH}" && ! -f "${CERT_PATH}" ]]; then
  echo "信息：CERT_PATH 必须是已存在证书文件: ${CERT_PATH}" >&2
  exit 1
fi

echo "信息：Security key and certificate metadata audit"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：Scan root: ${SCAN_ROOT}"
echo "信息：证书路径: ${CERT_PATH:-<无>}"
echo "信息：本脚本为只读，绝不打印私钥内容。元数据和证书主题仍可能敏感。"
echo

echo "信息：== Private-key-like file metadata =="
find "${SCAN_ROOT}" -xdev -type f \( -name 'id_rsa' -o -name 'id_dsa' -o -name 'id_ecdsa' -o -name 'id_ed25519' -o -name '*.key' -o -name '*.pem' \) -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "key_like_files_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' | while IFS= read -r key_file; do
  case "${key_file}" in
    key_like_files_seen=*|...output*)
      echo "信息：${key_file}"
      ;;
    *)
      ls -l "${key_file}" 2>/dev/null || true
      case "$(basename "${key_file}")" in
        *.pub)
          echo "信息：public_key_candidate: ${key_file}"
          ;;
      esac
      ;;
  esac
done
echo

echo "信息：== Broad-read permission hints for key-like files =="
find "${SCAN_ROOT}" -xdev -type f \( -name 'id_rsa' -o -name 'id_dsa' -o -name 'id_ecdsa' -o -name 'id_ed25519' -o -name '*.key' -o -name '*.pem' \) -perm -004 -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "world_readable_key_like_files_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || true
echo

echo "信息：== Certificate metadata =="
if [[ -n "${CERT_PATH}" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl x509 -in "${CERT_PATH}" -noout -subject -issuer -dates -serial -fingerprint -sha256 2>/dev/null || echo "信息：无法使用 openssl 解析证书元数据。"
  else
    echo "openssl 不可用."
  fi
else
  find "${SCAN_ROOT}" -xdev -type f \( -name '*.crt' -o -name '*.cer' -o -name '*.pem' \) -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "certificate_like_files_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' | while IFS= read -r cert_file; do
    case "${cert_file}" in
      certificate_like_files_seen=*|...output*)
        echo "信息：${cert_file}"
        ;;
      *)
        ls -l "${cert_file}" 2>/dev/null || true
        if command -v openssl >/dev/null 2>&1; then
          openssl x509 -in "${cert_file}" -noout -subject -issuer -dates 2>/dev/null || true
        fi
        ;;
    esac
  done
fi
