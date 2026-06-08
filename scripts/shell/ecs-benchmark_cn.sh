#!/usr/bin/env bash
set -euo pipefail

# spiritLHLS/ecs 上游 Shell 版融合怪测评脚本下载地址。优先 GitHub，失败时回退 GitLab 镜像。
readonly ECS_GITHUB_URL="https://raw.githubusercontent.com/spiritLHLS/ecs/main/ecs.sh"
readonly ECS_GITLAB_URL="https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh"

TEMP_DIR=""
UPSTREAM_SCRIPT=""
EXTRA_ARGS_NUL=""

declare -a UPSTREAM_ARGS=()
declare -a DIRECT_ARGS=("$@")

cleanup() {
  if [ -n "${TEMP_DIR}" ] && [ -d "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
  fi
}

on_interrupt() {
  cleanup
  exit 130
}

on_terminate() {
  cleanup
  exit 143
}

trap cleanup EXIT
trap on_interrupt INT
trap on_terminate TERM

print_help() {
  cat <<'EOF'
ECS/融合怪综合测评启动器（Shell 版）

用法:
  scripts/shell/ecs-benchmark_cn.sh
  ECS_MODE=1 ECS_SKIP_UPLOAD=true scripts/shell/ecs-benchmark_cn.sh
  ECS_BASE_ONLY=true ECS_SKIP_SPEEDTEST=true scripts/shell/ecs-benchmark_cn.sh

说明:
  本脚本是 spiritLHLS/ecs 上游 ecs.sh 的轻量启动器。它会先将上游 Shell 脚本
  下载到临时文件，确认文件非空后再用 bash 运行；不会直接 curl | bash。
  如需更少依赖、非 root 运行或降低主机污染，上游更推荐 Golang 版本；本包装器
  仅负责启动 Shell 版。

重要提示:
  - 推荐在 /root 下运行，但本包装器本身不强制要求 root。
  - 上游脚本可能更新包管理器并安装依赖，可能对主机产生变更，不建议在生产环境运行。
  - CPU、内存、磁盘 DD/FIO、网络测速、流媒体解锁、TikTok 解锁、回程路由、IP 质量、
    邮件端口等测试可能耗时、占用资源、产生大量外联网络流量，并暴露运行环境信息。
  - 完整/简单测评默认可能上传结果到 pastebin 并返回分享链接；结果也会保存到当前路径
    test_result.txt。若不希望上传，请设置 ECS_SKIP_UPLOAD=true。
  - 长时间测试建议在 screen 或 tmux 中运行。
  - 按 Ctrl+C 退出时，上游脚本会尝试清理残留依赖；本包装器会清理下载的临时文件。

上游支持范围:
  - 系统: Ubuntu 18+、Debian 8+、CentOS 7+、Fedora 33+、AlmaLinux 8.5+、
    OracleLinux 8+、RockyLinux 8+、AstraLinux CE、Arch；FreeBSD 半支持
    （需先 pkg install -y curl bash）；Armbian 半支持。
  - 架构: amd64/x86_64、arm64、i386、arm。
  - 网络测试需要可用的出站网络。

环境变量:
  ECS_MODE              传给上游 -m 的运行模式，例如 1；为空时使用上游默认行为。
  ECS_ENGLISH           true/1/yes/on 时添加 -en；false/0/no/off 时不添加。
                        中文包装器默认不添加 -en。
  ECS_ROUTE_TARGET      传给上游 -r 的回程或路由测试目标。
  ECS_TARGET_IPV4       传给上游 -i 的目标 IPv4 地址。
  ECS_BASE_ONLY         true/1/yes/on 时添加 -base，仅运行基础信息相关测试。
  ECS_CPU_TYPE          传给上游 -ctype 的 CPU 测试类型。
  ECS_DISK_TYPE         传给上游 -dtype 的磁盘测试类型。
  ECS_MULTI_DISK        true/1/yes/on 时添加 -mdisk，启用多磁盘测试选项。
  ECS_SPEEDTEST_SOURCE  传给上游 -stype 的测速源类型。
  ECS_SKIP_SPEEDTEST    true/1/yes/on 时添加 -bansp，跳过测速相关测试。
  ECS_SKIP_UPLOAD       true/1/yes/on 时添加 -banup，跳过结果上传。
  ECS_EXTRA_ARGS        追加传给上游 ecs.sh 的额外参数。有 python3 时按 shell 风格引号解析；
                        否则按空白保守拆分。不使用 eval。

传给本包装器的非 -h/--help 命令行参数会追加到上游参数末尾。
EOF
}

lower_value() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

is_true() {
  case "$(lower_value "$1")" in
    1|true|yes|y|on) return 0 ;;
    *) return 1 ;;
  esac
}

is_false() {
  case "$(lower_value "$1")" in
    0|false|no|n|off) return 0 ;;
    *) return 1 ;;
  esac
}

warn_invalid_bool() {
  printf '警告: %s=%s 不是可识别的布尔值，已忽略。请使用 true/false、1/0、yes/no 或 on/off。\n' "$1" "$2" >&2
}

append_value_arg() {
  local flag="$1"
  local value="$2"
  if [ -n "${value}" ]; then
    UPSTREAM_ARGS+=("${flag}" "${value}")
  fi
}

append_true_flag() {
  local name="$1"
  local value="$2"
  local flag="$3"

  if [ -z "${value}" ]; then
    return 0
  fi
  if is_true "${value}"; then
    UPSTREAM_ARGS+=("${flag}")
  elif ! is_false "${value}"; then
    warn_invalid_bool "${name}" "${value}"
  fi
}

prepare_temp_dir() {
  TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ecs-benchmark.XXXXXX")"
  UPSTREAM_SCRIPT="${TEMP_DIR}/ecs.sh"
  EXTRA_ARGS_NUL="${TEMP_DIR}/extra-args.nul"
}

require_downloader() {
  if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
    return 0
  fi
  printf '错误: 未找到 curl 或 wget。请先安装其中任意一个下载工具。\n' >&2
  return 127
}

download_url() {
  local url="$1"
  local dest="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fL --connect-timeout 15 --retry 2 --output "${dest}" "${url}"
  else
    wget -O "${dest}" "${url}"
  fi
}

download_upstream() {
  local url

  for url in "${ECS_GITHUB_URL}" "${ECS_GITLAB_URL}"; do
    printf '正在下载上游 ecs.sh: %s\n' "${url}"
    if download_url "${url}" "${UPSTREAM_SCRIPT}"; then
      if [ -s "${UPSTREAM_SCRIPT}" ]; then
        chmod +x "${UPSTREAM_SCRIPT}"
        return 0
      fi
      printf '警告: 下载文件为空，准备尝试下一个地址。\n' >&2
    else
      printf '警告: 下载失败，准备尝试下一个地址。\n' >&2
    fi
    rm -f "${UPSTREAM_SCRIPT}"
  done

  printf '错误: 无法从 GitHub 或 GitLab 下载上游 ecs.sh。\n' >&2
  return 1
}

parse_extra_args() {
  local extra_arg
  local extra_parts

  if [ -z "${ECS_EXTRA_ARGS:-}" ]; then
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    if ! python3 - "${ECS_EXTRA_ARGS}" >"${EXTRA_ARGS_NUL}" <<'PY'
import shlex
import sys

try:
    parts = shlex.split(sys.argv[1])
except ValueError as exc:
    print(f"ECS_EXTRA_ARGS parse error: {exc}", file=sys.stderr)
    sys.exit(2)

for part in parts:
    sys.stdout.buffer.write(part.encode())
    sys.stdout.buffer.write(b"\0")
PY
    then
      printf '错误: ECS_EXTRA_ARGS 引号或转义解析失败。\n' >&2
      return 2
    fi

    while IFS= read -r -d '' extra_arg; do
      UPSTREAM_ARGS+=("${extra_arg}")
    done <"${EXTRA_ARGS_NUL}"
  else
    printf '警告: 未找到 python3，ECS_EXTRA_ARGS 将按空白保守拆分，无法保留引号分组。\n' >&2
    set -f
    # shellcheck disable=SC2206,SC2086
    extra_parts=(${ECS_EXTRA_ARGS})
    set +f
    for extra_arg in "${extra_parts[@]}"; do
      UPSTREAM_ARGS+=("${extra_arg}")
    done
  fi
}

build_upstream_args() {
  append_value_arg "-m" "${ECS_MODE:-}"

  if [ -n "${ECS_ENGLISH:-}" ]; then
    if is_true "${ECS_ENGLISH}"; then
      UPSTREAM_ARGS+=("-en")
    elif ! is_false "${ECS_ENGLISH}"; then
      warn_invalid_bool "ECS_ENGLISH" "${ECS_ENGLISH}"
    fi
  fi

  append_value_arg "-r" "${ECS_ROUTE_TARGET:-}"
  append_value_arg "-i" "${ECS_TARGET_IPV4:-}"
  append_true_flag "ECS_BASE_ONLY" "${ECS_BASE_ONLY:-}" "-base"
  append_value_arg "-ctype" "${ECS_CPU_TYPE:-}"
  append_value_arg "-dtype" "${ECS_DISK_TYPE:-}"
  append_true_flag "ECS_MULTI_DISK" "${ECS_MULTI_DISK:-}" "-mdisk"
  append_value_arg "-stype" "${ECS_SPEEDTEST_SOURCE:-}"
  append_true_flag "ECS_SKIP_SPEEDTEST" "${ECS_SKIP_SPEEDTEST:-}" "-bansp"
  append_true_flag "ECS_SKIP_UPLOAD" "${ECS_SKIP_UPLOAD:-}" "-banup"
  parse_extra_args
}

print_run_notice() {
  cat <<'EOF'
即将运行上游 ECS/融合怪 Shell 测评脚本。
请确认: 不在生产环境运行、已了解可能安装依赖/更新包管理器/上传结果、当前网络允许外联。
如需避免结果上传，请设置 ECS_SKIP_UPLOAD=true；长时间测试建议使用 screen 或 tmux。
EOF
  if [ "$(id -u)" -ne 0 ]; then
    printf '提示: 当前不是 root。上游脚本仍会启动，但依赖安装或部分测试可能失败；上游建议在 /root 下运行。\n'
  fi
  printf '上游参数数量: %s\n' "$((${#UPSTREAM_ARGS[@]} + ${#DIRECT_ARGS[@]}))"
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    print_help
    return 0
  fi

  require_downloader
  prepare_temp_dir
  build_upstream_args
  download_upstream
  print_run_notice

  bash "${UPSTREAM_SCRIPT}" "${UPSTREAM_ARGS[@]}" "${DIRECT_ARGS[@]}"
}

main "$@"
