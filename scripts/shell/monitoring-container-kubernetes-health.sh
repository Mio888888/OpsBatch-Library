#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${MODE:-auto}}"
NAMESPACE="${2:-${NAMESPACE:-default}}"
NAME_FILTER="${3:-${NAME_FILTER:-}}"
MAX_RESTARTS_WARN="${4:-${MAX_RESTARTS_WARN:-3}}"
MAX_RESTARTS_CRIT="${5:-${MAX_RESTARTS_CRIT:-10}}"

is_nonnegative_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

if [[ "${MODE}" != "auto" && "${MODE}" != "docker" && "${MODE}" != "kubernetes" ]]; then
  unknown "MODE must be auto, docker, or kubernetes"
fi
if ! is_nonnegative_int "${MAX_RESTARTS_WARN}" || ! is_nonnegative_int "${MAX_RESTARTS_CRIT}"; then
  unknown "restart thresholds must be non-negative integers"
fi
if [[ "${MAX_RESTARTS_WARN}" -gt "${MAX_RESTARTS_CRIT}" ]]; then
  unknown "MAX_RESTARTS_WARN must be less than or equal to MAX_RESTARTS_CRIT"
fi
if [[ "${NAMESPACE}" == -* ]]; then
  unknown "NAMESPACE must not start with '-'"
fi

status="OK"
exit_code=0
reasons=()

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker CLI not available."
    return 3
  fi
  if ! docker ps --format '{{.Names}}' >/dev/null 2>&1; then
    echo "Docker CLI available but cannot list containers."
    return 3
  fi
  echo "== Docker containers (bounded) =="
  docker_lines="$(docker ps --format 'name={{.Names}} status={{.Status}}' 2>/dev/null)"
  if [[ -n "${NAME_FILTER}" ]]; then
    printf '%s\n' "${docker_lines}" | grep -F -- "${NAME_FILTER}" || true
  else
    printf '%s\n' "${docker_lines}" | awk 'NR <= 20 {print}'
  fi
  unhealthy_count="$(docker ps --filter health=unhealthy --format '{{.Names}}' 2>/dev/null | { if [[ -n "${NAME_FILTER}" ]]; then grep -F -- "${NAME_FILTER}" || true; else cat; fi; } | wc -l | tr -d ' ')"
  if [[ "${unhealthy_count}" -gt 0 ]]; then
    reasons+=("docker_unhealthy=${unhealthy_count}")
    return 2
  fi
  return 0
}

check_kubernetes() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl CLI not available."
    return 3
  fi
  if ! kubectl get pods -n "${NAMESPACE}" --no-headers >/dev/null 2>&1; then
    echo "kubectl available but cannot list pods in namespace ${NAMESPACE}."
    return 3
  fi
  echo "== Kubernetes pods namespace=${NAMESPACE} (bounded) =="
  pod_lines="$(kubectl get pods -n "${NAMESPACE}" --no-headers 2>/dev/null | { if [[ -n "${NAME_FILTER}" ]]; then grep -F -- "${NAME_FILTER}" || true; else head -n 20; fi; })"
  if [[ -z "${pod_lines}" ]]; then
    echo "No pods matched filter '${NAME_FILTER:-<none>}' in namespace ${NAMESPACE}."
    return 1
  fi
  printf '%s\n' "${pod_lines}"
  not_ready_count="$(printf '%s\n' "${pod_lines}" | awk '{split($2, ready, "/"); if (ready[1] != ready[2] || $3 != "Running") c++} END {print c+0}')"
  max_restart="$(printf '%s\n' "${pod_lines}" | awk '{if ($4 > max) max=$4} END {print max+0}')"
  if [[ "${not_ready_count}" -gt 0 ]]; then
    reasons+=("kubernetes_not_ready=${not_ready_count}")
  fi
  if [[ "${max_restart}" -ge "${MAX_RESTARTS_CRIT}" ]]; then
    reasons+=("kubernetes_max_restarts=${max_restart}>=${MAX_RESTARTS_CRIT}")
    return 2
  fi
  if [[ "${not_ready_count}" -gt 0 || "${max_restart}" -ge "${MAX_RESTARTS_WARN}" ]]; then
    if [[ "${max_restart}" -ge "${MAX_RESTARTS_WARN}" ]]; then
      reasons+=("kubernetes_max_restarts=${max_restart}>=${MAX_RESTARTS_WARN}")
    fi
    return 1
  fi
  return 0
}

ran_any="false"
mode_status=0

if [[ "${MODE}" == "docker" || "${MODE}" == "auto" ]]; then
  docker_result=0
  check_docker || docker_result=$?
  if [[ "${docker_result}" -ne 3 ]]; then
    ran_any="true"
    if [[ "${docker_result}" -gt "${mode_status}" ]]; then
      mode_status="${docker_result}"
    fi
  fi
fi

if [[ "${MODE}" == "kubernetes" || "${MODE}" == "auto" ]]; then
  kube_result=0
  check_kubernetes || kube_result=$?
  if [[ "${kube_result}" -ne 3 ]]; then
    ran_any="true"
    if [[ "${kube_result}" -gt "${mode_status}" ]]; then
      mode_status="${kube_result}"
    fi
  fi
fi

if [[ "${ran_any}" != "true" ]]; then
  unknown "no accessible Docker or Kubernetes inspection source found"
fi

case "${mode_status}" in
  0)
    status="OK"
    exit_code=0
    ;;
  1)
    status="WARNING"
    exit_code=1
    ;;
  *)
    status="CRITICAL"
    exit_code=2
    ;;
esac

reason_text="container health clues within thresholds"
if [[ ${#reasons[@]} -gt 0 ]]; then
  reason_text="$(IFS=', '; echo "${reasons[*]}")"
fi

echo "${status} - mode=${MODE} namespace=${NAMESPACE} filter=${NAME_FILTER:-<none>} (${reason_text})"
echo "Details: read-only CLI inspection only; no logs, restarts, deletes, scaling, or cluster changes."
exit "${exit_code}"
