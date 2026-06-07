#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${1:-${SCAN_ROOT:-${HOME:-/tmp}}}"
CERT_PATH="${2:-${CERT_PATH:-}}"
LIMIT="${LIMIT:-30}"

if [[ ! -d "${SCAN_ROOT}" ]]; then
  echo "信息：SCAN_ROOT must be an existing directory: ${SCAN_ROOT}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

if [[ -n "${CERT_PATH}" && ! -f "${CERT_PATH}" ]]; then
  echo "信息：CERT_PATH must be an existing certificate file: ${CERT_PATH}" >&2
  exit 1
fi

echo "信息：Security key and certificate metadata audit"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Host: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Scan root: ${SCAN_ROOT}"
echo "信息：Certificate path: ${CERT_PATH:-<none>}"
echo "信息：This script is read-only and never prints private key contents. Metadata and certificate subjects may still be sensitive."
echo

echo "信息：== Private-key-like file metadata =="
find "${SCAN_ROOT}" -xdev -type f \( -name 'id_rsa' -o -name 'id_dsa' -o -name 'id_ecdsa' -o -name 'id_ed25519' -o -name '*.key' -o -name '*.pem' \) -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "key_like_files_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' | while IFS= read -r key_file; do
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
find "${SCAN_ROOT}" -xdev -type f \( -name 'id_rsa' -o -name 'id_dsa' -o -name 'id_ecdsa' -o -name 'id_ed25519' -o -name '*.key' -o -name '*.pem' \) -perm -004 -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "world_readable_key_like_files_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || true
echo

echo "信息：== Certificate metadata =="
if [[ -n "${CERT_PATH}" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl x509 -in "${CERT_PATH}" -noout -subject -issuer -dates -serial -fingerprint -sha256 2>/dev/null || echo "信息：Unable to parse certificate metadata with openssl."
  else
    echo "openssl 不可用.（openssl not available.）"
  fi
else
  find "${SCAN_ROOT}" -xdev -type f \( -name '*.crt' -o -name '*.cer' -o -name '*.pem' \) -print 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "certificate_like_files_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' | while IFS= read -r cert_file; do
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
