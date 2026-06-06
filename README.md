# OpsBatch 运维内容库

这是一个用于 OpsBatch 的运维命令、脚本和快捷指令仓库。仓库既提供少量安全、通用的示例内容，也提供模板和字段约定，方便后续扩展成团队自己的运维知识库。

## 目录结构

```text
.
├── library.json                 # 运维库元信息
├── commands/                    # 运维命令 YAML
│   ├── system/                  # 系统巡检
│   ├── process/                 # 进程巡检与排障
│   ├── cpu/                     # CPU 巡检与排障
│   ├── memory/                  # 内存巡检与排障
│   ├── network/                 # 网络排障
│   ├── disk/                    # 磁盘检查
│   ├── log/                     # 日志查看
│   ├── service/                 # 服务状态
│   └── troubleshooting/         # 通用排障
├── scripts/                     # 运维脚本
│   ├── shell/                   # Shell 脚本及 .meta.json
│   ├── python/                  # Python 脚本及 .meta.json
│   └── powershell/              # PowerShell 脚本及 .meta.json
├── quick-actions/               # 快捷指令 JSON
├── templates/                   # 新增内容时可复制的模板
└── tools/validate_library.py    # 本地结构与格式检查脚本
```

## 命令文件约定

命令文件放在 `commands/<category>/<name>.yml` 或 `commands/<category>/<name>.yaml`，首版字段贴合 OpsBatch 命令库字段：

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

字段说明：

| 字段 | 说明 |
| --- | --- |
| `name` | 命令显示名称 |
| `command` | 实际执行命令，可用 YAML block scalar 写多行 |
| `category` | 分类，建议与目录名一致 |
| `tags` | 标签数组 |
| `risk` | 风险等级：`low` / `medium` / `high` |
| `description` | 用途和注意事项 |
| `platform` | 适用平台数组 |

## 脚本文件约定

脚本正文放在对应语言目录下，每个脚本必须配套同名 `.meta.json`：

```text
scripts/shell/check-service.sh
scripts/shell/check-service.meta.json
```

`.meta.json` 字段：

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

## 快捷指令约定

快捷指令放在 `quick-actions/*.json`，采用“内联步骤 + 文件引用”结构：

```json
{
  "name": "每日基础巡检",
  "steps": [
    {
      "name": "检查系统负载",
      "type": "command",
      "ref": "commands/system/check-load.yml"
    },
    {
      "name": "生成系统摘要",
      "type": "script",
      "ref": "scripts/python/health-check.py"
    }
  ]
}
```

这样快捷指令不依赖 OpsBatch 数据库 ID，也不会重复内联命令或脚本内容。

## 安全原则

- 默认示例只做只读检查，不主动删除、重启、覆盖或批量修改系统状态。
- 如果后续添加高风险操作，必须把 `risk` 标记为 `high`，并在 `description` 中说明风险与前置条件。
- 不要提交真实 Token、密钥、内网地址或客户环境信息。
- 参数要提供安全默认值，避免误扫大范围目标。

## 本地校验

```bash
python3 tools/validate_library.py
```

校验内容包括：

- `library.json` 和所有 `.json` 文件可解析。
- 命令 YAML 包含必需字段；如果环境安装了 PyYAML，会额外解析 YAML。
- 每个脚本示例都有同名 `.meta.json`。
- 快捷指令中的 `ref` 路径存在。
- Shell/Python 脚本尽量做语法检查；PowerShell 在安装 `pwsh` 时做语法检查。

## 贡献新内容

1. 从 `templates/` 复制对应模板。
2. 按目录分类放入 `commands/`、`scripts/` 或 `quick-actions/`。
3. 确保字段完整、命名清晰、风险等级准确。
4. 运行 `python3 tools/validate_library.py`。
5. 更新 `library.json` 中的分类（如新增分类）。
