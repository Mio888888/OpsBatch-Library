#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_PATH="${1:-${ARTIFACT_PATH:-}}"
CHECKSUM_FILE="${2:-${CHECKSUM_FILE:-}}"
EXPECTED_SHA256="${EXPECTED_SHA256:-}"
LIMIT="${LIMIT:-40}"

if [[ -z "${ARTIFACT_PATH}" ]]; then
  echo "请设置 ARTIFACT_PATH，或将制品路径作为第一个参数传入。" >&2
  exit 2
fi

if [[ ! -f "${ARTIFACT_PATH}" ]]; then
  echo "制品文件未找到: ${ARTIFACT_PATH}" >&2
  exit 1
fi

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
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

echo "信息：部署制品验证"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：制品路径: ${ARTIFACT_PATH}"
echo "信息：校验和文件: ${CHECKSUM_FILE:-<无>}"
echo "信息：预期 SHA-256: ${EXPECTED_SHA256:-<无>}"
echo "信息：本脚本为只读，不会解包、安装或部署制品。"
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
  echo "信息：未找到 SHA-256 工具（需要 sha256sum 或 shasum）。" >&2
  exit 1
fi
if [[ -n "${EXPECTED_SHA256}" ]]; then
  if [[ "${digest}" == "${EXPECTED_SHA256}" ]]; then
    echo "信息：预期_sha256_match=yes"
  else
    echo "信息：预期_sha256_match=no" >&2
    exit 1
  fi
fi
echo

if [[ -n "${CHECKSUM_FILE}" ]]; then
  echo "信息：== 校验和文件 verification =="
  if [[ ! -f "${CHECKSUM_FILE}" ]]; then
    echo "校验和文件未找到: ${CHECKSUM_FILE}" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "${CHECKSUM_FILE}")" && sha256sum -c "$(basename "${CHECKSUM_FILE}")")
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$(dirname "${CHECKSUM_FILE}")" && shasum -a 256 -c "$(basename "${CHECKSUM_FILE}")")
  else
    echo "信息：未找到 SHA-256 清单校验工具。" >&2
    exit 1
  fi
else
  echo "信息：未提供校验和文件。"
fi
echo

echo "信息：== 归档列表预览 =="
case "${ARTIFACT_PATH}" in
  *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz)
    if command -v tar >/dev/null 2>&1; then
      tar -tf "${ARTIFACT_PATH}" 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { printf "archive_entries_seen=%d\n", NR; if (NR > limit) print "...输出已截断..." }' || echo "信息：无法使用 tar 列出归档内容。"
    else
      echo "tar 不可用."
    fi
    ;;
  *.zip)
    if command -v unzip >/dev/null 2>&1; then
      unzip -l "${ARTIFACT_PATH}" 2>/dev/null | awk -v limit="${LIMIT}" 'NR <= limit { print } END { if (NR > limit) print "...输出已截断..." }' || echo "信息：无法使用 unzip 列出归档内容。"
    else
      echo "unzip 不可用."
    fi
    ;;
  *)
    echo "信息：制品扩展名不是可识别的归档预览类型。"
    ;;
esac
