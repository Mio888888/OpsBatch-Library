# OpsBatch 运维内容库 / OpsBatch Operations Library

[![OpsBatch](https://img.shields.io/badge/OpsBatch-内容库-blue)](https://github.com/your-org/OpsBatch)
[![Commands](https://img.shields.io/badge/commands-bilingual-green)](commands/)
[![Shell scripts](https://img.shields.io/badge/shell-bilingual-orange)](scripts/shell/)
[![Quick actions](https://img.shields.io/badge/quick--actions-bilingual-purple)](quick-actions/)

> 面向 OpsBatch 的中英双语运维命令、Shell 脚本和快捷指令仓库。覆盖系统巡检、故障排查、安全审计、部署管理、监控检查等场景。
>
> A bilingual Chinese/English operations content repository for OpsBatch, covering baseline inspection, troubleshooting, defensive security checks, deployment operations, monitoring checks, and protected maintenance workflows.

## Breaking change: 显式双语文件后缀

本仓库已升级为显式双语文件结构，不再保留旧的无后缀内容文件。

This repository now uses explicit bilingual file suffixes and no longer keeps legacy unsuffixed content files.

| 旧格式 / Old | 新格式 / New |
| :--- | :--- |
| `library.json` | `library_cn.json` / `library_en.json` |
| `commands/<category>/<name>.yml` | `commands/<category>/<name>_cn.yml` / `<name>_en.yml` |
| `commands/<category>/<name>.sh` | `commands/<category>/<name>_cn.sh` / `<name>_en.sh` |
| `scripts/shell/<name>.meta.json` | `scripts/shell/<name>_cn.meta.json` / `<name>_en.meta.json` |
| `scripts/shell/<name>.sh` | `scripts/shell/<name>_cn.sh` / `<name>_en.sh` |
| `quick-actions/<name>.json` | `quick-actions/<name>_cn.json` / `<name>_en.json` |

旧 Raw URL 和旧 quick-action `ref` 会失效；请按语言选择 `_cn` 或 `_en` 文件。

Legacy Raw URLs and quick-action refs are breaking; choose `_cn` or `_en` artifacts explicitly.

## 内容一览 / Contents

| 类型 / Type | 说明 / Description |
| :--- | :--- |
| `library_cn.json` / `library_en.json` | 库级元信息 / library-level metadata |
| `commands/` | 双语命令 YAML + 同语言 Shell 执行脚本 / bilingual command YAML plus same-language Shell scripts |
| `scripts/shell/` | 双语 Shell 脚本库 + 同语言 `.meta.json` / bilingual Shell script library plus same-language metadata |
| `quick-actions/` | 双语快捷指令，step `ref` 指向同语言资源 / bilingual quick actions whose step refs point to same-language resources |
| `templates/` | 新增双语内容时使用的模板 / templates for new bilingual content |
| `tools/validate_library.py` | 内容库结构与格式校验器 / repository validator |

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

## 快速开始 / Quick start

### 中文示例

```bash
# 查看系统负载（中文输出/中文元数据）
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_cn.sh | bash

# 查看磁盘使用情况（中文）
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/disk/disk-usage_cn.sh | bash
```

### English examples

```bash
# Check system load (English artifact)
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_en.sh | bash

# Check disk usage (English artifact)
curl -fsSL https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/disk/disk-usage_en.sh | bash
```

### 本地校验 / Local validation

```bash
python3 tools/validate_library.py
```

校验器会检查：

The validator checks:

- `library_cn.json` 与 `library_en.json` 是否存在且字段完整。
- every localized command YAML has the matching same-language `.sh` file.
- every Shell script has the matching same-language `.meta.json` file.
- every `_cn` artifact has an `_en` sibling and every `_en` artifact has a `_cn` sibling.
- YAML / JSON `url` values point to same-language resources.
- quick-action step `ref` / `url` values point to same-language resources.
- no legacy unsuffixed content files remain in the managed content areas.
- JSON/YAML syntax, risk values, array fields, refs, and Shell syntax are valid.

## 文件格式约定 / File format conventions

### 命令文件 / Command files

路径 / Path:

```text
commands/<category>/<name>_cn.yml
commands/<category>/<name>_cn.sh
commands/<category>/<name>_en.yml
commands/<category>/<name>_en.sh
```

中文 YAML 示例：

```yaml
name: 检查系统负载
url: https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_cn.sh
category: system
tags:
- inspection
- system
- load
risk: low
description: 查看系统运行时间和平均负载，用于判断 CPU 压力和基础运行状态。
platform:
- linux
- macos
parameters: []
```

English YAML example:

```yaml
name: Check System Load
url: https://raw.githubusercontent.com/Mio888888/OpsBatch-Library/main/commands/system/check-load_en.sh
category: system
tags:
- inspection
- system
- load
risk: low
description: Collects read-only information for system inventory and runtime inspection with the check system load workflow.
platform:
- linux
- macos
parameters: []
```

字段 / Fields:

| 字段 / Field | Required | 说明 / Description |
| :--- | :---: | :--- |
| `name` | ✅ | 当前语言的显示名称 / display name in the artifact language |
| `url` | ✅ | 同语言 Shell 脚本 Raw URL / Raw URL for the same-language Shell script |
| `category` | ✅ | 机器字段，不翻译 / machine field, not localized |
| `tags` | ✅ | 机器字段，不翻译 / machine field, not localized |
| `risk` | ✅ | `low` / `medium` / `high` |
| `description` | ✅ | 当前语言说明 / description in the artifact language |
| `platform` | ✅ | `linux` / `macos` / `windows` |
| `parameters` | ✅ | 参数数组；参数名不翻译，参数说明本地化 / parameter names stay stable, descriptions are localized |

### Shell 脚本 / Shell scripts

- `_cn.sh` 与 `_en.sh` 必须保持相同执行逻辑。
- Only user-visible output, help/usage text, error messages, and comments should differ by language.
- 不翻译变量名、环境变量名、命令选项、路径和确认变量。
- Do not change protected/high-risk confirmation semantics while localizing text.

### Shell 脚本库元数据 / Script metadata

路径 / Path:

```text
scripts/shell/<name>_cn.meta.json
scripts/shell/<name>_cn.sh
scripts/shell/<name>_en.meta.json
scripts/shell/<name>_en.sh
```

`url` 必须指向同语言 `.sh` 文件。

The `url` field must point to the same-language `.sh` file.

### 快捷指令 / Quick actions

路径 / Path:

```text
quick-actions/<name>_cn.json
quick-actions/<name>_en.json
```

规则 / Rules:

- `_cn.json` 的 `name`、`description`、`steps[].name` 使用中文。
- `_en.json` uses English `name`, `description`, and `steps[].name`.
- `_cn.json` step `ref` / `url` must point only to `_cn` resources.
- `_en.json` step `ref` / `url` must point only to `_en` resources.
- Repository quick actions must use file-path refs, not database IDs.

### 库级元信息 / Library metadata

- `library_cn.json`: 中文库名称和描述。
- `library_en.json`: English library name and description.
- Both files share structural fields such as `version`, `author`, `homepage`, `categories`, and `baseUrl`.

## 新增内容流程 / Adding new content

1. 从 `templates/` 复制对应 `_cn` 和 `_en` 模板。
2. Keep machine fields stable across languages: `category`, `tags`, `risk`, `platform`, parameter names, defaults, paths, and URLs except for language suffixes.
3. Localize user-visible fields and script output/comments.
4. Ensure URLs and refs point to same-language files.
5. Run:

```bash
python3 tools/validate_library.py
```

## 安全约定 / Safety conventions

- `risk: high` 的命令通常以 `protected-` 开头。
- High-risk examples must require explicit target and confirmation variables before changing state.
- 本地化不得弱化确认、dry-run、目标限制、权限检查或保护逻辑。
- Localization must not weaken confirmations, dry runs, target restrictions, permission checks, or protected execution logic.
