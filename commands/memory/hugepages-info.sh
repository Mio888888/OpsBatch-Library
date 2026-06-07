#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/meminfo ]; then
    echo "== HugePages fields in /proc/meminfo =="
    grep -E '^(HugePages_Total|HugePages_Free|HugePages_Rsvd|HugePages_Surp|Hugepagesize|Hugetlb|AnonHugePages|ShmemHugePages|FileHugePages):' /proc/meminfo || true
  else
    echo "/proc/meminfo is not available."
  fi

  echo
  echo "== /sys/kernel/mm/hugepages =="
  if ls /sys/kernel/mm/hugepages/hugepages-* >/dev/null 2>&1; then
    for dir in /sys/kernel/mm/hugepages/hugepages-*; do
      echo "-- ${dir##*/} --"
      for file in free_hugepages nr_hugepages resv_hugepages surplus_hugepages; do
        [ -r "$dir/$file" ] && echo "$file=$(cat "$dir/$file")"
      done
    done
  else
    echo "HugePages sysfs directory not found."
  fi
else
  echo "Huge Pages inspection in this command relies on Linux /proc and /sys."
fi
