#!/usr/bin/env bash
set -euo pipefail

# Download URLs for the upstream spiritLHLS/ecs Shell benchmark script. Prefer GitHub and fall back to the GitLab mirror.
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
ECS Comprehensive Benchmark Launcher (Shell version)

Usage:
  scripts/shell/ecs-benchmark_en.sh
  ECS_MODE=1 ECS_SKIP_UPLOAD=true scripts/shell/ecs-benchmark_en.sh
  ECS_BASE_ONLY=true ECS_SKIP_SPEEDTEST=true scripts/shell/ecs-benchmark_en.sh

Description:
  This script is a lightweight launcher for the upstream spiritLHLS/ecs ecs.sh script.
  It downloads the upstream Shell script to a temporary file, verifies the file is not empty,
  and then runs it with bash. It does not pipe curl directly into bash.
  The upstream project recommends its Golang version when you need fewer dependencies,
  non-root execution, or less host pollution. This wrapper only starts the Shell version.

Important warnings:
  - Running under /root is recommended, but this wrapper does not require root by itself.
  - The upstream script may update the package manager and install dependencies. It can modify
    the host, so it is not recommended for production systems.
  - System, CPU, memory, disk DD/FIO, speedtest, streaming unlock, TikTok unlock, return route,
    IP quality, and mail port tests may take a long time, consume resources, generate outbound
    traffic, and expose runtime environment details.
  - Full/simple benchmark modes may upload results to pastebin by default and return a share link.
    Results are also saved to test_result.txt in the current path. Set ECS_SKIP_UPLOAD=true if
    you do not want result uploads.
  - Use screen or tmux for long-running tests.
  - When Ctrl+C is used, the upstream script attempts to clean residual dependencies; this wrapper
    cleans the downloaded temporary file.

Upstream support scope:
  - Systems: Ubuntu 18+, Debian 8+, CentOS 7+, Fedora 33+, AlmaLinux 8.5+, OracleLinux 8+,
    RockyLinux 8+, AstraLinux CE, Arch; semi-supported FreeBSD (requires pkg install -y curl bash)
    and Armbian.
  - Architectures: amd64/x86_64, arm64, i386, arm.
  - Network tests require outbound network access.

Environment variables:
  ECS_MODE              Run mode passed to upstream -m, for example 1; leave empty for upstream defaults.
  ECS_ENGLISH           true/1/yes/on adds -en; false/0/no/off disables it.
                        This English wrapper adds -en by default when the variable is empty.
  ECS_ROUTE_TARGET      Route or backtrace target passed to upstream -r.
  ECS_TARGET_IPV4       Target IPv4 address passed to upstream -i.
  ECS_BASE_ONLY         true/1/yes/on adds -base to run only base-information related tests.
  ECS_CPU_TYPE          CPU test type passed to upstream -ctype.
  ECS_DISK_TYPE         Disk test type passed to upstream -dtype.
  ECS_MULTI_DISK        true/1/yes/on adds -mdisk for the upstream multi-disk test option.
  ECS_SPEEDTEST_SOURCE  Speedtest source type passed to upstream -stype.
  ECS_SKIP_SPEEDTEST    true/1/yes/on adds -bansp to skip speedtest-related checks.
  ECS_SKIP_UPLOAD       true/1/yes/on adds -banup to skip result upload.
  ECS_EXTRA_ARGS        Additional arguments appended to upstream ecs.sh. Parsed with shell-style
                        quoting when python3 is available; otherwise split conservatively on
                        whitespace. eval is not used.

Non -h/--help command-line arguments passed to this wrapper are appended to the upstream arguments.
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
  printf 'Warning: %s=%s is not a recognized boolean value and was ignored. Use true/false, 1/0, yes/no, or on/off.\n' "$1" "$2" >&2
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
  printf 'Error: curl or wget is required. Install at least one downloader first.\n' >&2
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
    printf 'Downloading upstream ecs.sh: %s\n' "${url}"
    if download_url "${url}" "${UPSTREAM_SCRIPT}"; then
      if [ -s "${UPSTREAM_SCRIPT}" ]; then
        chmod +x "${UPSTREAM_SCRIPT}"
        return 0
      fi
      printf 'Warning: downloaded file is empty; trying the next URL.\n' >&2
    else
      printf 'Warning: download failed; trying the next URL.\n' >&2
    fi
    rm -f "${UPSTREAM_SCRIPT}"
  done

  printf 'Error: failed to download upstream ecs.sh from GitHub or GitLab.\n' >&2
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
      printf 'Error: failed to parse ECS_EXTRA_ARGS quoting or escaping.\n' >&2
      return 2
    fi

    while IFS= read -r -d '' extra_arg; do
      UPSTREAM_ARGS+=("${extra_arg}")
    done <"${EXTRA_ARGS_NUL}"
  else
    printf 'Warning: python3 was not found. ECS_EXTRA_ARGS will be split conservatively on whitespace, so quoted groups cannot be preserved.\n' >&2
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

  if [ -z "${ECS_ENGLISH:-}" ]; then
    UPSTREAM_ARGS+=("-en")
  elif is_true "${ECS_ENGLISH}"; then
    UPSTREAM_ARGS+=("-en")
  elif ! is_false "${ECS_ENGLISH}"; then
    warn_invalid_bool "ECS_ENGLISH" "${ECS_ENGLISH}"
    UPSTREAM_ARGS+=("-en")
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
About to run the upstream ECS Shell benchmark script.
Confirm that this is not a production host, that package updates/dependency installs/result uploads are acceptable,
and that outbound network access is allowed.
Set ECS_SKIP_UPLOAD=true to avoid result upload. Use screen or tmux for long-running tests.
EOF
  if [ "$(id -u)" -ne 0 ]; then
    printf 'Note: current user is not root. The upstream script will still start, but dependency installation or some tests may fail; upstream recommends running under /root.\n'
  fi
  printf 'Upstream argument count: %s\n' "$((${#UPSTREAM_ARGS[@]} + ${#DIRECT_ARGS[@]}))"
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
