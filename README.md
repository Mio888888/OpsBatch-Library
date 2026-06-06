# OpsBatch 运维内容库

[![OpsBatch](https://img.shields.io/badge/OpsBatch-内容库-blue)](https://github.com/your-org/OpsBatch) [![命令](https://img.shields.io/badge/命令-196-green)](commands/) [![脚本](https://img.shields.io/badge/脚本-43-orange)](scripts/) [![快捷指令](https://img.shields.io/badge/快捷指令-8-purple)](quick-actions/)

> 面向 [OpsBatch](https://github.com/your-org/OpsBatch) 的运维命令、脚本和快捷指令仓库。覆盖系统巡检、故障排查、安全审计、部署管理、监控检查等场景，开箱即用，方便团队定制扩展。

## 内容一览

| 类型 | 数量 | 说明 |
| :--- | ---: | :--- |
| **命令** (YAML) | 196 条 | 覆盖 12 个分类，单条命令可直接在终端执行 |
| **脚本** (Shell / Python / PowerShell) | 43 个 | 每个脚本均附带 `.meta.json` 元数据，支持参数化执行 |
| **快捷指令** (JSON) | 8 套 | 将多条命令和脚本串联为可一键执行的巡检 / 排障流程 |
| **模板** | 4 份 | 新增内容时的快速复制模板 |

### 命令库分类

| 分类 | 数量 | 典型场景 |
| :--- | ---: | :--- |
| 🔒 `security` | 42 | SSH 审计、防火墙状态、用户权限检查、入侵检测 |
| 💾 `disk` | 27 | 磁盘用量、SMART 健康、inode 耗尽、大文件定位 |
| 📦 `package-management` | 20 | 包更新、仓库源检查、安全补丁、锁修复 |
| 🌐 `network` | 19 | 端口检查、连通性测试、DNS 解析、路由追踪 |
| 🧠 `cpu` | 18 | CPU 使用率、负载压力、温度监控、NUMA 拓扑 |
| 🧮 `memory` | 18 | 内存使用、OOM 日志、Swap 分析、NUMA 内存分布 |
| ⚙️ `process` | 17 | 僵尸进程、线程分析、文件描述符、cgroup 信息 |
| 📋 `log` | 17 | 日志搜索、日志轮转、增长检测、内核日志 |
| 🖥️ `system` | 12 | 系统概览、负载检查、内核信息、资源限制 |
| 👤 `user` | 5 | 在线用户、用户详情、用户文件、活动痕迹 |
| 🔧 `service` | 1 | 服务状态检查 |
| 🔍 `troubleshooting` | — | 通用排障（预留分类） |

### 脚本库分类

| 语言 / 场景 | 数量 | 说明 |
| :--- | ---: | :--- |
| 🐚 Shell | 35 | 覆盖巡检、监控、安全、部署、维护五大场景 |
| 🐍 Python | 2 | TCP 端口检查、系统健康摘要 |
| 💻 PowerShell | 2 | 磁盘摘要、服务状态（Windows 场景） |

Shell 脚本按用途可归为：

- **巡检** (`inspection-*`)：系统清单、网络/磁盘盘点、支持清单
- **监控** (`monitoring-*`)：磁盘/内存阈值、HTTP 端点、DNS、TLS 证书过期
- **安全** (`security-*`)：账号权限审计、SSH/防火墙审计、基线加固检查、可疑活动指标
- **部署** (`deployment-*`)：预检、制品校验、发布切换、回滚计划、上线健康检查
- **维护** (`maintenance-*`)：健康摘要、日志维护、目录清理候选、临时文件清理

### 快捷指令

| 名称 | 场景 | 风险 |
| :--- | :--- | :--- |
| 每日基础巡检 | 串联负载、内存、磁盘、服务、健康摘要 | low |
| 主机安全基线巡检 | SSH 审计、防火墙、用户权限、文件完整性 | low |
| 网络/服务排障 | 连通性、端口、DNS、路由、活跃连接 | low |
| 包管理健康巡检 | 更新候选、安全补丁、仓库源、锁状态 | low |
| 包管理维护操作 | 缓存清理、锁修复、包升级 | medium~high |
| 安全加固处置 | 用户锁定、防火墙规则、SSH 加固 | high |
| 用户账号安全巡检 | 登录日志、权限审计、SSH 密钥检查 | low |
| 用户账号操作 | 创建/删除/锁定用户、Shell 变更 | medium~high |

## 目录结构

```text
.
├── library.json                 # 运维库元信息（名称、版本、分类索引）
├── commands/                    # 运维命令 YAML
│   ├── system/                  #   系统巡检（12 条）
│   ├── process/                 #   进程巡检与排障（17 条）
│   ├── cpu/                     #   CPU 巡检与排障（18 条）
│   ├── memory/                  #   内存巡检与排障（18 条）
│   ├── network/                 #   网络排障（19 条）
│   ├── disk/                    #   磁盘检查（27 条）
│   ├── package-management/      #   包管理巡检与维护（20 条）
│   ├── log/                     #   日志查看（17 条）
│   ├── user/                    #   用户与账号（5 条）
│   ├── security/                #   安全巡检与防御性排障（42 条）
│   ├── service/                 #   服务状态（1 条）
│   └── troubleshooting/         #   通用排障（预留）
├── scripts/                     # 运维脚本
│   ├── shell/                   #   Shell 脚本 + .meta.json
│   ├── python/                  #   Python 脚本 + .meta.json
│   └── powershell/              #   PowerShell 脚本 + .meta.json
├── quick-actions/               # 快捷指令 JSON（一键巡检/排障流程）
├── templates/                   # 新增内容时的模板文件
│   ├── command.yml              #   命令模板
│   ├── script.sh                #   Shell 脚本模板
│   ├── script.meta.json         #   脚本元数据模板
│   └── quick-action.json        #   快捷指令模板
└── tools/
    └── validate_library.py      # 本地结构与格式校验脚本
```

## 快速开始

### 1. 在 OpsBatch 中导入

在 OpsBatch 的「仓库同步」页面，添加本仓库地址即可自动扫描并导入命令和脚本：

```
https://github.com/your-org/OpsLibrary.git
```

### 2. 直接使用

也可以直接浏览 `commands/` 目录下的 YAML 文件，复制 `command` 字段中的命令在终端执行：

```bash
# 示例：检查系统负载
uptime

# 示例：查看磁盘使用情况
df -hT -x tmpfs -x devtmpfs | sort -k6
```

### 3. 本地校验

修改内容后，运行校验脚本确保格式和结构正确：

```bash
python3 tools/validate_library.py
```

## 文件格式约定

### 命令文件

路径：`commands/<category>/<name>.yml`

**无参数命令（静态）：**

```yaml
name: 检查系统负载
command: |
  uptime
category: system
tags:
  - inspection
risk: low
description: 查看系统运行时间和平均负载。
platform:
  - linux
  - macos
```

**含参数命令（动态）：**

```yaml
name: 按服务查看日志
command: |
  SERVICE_NAME="${SERVICE_NAME:-ssh}"
  SINCE="${SINCE:-2 hours ago}"
  LINES="${LINES:-120}"
  journalctl -u "$SERVICE_NAME" --since "$SINCE" -n "$LINES" --no-pager
category: log
tags:
  - log
  - service
risk: medium
description: 按服务名查看近期日志。
platform:
  - linux
  - macos
parameters:
  - name: SERVICE_NAME
    description: 服务名称
    required: false
    default: ssh
  - name: SINCE
    description: 起始时间
    required: false
    default: 2 hours ago
  - name: LINES
    description: 显示行数
    required: false
    default: "120"
```

**字段说明：**

| 字段 | 必填 | 说明 |
| :--- | :---: | :--- |
| `name` | ✅ | 命令显示名称 |
| `command` | ✅ | 实际执行命令，支持 YAML block scalar 多行 |
| `category` | ✅ | 分类，建议与目录名一致 |
| `tags` | ✅ | 标签数组（如 `inspection`、`troubleshooting`、`protected`） |
| `risk` | ✅ | 风险等级：`low` / `medium` / `high` |
| `description` | ✅ | 用途说明和注意事项 |
| `platform` | ✅ | 适用平台数组：`linux`、`macos`、`windows` |
| `parameters` | — | 参数定义数组（仅含动态参数的命令需要） |

**`parameters` 子字段：**

| 字段 | 说明 |
| :--- | :--- |
| `name` | 环境变量名（如 `TARGET_HOST`、`LINES`） |
| `description` | 参数用途说明 |
| `required` | 是否必填（`true` / `false`） |
| `default` | 默认值（空字符串表示必须由用户指定） |

> **命名约定：** `risk: high` 的命令文件名以 `protected-` 开头，便于识别和筛选。

### 脚本文件

路径：`scripts/<language>/<name>.<ext>` + `scripts/<language>/<name>.meta.json`

每个脚本必须配套同名的 `.meta.json` 元数据文件：

```text
scripts/shell/check-service.sh
scripts/shell/check-service.meta.json
```

**`.meta.json` 字段：**

```json
{
  "name": "检查服务状态",
  "language": "shell",
  "category": "service",
  "tags": ["service", "inspection"],
  "risk": "low",
  "description": "检查指定服务是否处于运行状态。",
  "parameters": [
    {
      "name": "service",
      "description": "服务名称",
      "required": false,
      "default": "ssh"
    }
  ],
  "platform": ["linux", "macos"]
}
```

**字段说明：**

| 字段 | 必填 | 说明 |
| :--- | :---: | :--- |
| `name` | ✅ | 脚本显示名称 |
| `language` | ✅ | 脚本语言：`shell` / `python` / `powershell` |
| `category` | ✅ | 分类 |
| `tags` | ✅ | 标签数组（如 `inspection`、`monitoring`、`security`、`deployment`、`protected`） |
| `risk` | ✅ | 风险等级 |
| `description` | ✅ | 用途说明 |
| `parameters` | ✅ | 参数定义数组（可为空） |
| `platform` | ✅ | 适用平台数组 |

### 快捷指令

路径：`quick-actions/<name>.json`

快捷指令通过 `ref` 引用命令和脚本，不重复内联内容，也不依赖数据库 ID：

```json
{
  "name": "每日基础巡检",
  "description": "串联系统负载、内存、磁盘、服务状态与系统健康摘要。",
  "category": "inspection",
  "risk": "low",
  "tags": ["daily", "inspection", "system"],
  "platform": ["linux", "macos"],
  "steps": [
    {
      "name": "检查系统负载",
      "type": "command",
      "ref": "commands/system/check-load.yml",
      "continueOnError": true
    },
    {
      "name": "生成系统健康摘要",
      "type": "script",
      "ref": "scripts/python/health-check.py",
      "continueOnError": true
    }
  ]
}
```

**`steps` 中每个步骤的字段：**

| 字段 | 说明 |
| :--- | :--- |
| `name` | 步骤显示名称 |
| `type` | `command` 或 `script` |
| `ref` | 指向命令 YAML 或脚本文件的相对路径 |
| `args` | 脚本参数数组（可选，仅 `type: script` 时生效） |
| `continueOnError` | 该步骤失败时是否继续执行后续步骤（默认 `false`） |

## 风险等级说明

| 等级 | 含义 | 行为约束 |
| :--- | :--- | :--- |
| 🟢 `low` | 只读检查 | 不修改任何系统状态，安全执行 |
| 🟡 `medium` | 轻微变更 | 可能修改非关键配置或清理临时文件 |
| 🔴 `high` | 重要变更 | 修改系统状态、用户、服务或安全配置；**必须**在 `description` 中说明风险与前置条件；默认只输出执行计划，要求显式确认后才执行 |

> 所有 `risk: high` 的命令和脚本，文件名均以 `protected-` 前缀标识。

## 安全原则

1. **只读优先** — 默认示例只做只读检查，不主动删除、重启、覆盖或批量修改系统状态。
2. **高风险标记** — 高风险操作必须将 `risk` 设为 `high`，并在 `description` 中说明风险与前置条件。
3. **安全默认值** — 高风险操作默认只输出计划或拒绝执行，要求显式目标变量和确认后才执行真实变更。
4. **参数安全** — 参数要提供安全默认值，避免误扫大范围目标。
5. **无敏感信息** — 不提交真实 Token、密钥、内网地址或客户环境信息。

## 贡献指南

### 新增命令

1. 复制 `templates/command.yml` 模板。
2. 放入 `commands/<category>/` 下对应的分类目录。
3. 填写完整字段，确保 `risk` 等级准确。
4. 运行 `python3 tools/validate_library.py` 校验。
5. 如新增分类，同步更新 `library.json` 中的 `categories.commands`。

### 新增脚本

1. 复制 `templates/script.sh`（或 `.py` / `.ps1`）和 `templates/script.meta.json` 模板。
2. 放入 `scripts/<language>/` 目录。
3. 脚本文件与 `.meta.json` 文件名（不含扩展名）必须一致。
4. 运行 `python3 tools/validate_library.py` 校验。

### 新增快捷指令

1. 复制 `templates/quick-action.json` 模板。
2. 放入 `quick-actions/` 目录。
3. 确保所有 `ref` 路径指向已存在的文件。
4. 运行 `python3 tools/validate_library.py` 校验。

## 本地校验工具

```bash
python3 tools/validate_library.py
```

校验内容包括：

- ✅ `library.json` 和所有 `.json` 文件可正确解析
- ✅ 命令 YAML 包含所有必需字段（安装 PyYAML 时额外解析 YAML 内容）
- ✅ 每个脚本都有同名 `.meta.json` 元数据文件
- ✅ 快捷指令中所有 `ref` 引用路径存在
- ✅ Shell / Python 脚本做语法检查；PowerShell 在安装 `pwsh` 时做语法检查

## 许可证

MIT License
