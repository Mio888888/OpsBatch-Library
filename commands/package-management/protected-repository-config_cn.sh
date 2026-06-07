#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_REPO_NAME="${TARGET_REPO_NAME:-}"
TARGET_REPO_URL="${TARGET_REPO_URL:-}"
REPO_ACTION="${REPO_ACTION:-show-plan}"
CONFIRM_REPO_CHANGE="${CONFIRM_REPO_CHANGE:-}"

if [ -z "$TARGET_REPO_NAME" ] || [ -z "$TARGET_REPO_URL" ]; then
  echo "拒绝执行： set TARGET_REPO_NAME and TARGET_REPO_URL explicitly. Do not include tokens or credentials in URLs.（Refusing to run: set TARGET_REPO_NAME and TARGET_REPO_URL explicitly. Do not include tokens or credentials in URLs.）"
  exit 0
fi

if [ "$PACKAGE_MANAGER" = "auto" ]; then
  if command -v apt-get >/dev/null 2>&1; then PACKAGE_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1; then PACKAGE_MANAGER="dnf"
  elif command -v yum >/dev/null 2>&1; then PACKAGE_MANAGER="yum"
  elif command -v zypper >/dev/null 2>&1; then PACKAGE_MANAGER="zypper"
  elif command -v brew >/dev/null 2>&1; then PACKAGE_MANAGER="brew"
  else PACKAGE_MANAGER="unsupported"; fi
fi

echo "信息：== protected repository configuration plan =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：REPO_ACTION=$REPO_ACTION"
echo "信息：TARGET_REPO_NAME=$TARGET_REPO_NAME"
echo "信息：TARGET_REPO_URL=$TARGET_REPO_URL"
echo "信息：No credentials should be embedded in TARGET_REPO_URL."

case "$PACKAGE_MANAGER" in
  apt) echo "信息：Would create /etc/apt/sources.list.d/$TARGET_REPO_NAME.list with a reviewed deb line." ;;
  dnf|yum) echo "信息：Would create /etc/yum.repos.d/$TARGET_REPO_NAME.repo with gpgcheck enabled after key validation." ;;
  zypper) echo "信息：Would run: sudo zypper addrepo $TARGET_REPO_URL $TARGET_REPO_NAME" ;;
  brew) echo "信息：Would run: brew tap $TARGET_REPO_NAME $TARGET_REPO_URL" ;;
  *) echo "信息：Unsupported package manager for repo config template." ;;
esac

if [ "$CONFIRM_REPO_CHANGE" != "APPLY_REPO_CHANGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_REPO_CHANGE=APPLY_REPO_CHANGE after validating URL, GPG/signing policy, trust boundary, and rollback plan.（Dry-run only. Set CONFIRM_REPO_CHANGE=APPLY_REPO_CHANGE after validating URL, GPG/signing policy, trust boundary, and rollback plan.）"
  exit 0
fi

case "$PACKAGE_MANAGER" in
  apt)
    echo "信息：Applying apt repo changes is intentionally not automated here. Create the reviewed file manually with signed-by/GPG controls."
    ;;
  dnf|yum)
    echo "信息：Applying yum/dnf repo changes is intentionally not automated here. Create the reviewed .repo file manually with gpgcheck=1."
    ;;
  zypper)
    sudo zypper addrepo "$TARGET_REPO_URL" "$TARGET_REPO_NAME"
    ;;
  brew)
    brew tap "$TARGET_REPO_NAME" "$TARGET_REPO_URL"
    ;;
  *) echo "信息：Unsupported package manager; no changes made." ;;
esac
