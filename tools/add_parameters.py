#!/usr/bin/env python3
"""
自动为 commands/ 目录下含动态参数的 YAML 命令文件添加 parameters 字段。
用法: python3 tools/add_parameters.py [--dry-run]
"""
import os
import re
import sys

try:
    import yaml
except ImportError:
    print("Error: PyYAML is required. Install with: pip install pyyaml")
    sys.exit(1)

# ── 参数名 → 中文描述映射 ──────────────────────────────────────────────
PARAM_DESCRIPTIONS = {
    # 通用目标
    "TARGET_USER": "目标用户名",
    "TARGET_HOST": "目标主机地址",
    "TARGET_PORT": "目标端口号",
    "TARGET_DIR": "目标目录路径",
    "TARGET_FILE": "目标文件路径",
    "TARGET_DEVICE": "目标设备路径（如 /dev/sda）",
    "TARGET_MOUNT": "目标挂载点路径",
    "TARGET_PACKAGE": "目标软件包名",
    "TARGET_SERVICE": "目标服务名称",
    "TARGET_GROUP": "目标用户组名",
    "TARGET_PATH": "目标文件或目录路径",
    "TARGET_URL": "目标 URL 地址",
    "TARGET_LOCK_FILE": "目标锁文件路径",
    "TARGET_LOCK_FIX_SCOPE": "锁修复范围",
    "TARGET_REPO_NAME": "仓库名称",
    "TARGET_REPO_URL": "仓库 URL 地址",
    "TARGET_LOG_DIR": "目标日志目录路径",
    "TARGET_MODE": "目标权限模式（如 0644）",
    "TARGET_SHELL": "目标 Shell 路径",
    "CERT_DIR": "证书搜索目录",
    "CERT_PATH": "证书文件路径",
    "SSHD_CONFIG": "sshd 配置文件路径",
    "LOG_FILE": "日志文件路径",
    "LOGROTATE_CONFIG": "logrotate 配置文件路径",
    "LOGROTATE_STATE": "logrotate 状态文件路径",
    "SCAN_ROOT": "扫描根目录",
    "CACHE_TARGET": "缓存清理目标",
    "QUARANTINE_DIR": "隔离文件存放目录",

    # 进程
    "PID": "目标进程 ID",
    "PROCESS_PATTERN": "进程名或命令行匹配模式",

    # 输出控制
    "LINES": "显示行数",
    "LIMIT": "显示数量上限",
    "PROCESS_LIMIT": "显示进程数量上限",
    "TOP_LIMIT": "显示排名数量上限",
    "MAX_KEYS": "最大密钥数量告警阈值",
    "DEPTH": "目录扫描深度",
    "MAX_DEPTH": "最大递归深度",
    "MIN_SIZE": "最小文件大小",
    "MAX_HOPS": "最大路由跳数",
    "SAMPLE_SECONDS": "采样时长（秒）",
    "SAMPLES": "采样次数",
    "INTERVAL": "采样间隔（秒）",
    "TIMEOUT_SECONDS": "超时时间（秒）",
    "PACKET_SIZE": "探测包大小（字节）",

    # 时间范围
    "SINCE": "起始时间",
    "UNTIL": "结束时间",
    "OLDER_THAN_DAYS": "超过指定天数",

    # 匹配模式
    "PATTERN": "搜索关键词或正则表达式",
    "LOG_PATTERN": "日志搜索模式（支持正则）",
    "AUTH_PATTERN": "认证失败搜索模式",
    "SSH_LOG_PATTERN": "SSH 日志搜索模式",
    "PRIVILEGE_PATTERN": "权限提升搜索模式",
    "SECURITY_LOG_PATTERN": "安全日志搜索模式",
    "KERNEL_LOG_PATTERN": "内核日志搜索模式",
    "CRON_PATTERN": "定时任务日志搜索模式",
    "FILE_LIST": "要校验的文件路径列表",

    # 用户/操作参数
    "SERVICE_NAME": "服务名称",
    "NEW_USER": "新用户名",
    "NEW_USER_COMMENT": "新用户注释（GECOS 字段）",
    "NEW_USER_HOME": "新用户家目录路径",
    "NEW_USER_SHELL": "新用户默认 Shell",
    "REMOVE_HOME": "是否删除用户家目录",

    # 包管理
    "PACKAGE_MANAGER": "包管理器（apt/yum/dnf/pacman/auto）",

    # 服务
    "SERVICE": "服务名称",

    # 操作控制
    "REPO_ACTION": "仓库操作类型",
    "GROUP_ACTION": "组成员操作（add/remove）",
    "LOCK_FIX_ACTION": "锁修复操作类型",
    "TARGET_PROTO": "协议类型（tcp/udp）",
    "TARGET_SOURCE": "来源地址（CIDR 或 IP）",

    # 确认令牌（protected 命令）
    "CONFIRM_LOCK_USER": "确认锁定令牌，需设为 LOCK_TARGET_USER 才执行",
    "CONFIRM_UNLOCK_USER": "确认解锁令牌，需设为 UNLOCK_TARGET_USER 才执行",
    "CONFIRM_DELETE_USER": "确认删除令牌，需设为 DELETE_TARGET_USER 才执行",
    "CONFIRM_CREATE_USER": "确认创建令牌，需设为 CREATE_TARGET_USER 才执行",
    "CONFIRM_EXPIRE_PASSWORD": "确认过期密码令牌，需设为 EXPIRE_TARGET_USER 才执行",
    "CONFIRM_SHELL_CHANGE": "确认修改 Shell 令牌，需设为 CHANGE_SHELL_TARGET_USER 才执行",
    "CONFIRM_GROUP_CHANGE": "确认组成员变更令牌",
    "CONFIRM_CHMOD": "确认修改权限令牌",
    "CONFIRM_STOP_SERVICE": "确认停止服务令牌",
    "CONFIRM_FIREWALL_ALLOW": "确认添加防火墙规则令牌",
    "CONFIRM_SSH_HARDEN": "确认 SSH 加固令牌",
    "CONFIRM_SYSCTL": "确认内核参数加固令牌",
    "CONFIRM_QUARANTINE": "确认隔离文件令牌",
    "CONFIRM_INSTALL": "确认安装令牌",
    "CONFIRM_UNINSTALL": "确认卸载令牌",
    "CONFIRM_UPGRADE": "确认升级令牌",
    "CONFIRM_LOCK_FIX": "确认锁修复令牌",
    "CONFIRM_CLEAN": "确认清理令牌",
    "CONFIRM_REPO_CHANGE": "确认仓库配置变更令牌",
    "CONFIRM_RESET_AUTH_LOCK": "确认重置认证锁定令牌",
    "CONFIRM_COMPRESS": "确认压缩令牌",
    "CONFIRM_ROTATE": "确认轮转令牌",
    "CONFIRM_TRUNCATE": "确认截断令牌",
    "CONFIRM_DELETE": "确认删除令牌",
    "CONFIRM_FSCK": "确认文件系统检查令牌",
    "CONFIRM_UMOUNT": "确认卸载令牌",

    # 容器/K8s
    "NAMESPACE": "Kubernetes 命名空间",
    "POD_NAME": "Pod 名称",
    "CONTAINER_NAME": "容器名称",

    # 系统参数
    "SYSCTL_KEY": "sysctl 参数键名",
    "SYSCTL_VALUE": "sysctl 参数目标值",
}

# ── YAML 定制 representer，保持中文可读 ───────────────────────────────
class CleanDumper(yaml.SafeDumper):
    pass

def _str_representer(dumper, data):
    if '\n' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    if data in ('true', 'false', 'yes', 'no', 'on', 'off', 'null', '~', ''):
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')
    if re.match(r'^\d+(\.\d+)?$', data):
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)

CleanDumper.add_representer(str, _str_representer)


def extract_parameters(command_text):
    """从命令文本中提取参数名、默认值。"""
    params = []
    seen = set()

    # 匹配以下模式：
    #   VAR="${VAR:-default}"     (带引号)
    #   VAR=${VAR:-default}       (不带引号)
    #   var="${UPPER:-default}"   (小写变量名引用大写参数)
    patterns = [
        re.compile(r'[A-Za-z_][A-Za-z0-9_]*="\$\{([A-Z][A-Z0-9_]*):-([^}]*)\}"'),
        re.compile(r'[A-Za-z_][A-Za-z0-9_]*=\$\{([A-Z][A-Z0-9_]*):-([^}]*)\}'),
    ]

    for pattern in patterns:
        for match in pattern.finditer(command_text):
            name = match.group(1)
            default = match.group(2)
            if name not in seen:
                seen.add(name)
                params.append({"name": name, "default": default})

    return params


def determine_required(param_name, default_value):
    """判断参数是否必填。"""
    # CONFIRM_* 令牌：空默认值 → 必填才能执行真实操作
    if param_name.startswith("CONFIRM_"):
        return False  # technically optional; command runs in dry-run mode without it
    # 空默认值的目标参数 → 必填
    if default_value == "" and not param_name.startswith("CONFIRM_"):
        return True
    return False


def build_parameter(name, default_value):
    """构建单个参数字典。"""
    description = PARAM_DESCRIPTIONS.get(name, name)
    required = determine_required(name, default_value)

    entry = {
        "name": name,
        "description": description,
        "required": required,
    }
    if default_value:
        entry["default"] = default_value
    else:
        entry["default"] = ""

    return entry


def process_file(filepath, dry_run=False):
    """处理单个 YAML 文件。"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)

    if not data or 'command' not in data:
        return None

    command_text = data.get('command', '')
    params = extract_parameters(command_text)

    if not params:
        return None

    # 构建参数列表
    param_list = []
    for p in params:
        entry = build_parameter(p["name"], p["default"])
        param_list.append(entry)

    if not param_list:
        return None

    # 更新数据
    data['parameters'] = param_list

    if dry_run:
        return (filepath, param_list)

    # 写回文件
    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.dump(data, f, Dumper=CleanDumper, default_flow_style=False,
                  allow_unicode=True, sort_keys=False, width=200)

    return (filepath, param_list)


def main():
    dry_run = "--dry-run" in sys.argv

    if dry_run:
        print("=== DRY RUN MODE ===\n")

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    # 遍历所有 command 根目录：传统脚本命令 commands/ 与内联原始命令 docker-commands/。
    command_roots = ['commands', 'docker-commands']

    results = []
    errors = []

    for root_name in command_roots:
        commands_dir = os.path.join(repo_root, root_name)
        if not os.path.isdir(commands_dir):
            continue
        for root, dirs, files in os.walk(commands_dir):
            dirs.sort()
            for fname in sorted(files):
                if not fname.endswith(('.yml', '.yaml')):
                    continue
                filepath = os.path.join(root, fname)
                try:
                    result = process_file(filepath, dry_run)
                    if result:
                        results.append(result)
                except Exception as e:
                    errors.append((filepath, str(e)))

    # 报告
    print(f"处理完成: {len(results)} 个文件已添加 parameters 字段")
    if errors:
        print(f"\n错误 ({len(errors)} 个):")
        for fp, err in errors:
            print(f"  {fp}: {err}")

    if dry_run:
        print("\n=== 变更预览 ===\n")
        for filepath, params in results:
            relpath = os.path.relpath(filepath)
            print(f"  {relpath}:")
            for p in params:
                req = "必填" if p["required"] else "可选"
                defval = p.get("default", "")
                print(f"    - {p['name']} ({req}, 默认={defval!r}): {p['description']}")
            print()


if __name__ == "__main__":
    main()
