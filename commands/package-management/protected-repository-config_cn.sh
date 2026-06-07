#!/usr/bin/env bash
set -euo pipefail

PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
TARGET_REPO_NAME="${TARGET_REPO_NAME:-}"
TARGET_REPO_URL="${TARGET_REPO_URL:-}"
REPO_ACTION="${REPO_ACTION:-show-plan}"
CONFIRM_REPO_CHANGE="${CONFIRM_REPO_CHANGE:-}"

if [ -z "$TARGET_REPO_NAME" ] || [ -z "$TARGET_REPO_URL" ]; then
  echo "拒绝执行：请显式设置 TARGET_REPO_NAME 和 TARGET_REPO_URL。URL 中不要包含 token 或凭据。"
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

echo "信息：== 受保护仓库配置计划 =="
echo "信息：PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "信息：REPO_ACTION=$REPO_ACTION"
echo "信息：TARGET_REPO_NAME=$TARGET_REPO_NAME"
echo "信息：TARGET_REPO_URL=$TARGET_REPO_URL"
echo "信息：TARGET_REPO_URL 中不应嵌入凭据。"

case "$PACKAGE_MANAGER" in
  apt) echo "信息：将使用已审核的 deb 行创建 /etc/apt/sources.list.d/$TARGET_REPO_NAME.list。" ;;
  dnf|yum) echo "信息：将在密钥验证后创建启用 gpgcheck 的 /etc/yum.repos.d/$TARGET_REPO_NAME.repo。" ;;
  zypper) echo "信息：将执行： sudo zypper addrepo $TARGET_REPO_URL $TARGET_REPO_NAME" ;;
  brew) echo "信息：将执行： brew tap $TARGET_REPO_NAME $TARGET_REPO_URL" ;;
  *) echo "信息：此仓库配置模板不支持该软件包管理器。" ;;
esac

if [ "$CONFIRM_REPO_CHANGE" != "APPLY_REPO_CHANGE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_REPO_CHANGE=APPLY_REPO_CHANGE 在验证 URL、GPG/签名策略、信任边界和回滚计划后。"
  exit 0
fi

case "$PACKAGE_MANAGER" in
  apt)
    echo "信息：这里有意不自动应用 apt 仓库变更。请使用 signed-by/GPG 控制手动创建已复核文件。"
    ;;
  dnf|yum)
    echo "信息：这里有意不自动应用 yum/dnf 仓库变更。请手动创建 gpgcheck=1 的已复核 .repo 文件。"
    ;;
  zypper)
    sudo zypper addrepo "$TARGET_REPO_URL" "$TARGET_REPO_NAME"
    ;;
  brew)
    brew tap "$TARGET_REPO_NAME" "$TARGET_REPO_URL"
    ;;
  *) echo "信息：不支持的软件包管理器；未执行变更。" ;;
esac
