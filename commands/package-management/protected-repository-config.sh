#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_REPO_NAME="${TARGET_REPO_NAME:-}"
TARGET_REPO_URL="${TARGET_REPO_URL:-}"
REPO_ACTION="${REPO_ACTION:-show-plan}"
CONFIRM_REPO_CHANGE="${CONFIRM_REPO_CHANGE:-}"

if [ -z "$TARGET_REPO_NAME" ] || [ -z "$TARGET_REPO_URL" ]; then
  echo "Refusing to run: set TARGET_REPO_NAME and TARGET_REPO_URL explicitly. Do not include tokens or credentials in URLs."
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

echo "== protected repository configuration plan =="
echo "PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "REPO_ACTION=$REPO_ACTION"
echo "TARGET_REPO_NAME=$TARGET_REPO_NAME"
echo "TARGET_REPO_URL=$TARGET_REPO_URL"
echo "No credentials should be embedded in TARGET_REPO_URL."

case "$PACKAGE_MANAGER" in
  apt) echo "Would create /etc/apt/sources.list.d/$TARGET_REPO_NAME.list with a reviewed deb line." ;;
  dnf|yum) echo "Would create /etc/yum.repos.d/$TARGET_REPO_NAME.repo with gpgcheck enabled after key validation." ;;
  zypper) echo "Would run: sudo zypper addrepo $TARGET_REPO_URL $TARGET_REPO_NAME" ;;
  brew) echo "Would run: brew tap $TARGET_REPO_NAME $TARGET_REPO_URL" ;;
  *) echo "Unsupported package manager for repo config template." ;;
esac

if [ "$CONFIRM_REPO_CHANGE" != "APPLY_REPO_CHANGE" ]; then
  echo
  echo "Dry-run only. Set CONFIRM_REPO_CHANGE=APPLY_REPO_CHANGE after validating URL, GPG/signing policy, trust boundary, and rollback plan."
  exit 0
fi

case "$PACKAGE_MANAGER" in
  apt)
    echo "Applying apt repo changes is intentionally not automated here. Create the reviewed file manually with signed-by/GPG controls."
    ;;
  dnf|yum)
    echo "Applying yum/dnf repo changes is intentionally not automated here. Create the reviewed .repo file manually with gpgcheck=1."
    ;;
  zypper)
    sudo zypper addrepo "$TARGET_REPO_URL" "$TARGET_REPO_NAME"
    ;;
  brew)
    brew tap "$TARGET_REPO_NAME" "$TARGET_REPO_URL"
    ;;
  *) echo "Unsupported package manager; no changes made." ;;
esac
