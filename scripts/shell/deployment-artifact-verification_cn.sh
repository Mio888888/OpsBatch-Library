#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_PATH="${1:-${ARTIFACT_PATH:-}}"
CHECKSUM_FILE="${2:-${CHECKSUM_FILE:-}}"
EXPECTED_SHA256="${EXPECTED_SHA256:-}"
LIMIT="${LIMIT:-40}"

if [[ -z "${ARTIFACT_PATH}" ]]; then
  echo "请设置 ARTIFACT_PATH or pass an artifact path as the first argument.（Set ARTIFACT_PATH or pass an artifact path as the first argument.）" >&2
  exit 2
fi

if [[ ! -f "${ARTIFACT_PATH}" ]]; then
  echo "Artifact file 未找到: ${ARTIFACT_PATH}（Artifact file not found: ${ARTIFACT_PATH}）" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT must be a positive integer." >&2
  exit 2
fi

sha256_of_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${file}" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${file}" | awk '{ print $1 }'
  else
    return 1
  fi
}

echo "信息：Deployment artifact verification"
echo "信息：Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：Artifact path: ${ARTIFACT_PATH}"
echo "信息：Checksum file: ${CHECKSUM_FILE:-<none>}"
echo "信息：Expected SHA-256: ${EXPECTED_SHA256:-<none>}"
echo "信息：This script is read-only and does not unpack, install, or deploy artifacts."
echo

echo "信息：== Artifact metadata =="
ls -lh "${ARTIFACT_PATH}" || true
if command -v file >/dev/null 2>&1; then
  file "${ARTIFACT_PATH}" || true
fi
echo

echo "信息：== SHA-256 digest =="
if digest="$(sha256_of_file "${ARTIFACT_PATH}")"; then
  printf 'sha256=%s  %s\n' "${digest}" "${ARTIFACT_PATH}"
else
  echo "信息：No SHA-256 tool found (sha256sum or shasum required)." >&2
  exit 1
fi
if [[ -n "${EXPECTED_SHA256}" ]]; then
  if [[ "${digest}" == "${EXPECTED_SHA256}" ]]; then
    echo "信息：expected_sha256_match=yes"
  else
    echo "信息：expected_sha256_match=no" >&2
    exit 1
  fi
fi
echo

if [[ -n "${CHECKSUM_FILE}" ]]; then
  echo "信息：== Checksum file verification =="
  if [[ ! -f "${CHECKSUM_FILE}" ]]; then
    echo "Checksum file 未找到: ${CHECKSUM_FILE}（Checksum file not found: ${CHECKSUM_FILE}）" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "${CHECKSUM_FILE}")" && sha256sum -c "$(basename "${CHECKSUM_FILE}")")
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$(dirname "${CHECKSUM_FILE}")" && shasum -a 256 -c "$(basename "${CHECKSUM_FILE}")")
  else
    echo "信息：No SHA-256 manifest checker found." >&2
    exit 1
  fi
else
  echo "信息：No checksum file provided."
fi
echo

echo "信息：== Archive listing preview =="
case "${ARTIFACT_PATH}" in
  *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz)
    if command -v tar >/dev/null 2>&1; then
      tar -tf "${ARTIFACT_PATH}" 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "archive_entries_seen=%d\n", NR; if (NR > limit) print "...output truncated..." }' || echo "信息：Unable to list archive with tar."
    else
      echo "tar 不可用.（tar not available.）"
    fi
    ;;
  *.zip)
    if command -v unzip >/dev/null 2>&1; then
      unzip -l "${ARTIFACT_PATH}" 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...output truncated..." }' || echo "信息：Unable to list archive with unzip."
    else
      echo "unzip 不可用.（unzip not available.）"
    fi
    ;;
  *)
    echo "信息：Artifact extension is not a recognized archive preview type."
    ;;
esac
