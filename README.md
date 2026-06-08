# OpsBatch 运维内容库 / OpsBatch Operations Library

[![OpsBatch](https://img.shields.io/badge/OpsBatch-内容库-blue)](https://github.com/your-org/OpsBatch)
[![Commands](https://img.shields.io/badge/commands-196%20pairs-green)](commands/)
[![Shell scripts](https://img.shields.io/badge/shell-40%20pairs-orange)](scripts/shell/)
[![Quick actions](https://img.shields.io/badge/quick--actions-8%20pairs-purple)](quick-actions/)

OpsLibrary 是面向 OpsBatch 仓库同步 / 导入能力的双语运维内容库，提供可导入的命令元数据、Shell 脚本、快捷动作和库级元信息。内容覆盖基础巡检、故障排查、日志查看、服务状态检查、安全审计、部署和受保护维护等场景。

English artifacts are included for OpsBatch users who prefer English names, descriptions, script output, and quick-action steps.

## 当前状态 / Current status

计数按双语 stem 组统计；每组都有 `_cn` 与 `_en` 两个语言文件。实际内容文件数量为组数的两倍。

| 内容 / Content | 当前结构 / Current structure | 数量 / Count |
| :--- | :--- | ---: |
| 库级元信息 / Library metadata | `library_cn.json` / `library_en.json` | 2 files |
| 命令 / Commands | `commands/<category>/<name>_cn.yml` + `.sh`，`<name>_en.yml` + `.sh` | 196 bilingual pairs / 392 YAML + 392 Shell files |
| Shell 脚本库 / Shell script library | 本地脚本：`scripts/shell/<name>_cn.meta.json` + `.sh`，`<name>_en.meta.json` + `.sh`；外部脚本：双语 `.meta.json` 直接指向上游 Raw URL | 40 bilingual pairs / 80 metadata + 78 local Shell files |
| 快捷动作 / Quick actions | `quick-actions/<name>_cn.json` / `<name>_en.json` | 8 bilingual pairs / 16 JSON files |
| 模板 / Templates | `templates/*_cn.*` / `templates/*_en.*` | 8 files |
| 校验器 / Validator | `tools/validate_library.py` | 1 file |

当前已落地的命令目录按双语组计数：

| Directory | Pairs | Directory | Pairs |
| :--- | ---: | :--- | ---: |
| `security` | 42 | `network` | 19 |
| `disk` | 27 | `cpu` | 18 |
| `package-management` | 20 | `memory` | 18 |
| `process` | 17 | `log` | 17 |
| `system` | 12 | `user` | 5 |
| `service` | 1 |  |  |

## Breaking change：无后缀旧路径已移除

本仓库已从单语无后缀结构升级为显式 `_cn` / `_en` 双语结构，不再保留旧文件：

| 旧路径 / Old path | 新路径 / New path |
| :--- | :--- |
| `library.json` | `library_cn.json` / `library_en.json` |
| `commands/<category>/<name>.yml` | `commands/<category>/<name>_cn.yml` / `<name>_en.yml` |
| `commands/<category>/<name>.sh` | `commands/<category>/<name>_cn.sh` / `<name>_en.sh` |
| `scripts/shell/<name>.meta.json` | `scripts/shell/<name>_cn.meta.json` / `<name>_en.meta.json` |
| `scripts/shell/<name>.sh` | `scripts/shell/<name>_cn.sh` / `<name>_en.sh` |
| `quick-actions/<name>.json` | `quick-actions/<name>_cn.json` / `<name>_en.json` |

旧 Raw URL 和旧 quick-action `ref` 会失效。OpsBatch 导入或手动执行时必须显式选择 `_cn` 或 `_en` 文件。

Legacy Raw URLs and quick-action refs are breaking. Choose `_cn` or `_en` artifacts explicitly.

## 目录结构 / Directory layout

```text
.
├── library_cn.json
├── library_en.json
├── commands/
│   └── <category>/
│       ├── <command>_cn.yml
│       ├── <command>_cn.sh
│       ├── <command>_en.yml
│       └── <command>_en.sh
├── scripts/
│   └── shell/
│       ├── <script>_cn.meta.json
│       ├── <script>_cn.sh
│       ├── <script>_en.meta.json
│       └── <script>_en.sh
├── quick-actions/
│   ├── <quick-action>_cn.json
│   └── <quick-action>_en.json
├── templates/
│   ├── command_cn.yml
│   ├── command_en.yml
│   ├── script_cn.meta.json
│   ├── script_cn.sh
│   ├── script_en.meta.json
│   ├── script_en.sh
│   ├── quick-action_cn.json
│   └── quick-action_en.json
└── tools/
    └── validate_library.py
```

当前仓库的脚本库只管理 Shell 内容：默认在 `scripts/shell/` 下托管本地 `.sh`，也允许只维护双语 `.meta.json` 并直接引用可信上游 Shell Raw URL；Python / PowerShell 脚本不在当前内容范围内。

## 快速开始 / Quick start

### 在 OpsBatch 中同步 / 导入

在 OpsBatch 的仓库同步或内容导入功能中配置本仓库地址。导入端应按需要选择中文或英文入口：

- 中文库级元信息：`library_cn.json`
- English library metadata: `library_en.json`
- 中文命令、脚本和快捷动作：`*_cn.*`
- English commands, scripts, and quick actions: `*_en.*`

### 直接通过 Raw URL 执行

以下示例均为只读巡检命令。生产环境执行任何远程脚本前，建议先打开对应 `_cn.sh` / `_en.sh` 文件审阅内容。

中文脚本示例：

```bash
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_cn.sh | bash
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/disk/disk-usage_cn.sh | bash
```

English script examples:

```bash
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_en.sh | bash
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/disk/disk-usage_en.sh | bash
```

带参数执行时仍使用脚本约定的环境变量名；环境变量名不随语言翻译：

```bash
SAMPLES=10 INTERVAL=5 \
  curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/memory/memory-usage-sampling_cn.sh | bash
```

## 双语内容约定 / Bilingual content conventions

### 语言后缀 / Language suffixes

- 支持的语言后缀仅为 `_cn` 和 `_en`。
- 每个中文内容文件必须有同 stem 的英文文件；每个英文内容文件也必须有同 stem 的中文文件。
- 命令 YAML、命令 `.sh`、脚本 `.meta.json`、脚本 `.sh`、快捷动作 JSON 都必须使用显式语言后缀。
- managed content 区域不应再出现无后缀旧文件，例如 `library.json`、`commands/**/<name>.yml`、`commands/**/<name>.sh`、`scripts/shell/<name>.sh`、`scripts/shell/<name>.meta.json`、`quick-actions/<name>.json`。

### 中文侧与英文侧 / Chinese and English artifacts

- 中文侧文件：`*_cn.yml`、`*_cn.sh`、`*_cn.meta.json`、`*_cn.json`、`library_cn.json`。
- English artifacts: `*_en.yml`, `*_en.sh`, `*_en.meta.json`, `*_en.json`, and `library_en.json`.
- `category` 与 `tags` 是展示分类字段，不是不可翻译的机器字段：中文侧应尽量中文化，英文侧应保持英文。
- 中文侧 `name`、`description`、`category`、`tags`、`parameters[].description`、`steps[].name`、脚本输出、help / usage、错误提示和注释应尽量中文化。
- English-side display text should remain English.
- 技术名词可保留英文，例如 CPU、Shell、Docker、Kubernetes、HTTP、URL、TLS、SSH、I/O、NUMA、SMART。
- 不翻译执行语义：文件路径、目录名、URL、环境变量名、命令名、命令选项、确认变量、确认 token、参数 `name`、`required`、`default`、`risk`、`platform`。

### Shell 行为一致性 / Shell behavior consistency

`_cn.sh` 与 `_en.sh` 应保持相同执行行为，只允许用户可见文本和注释不同。不得因为本地化改变目标范围、默认值、删除 / 变更行为、确认变量、dry-run 逻辑或保护条件。

## 元数据字段说明 / Metadata fields

### 库级元信息 / Library metadata

- `library_cn.json`：中文库名称、描述和展示分类。
- `library_en.json`：English library name, description, and display taxonomy.
- 两者共享 `version`、`author`、`homepage`、`baseUrl` 等结构字段。
- `categories.commands` 与 `categories.scripts` 必须是数组；当前文件也可包含 `categories.quickActions` 作为展示分类。

### 命令 YAML / Command YAML

路径：

```text
commands/<category>/<name>_cn.yml
commands/<category>/<name>_cn.sh
commands/<category>/<name>_en.yml
commands/<category>/<name>_en.sh
```

最小中文示例：

```yaml
name: 检查系统负载
url: https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_cn.sh
category: 系统
tags:
- 巡检
- 系统
- 负载
risk: low
description: 查看系统运行时间和平均负载，用于判断 CPU 压力和基础运行状态。
platform:
- linux
- macos
parameters: []
```

Minimal English example:

```yaml
name: Check System Load
url: https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_en.sh
category: system
tags:
- inspection
- system
- load
risk: low
description: Collects read-only system load information.
platform:
- linux
- macos
parameters: []
```

| 字段 / Field | 必填 / Required | 说明 / Description |
| :--- | :---: | :--- |
| `name` | 是 / Yes | 当前语言的显示名称 |
| `url` | 是 / Yes | 同语言 `.sh` 的 HTTP(S) Raw URL；`*_cn.yml` 指向 `*_cn.sh`，`*_en.yml` 指向 `*_en.sh` |
| `category` | 是 / Yes | 当前语言的展示分类；中文侧中文化，英文侧英文 |
| `tags` | 是 / Yes | 当前语言的展示标签数组；中文侧中文化，英文侧英文 |
| `risk` | 是 / Yes | 风险等级：`low` / `medium` / `high` |
| `description` | 是 / Yes | 当前语言的用途、输出和注意事项说明 |
| `platform` | 是 / Yes | 适用平台数组：`linux` / `macos` / `windows` |
| `parameters` | 是 / Yes | 参数定义数组；无参数时为 `[]` |

`parameters` 子字段：

| 字段 | 说明 |
| :--- | :--- |
| `name` | 参数名或环境变量名，不翻译 |
| `description` | 当前语言的参数说明 |
| `required` | 是否必填，布尔值 |
| `default` | 默认值；不因语言变化改变语义 |

### Shell 脚本库元数据 / Shell script metadata

路径：

```text
scripts/shell/<name>_cn.meta.json
scripts/shell/<name>_cn.sh
scripts/shell/<name>_en.meta.json
scripts/shell/<name>_en.sh
```

若条目直接引用可信上游脚本，可只提供双语元数据文件：

```text
scripts/shell/<name>_cn.meta.json
scripts/shell/<name>_en.meta.json
```

最小中文示例：

```json
{
  "name": "检查服务状态",
  "url": "https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/scripts/shell/check-service_cn.sh",
  "language": "shell",
  "category": "服务",
  "tags": ["服务", "巡检"],
  "risk": "low",
  "description": "检查指定服务是否处于运行状态。默认检查 ssh，可通过参数或 SERVICE 环境变量覆盖。",
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

字段与命令 YAML 基本一致，额外包含：

| 字段 / Field | 必填 / Required | 说明 / Description |
| :--- | :---: | :--- |
| `language` | 是 / Yes | 当前内容库只管理 Shell 内容，值为 `shell` |
| `url` | 是 / Yes | 默认指向同语言本地脚本 Raw URL；若直接引用可信上游脚本，可指向外部 HTTP(S) Shell Raw URL |

### 快捷动作 JSON / Quick-action JSON

路径：

```text
quick-actions/<name>_cn.json
quick-actions/<name>_en.json
```

快捷动作通过文件路径 `ref` 组合命令和脚本，不使用数据库 ID。顶层 `url` 必须指向当前 quick-action JSON；step 的 `ref` 与可选 `url` 必须引用同语言资源。

中文示例：

```json
{
  "name": "每日基础巡检",
  "description": "串联系统负载、内存、磁盘与服务状态检查，适合作为日常只读巡检入口。",
  "url": "https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/quick-actions/daily-check_cn.json",
  "category": "巡检",
  "risk": "low",
  "tags": ["每日", "巡检", "系统"],
  "platform": ["linux", "macos"],
  "steps": [
    {
      "name": "检查系统负载",
      "type": "command",
      "ref": "commands/system/check-load_cn.yml",
      "url": "https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_cn.yml",
      "continueOnError": true
    },
    {
      "name": "检查默认服务状态",
      "type": "script",
      "ref": "scripts/shell/check-service_cn.sh",
      "url": "https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/scripts/shell/check-service_cn.sh",
      "args": ["ssh"],
      "continueOnError": true
    }
  ]
}
```

English step references must use `_en` resources:

```json
{
  "name": "Check System Load",
  "type": "command",
  "ref": "commands/system/check-load_en.yml",
  "url": "https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_en.yml",
  "continueOnError": true
}
```

`steps[]` 字段：

| 字段 / Field | 说明 / Description |
| :--- | :--- |
| `name` | 当前语言的步骤显示名称 |
| `type` | `command` 或 `script` |
| `ref` | 仓库根目录相对路径；必须存在且与 quick-action 语言一致 |
| `url` | 可选 HTTP(S) Raw URL；如存在，目标路径必须与 `ref` 一致 |
| `args` | 可选参数数组，通常用于脚本步骤 |
| `continueOnError` | 当前步骤失败时是否继续后续步骤 |

## 新增 / 维护内容流程

1. 从 `templates/` 复制同 stem 的 `_cn` 和 `_en` 模板，例如：
   - `templates/command_cn.yml` / `templates/command_en.yml`
   - `templates/script_cn.sh` / `templates/script_en.sh`
   - `templates/script_cn.meta.json` / `templates/script_en.meta.json`
   - `templates/quick-action_cn.json` / `templates/quick-action_en.json`
2. 放到目标目录并保持同 stem 配对，例如 `check-load_cn.yml` 与 `check-load_en.yml`。
3. 本地化显示字段和 Shell 用户可见文本；保持文件路径、URL、参数名、风险等级、平台、默认值和执行语义一致。
4. 检查所有 `url`：命令 YAML 必须指向同语言 `.sh`；脚本 meta 默认指向同语言 `.sh`，直接引用可信上游脚本时可指向外部 HTTP(S) Shell Raw URL；quick-action 顶层 `url` 必须指向当前 JSON 文件。
5. 检查所有 quick-action `steps[].ref` / `steps[].url`：中文动作只引用 `_cn`，英文动作只引用 `_en`。
6. 高风险内容先实现 dry-run / 候选摘要，再要求显式目标变量和确认变量，最后才允许真实变更。
7. 运行校验命令并修复所有错误。

## 校验命令 / Validation

每次修改内容库后至少运行：

```bash
python3 tools/validate_library.py
git diff --check
```

如果修改了校验器，再运行：

```bash
python3 -m py_compile tools/validate_library.py
```

`tools/validate_library.py` 会检查：

- `library_cn.json` / `library_en.json` 存在且字段完整，旧 `library.json` 不存在。
- JSON / YAML 语法正确。
- 命令 YAML 必填字段、`risk`、`tags` / `platform` / `parameters` 数组字段正确。
- 命令 YAML 与同语言 `.sh` 配对，且 `url` 指向同语言 `.sh`。
- 命令 `.sh` 使用 `_cn` / `_en` 后缀并存在同语言 YAML。
- `scripts/shell/*.sh` 使用 `_cn` / `_en` 后缀，存在同语言 `.meta.json`；脚本 meta 使用 `_cn` / `_en` 后缀，成对存在，且 `url` 指向同语言本地 `.sh` 或外部 HTTP(S) 脚本 URL。
- `_cn` / `_en` 兄弟文件配对完整。
- quick-action 必填字段、非空 `steps`、step `type`、`ref` 存在性和语言一致性正确。
- quick-action 顶层 `url` 指向自身，step `url` 与 `ref` 目标一致。
- managed content 区域没有无后缀旧文件。
- Bash 可用时，对命令脚本和 `scripts/shell/*.sh` 执行 `bash -n`。

## 风险与安全约定 / Safety conventions

| 风险 / Risk | 用途 / Use | 要求 / Requirement |
| :--- | :--- | :--- |
| `low` | 只读巡检、信息收集 | 不修改系统状态 |
| `medium` | 可能较重、较吵或暴露敏感运行细节的检查 / 维护 | 明确范围、参数和输出风险 |
| `high` | 会修改状态或具有破坏性的操作 | 默认 dry-run，要求显式目标和确认变量，说明不可逆风险 |

安全原则：

- 默认只读优先；不要在示例中默认删除、重启、覆盖或批量修改。
- 高风险脚本必须先展示候选或执行计划，再执行真实变更。
- 高风险示例必须要求显式目标变量和确认变量，不能因为语言本地化降低保护强度。
- 本地化不得弱化 dry-run、确认、目标限制、权限检查或破坏性操作保护。
- 不提交真实 token、密钥、客户环境地址或敏感内部信息。

## License

MIT License
