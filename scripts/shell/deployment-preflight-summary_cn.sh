#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${1:-${APP_DIR:-}}"
ARTIFACT_PATH="${2:-${ARTIFACT_PATH:-}}"
SERVICE="${3:-${SERVICE:-}}"
HEALTH_URL="${4:-${HEALTH_URL:-}}"
CHECKSUM_FILE="${CHECKSUM_FILE:-}"
RELEASES_DIR="${RELEASES_DIR:-}"
VALIDATE_CMD="${VALIDATE_CMD:-}"
LIMIT="${LIMIT:-10}"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

echo "信息：部署预检摘要"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：主机: $(hostname 2>/dev/null || echo 未知)"
echo "信息：应用目录: ${APP_DIR:-<未提供>}"
echo "信息：制品路径: ${ARTIFACT_PATH:-<未提供>}"
echo "信息：校验和文件: ${CHECKSUM_FILE:-<未提供>}"
echo "信息：发布目录: ${RELEASES_DIR:-<未提供>}"
echo "信息：服务： ${SERVICE:-<未提供>}"
echo "信息：健康检查 URL: ${HEALTH_URL:-<未提供>}"
echo "信息：本脚本为只读，不会部署、重启、迁移或切换符号链接。"
echo

echo "信息：== 必需工具可用性 =="
for tool in bash tar gzip openssl curl shasum sha256sum systemctl service launchctl; do
  if command -v "${tool}" >/dev/null 2>&1; then
    printf '%s: 可用\n' "${tool}"
  else
    printf '%s: 不可用\n' "${tool}"
  fi
done
echo

echo "信息：== 路径检查 =="
for path in "${APP_DIR}" "${ARTIFACT_PATH}" "${CHECKSUM_FILE}" "${RELEASES_DIR}"; do
  if [[ -z "${path}" ]]; then
    continue
  fi
  if [[ -e "${path}" ]]; then
    ls -ld "${path}" 2>/dev/null || true
  else
    printf '缺失： %s\n' "${path}"
  fi
done
echo

echo "信息：== 制品校验和预览 =="
if [[ -n "${ARTIFACT_PATH}" && -f "${ARTIFACT_PATH}" ]]; then
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${ARTIFACT_PATH}"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${ARTIFACT_PATH}"
  else
    echo "信息：未找到 sha256 工具。"
  fi
else
  echo "信息：未提供制品文件，跳过摘要预览。"
fi
if [[ -n "${CHECKSUM_FILE}" ]]; then
  if [[ -f "${CHECKSUM_FILE}" ]]; then
    echo "信息：校验和文件存在；请在操作员批准后运行受保护部署或专用验证。"
  else
    echo "信息：已提供校验和文件路径，但该路径不存在。"
  fi
fi
echo

echo "信息：== 发布目录摘要 =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "${LIMIT}" || true
else
  echo "信息：未提供发布目录或目录缺失。"
fi
if [[ -n "${APP_DIR}" && -L "${APP_DIR}/current" ]]; then
  printf '当前符号链接: %s -> %s\n' "${APP_DIR}/current" "$(readlink "${APP_DIR}/current")"
fi
echo

echo "信息：== 服务状态 =="
if [[ -n "${SERVICE}" ]]; then
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active "${SERVICE}" || true
  elif command -v service >/dev/null 2>&1; then
    service "${SERVICE}" status || true
  elif command -v launchctl >/dev/null 2>&1; then
    launchctl print "system/${SERVICE}" 2>/dev/null || launchctl print "gui/$(id -u)/${SERVICE}" 2>/dev/null || echo "未找到匹配的 launchctl 服务。"
  else
    echo "未找到受支持的 服务管理器。"
  fi
else
  echo "信息：未提供服务。"
fi
echo

echo "信息：== 可选验证命令 =="
if [[ -n "${VALIDATE_CMD}" ]]; then
  echo "信息：正在运行操作员提供的只读验证命令: ${VALIDATE_CMD}"
  bash -c "${VALIDATE_CMD}"
else
  echo "信息：未提供 VALIDATE_CMD。"
fi
echo

echo "信息：== 可选健康 URL 探测 =="
if [[ -n "${HEALTH_URL}" ]]; then
  if command -v curl >/dev/null 2>&1; then
    curl --fail --show-error --silent --max-time 10 --output /dev/null --write-out 'http_code=%{http_code} time_total=%{time_total}\n' "${HEALTH_URL}" || true
  else
    echo "curl 不可用."
  fi
else
  echo "信息：未提供 HEALTH_URL。"
fi
