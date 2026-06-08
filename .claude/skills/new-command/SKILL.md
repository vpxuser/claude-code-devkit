---
name: new-command
description: >
  创建新的 Claude Code Command。
  Use when user says "create command", "new command", "add command",
  "创建命令", "新建命令", "添加命令", "command 编写",
  or when user needs to create a .claude/commands/*.md file.
argument-hint: <command-name>
allowed-tools: Read, Write
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, command, creation]
---

# Skill: 创建新 Command

## Purpose

引导用户创建符合规范的 Claude Code Command 文件。
确保产出物遵循 command-writing.md 规范和 COMMAND.md.template 模板。

## Trigger Conditions

- 用户说"创建命令"、"新建命令"、"添加命令"
- 用户需要创建 .claude/commands/*.md 文件
- 用户说"command 编写"

## Inputs

- `$ARGUMENTS`: 命令名称（kebab-case）
  - 示例: `deploy`, `test`, `lint`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/COMMAND.md.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/command-writing.md` 获取编写规范
3. 使用 `Write` 创建 `.claude/commands/<name>.md` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含完整的 YAML frontmatter
   - 包含使用示例
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/COMMAND.md.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/command-writing.md` 规范
- ALWAYS 使用 kebab-case 命名命令
- ALWAYS 提供清晰的 description（≤100 字符）
- NEVER 跳过 YAML frontmatter
- NEVER 创建超过 50 行的命令文件
- NEVER 忽略使用示例

## Output Format

### 创建摘要

```text
✅ Command 已创建: .claude/commands/<name>.md

名称: [command-name]
描述: [description]

下一步:
1. 编辑 .claude/commands/<name>.md 实现命令逻辑
2. 使用 /<name> 测试命令
```

## Examples

### ✅ Do This

```text
User: /new-command deploy

Claude:
1. 读取模板和规范
2. 创建 .claude/commands/deploy.md
3. 输出: "✅ Command 已创建: .claude/commands/deploy.md"
```

### ❌ Not This

```text
User: /new-command deploy

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过 YAML frontmatter
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少 frontmatter 导致不可发现 -->
