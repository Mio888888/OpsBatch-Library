#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${1:-${APP_DIR:-}}"
RELEASES_DIR="${2:-${RELEASES_DIR:-}}"
CURRENT_LINK="${CURRENT_LINK:-}"
CANDIDATE_RELEASE="${CANDIDATE_RELEASE:-}"
LIMIT="${LIMIT:-10}"

if [[ ! "${LIMIT}" =~ ^[1-9][0-9]*$ ]]; then
  echo "信息：LIMIT 必须是正整数。" >&2
  exit 2
fi

if [[ -n "${APP_DIR}" && ! -d "${APP_DIR}" ]]; then
  echo "信息：APP_DIR 不存在或不是目录: ${APP_DIR}" >&2
  exit 1
fi

if [[ -z "${RELEASES_DIR}" && -n "${APP_DIR}" ]]; then
  RELEASES_DIR="${APP_DIR}/releases"
fi

if [[ -z "${CURRENT_LINK}" && -n "${APP_DIR}" ]]; then
  CURRENT_LINK="${APP_DIR}/current"
fi

echo "信息：部署发布与回滚计划"
echo "信息：生成时间: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "信息：应用目录: ${APP_DIR:-<未提供>}"
echo "信息：发布目录: ${RELEASES_DIR:-<未提供>}"
echo "信息：当前链接: ${CURRENT_LINK:-<未提供>}"
echo "信息：候选发布: ${CANDIDATE_RELEASE:-<未提供>}"
echo "信息：本脚本为只读，不会切换符号链接或删除发布。"
echo

echo "信息：== 当前发布 =="
if [[ -n "${CURRENT_LINK}" ]]; then
  if [[ -L "${CURRENT_LINK}" ]]; then
    printf '%s -> %s\n' "${CURRENT_LINK}" "$(readlink "${CURRENT_LINK}")"
  elif [[ -e "${CURRENT_LINK}" ]]; then
    echo "信息：当前路径存在但不是符号链接: ${CURRENT_LINK}"
  else
    echo "信息：当前链接不存在： ${CURRENT_LINK}"
  fi
else
  echo "信息：未提供 CURRENT_LINK 或 APP_DIR。"
fi
echo

echo "信息：== 最近发布 =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "${LIMIT}" || true
else
  echo "信息：发布目录缺失或未提供。"
fi
echo

echo "信息：== 候选发布检查 =="
if [[ -n "${CANDIDATE_RELEASE}" ]]; then
  if [[ -d "${CANDIDATE_RELEASE}" ]]; then
    ls -ld "${CANDIDATE_RELEASE}" 2>/dev/null || true
  elif [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}/${CANDIDATE_RELEASE}" ]]; then
    ls -ld "${RELEASES_DIR}/${CANDIDATE_RELEASE}" 2>/dev/null || true
  else
    echo "未以绝对路径或在发布目录下找到候选发布。"
  fi
else
  echo "信息：未提供 CANDIDATE_RELEASE。"
fi
echo

echo "信息：== 回滚候选 =="
if [[ -n "${RELEASES_DIR}" && -d "${RELEASES_DIR}" ]]; then
  current_target=""
  if [[ -n "${CURRENT_LINK}" && -L "${CURRENT_LINK}" ]]; then
    current_target="$(readlink "${CURRENT_LINK}")"
  fi
  find "${RELEASES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n "$((LIMIT + 1))" | while IFS= read -r release; do
    if [[ "${release}" == "${current_target}" || "$(basename "${release}")" == "$(basename "${current_target}")" ]]; then
      printf '当前: %s\n' "${release}"
    else
      printf '候选: %s\n' "${release}"
    fi
  done
else
  echo "信息：没有可用的回滚候选。"
fi
echo

echo "信息：== 安全发布检查清单 =="
printf '%s\n' "1. 预发布前请验证制品校验和/签名。"
printf '%s\n' "2. 验证候选发布中的配置。"
printf '%s\n' "3. 记录当前符号链接目标和备份前置条件。"
printf '%s\n' "4. 仅在受保护脚本中通过显式确认切换当前符号链接。"
printf '%s\n' "5. 运行有界健康检查，并保持回滚候选可用。"
printf '%s\n' "6. 仅在验证成功并获得单独批准后清理旧发布。"
