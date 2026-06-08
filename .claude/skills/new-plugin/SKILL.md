---
name: new-plugin
description: >
  创建新的 Claude Code Plugin。
  Use when user says "create plugin", "new plugin", "add plugin",
  "创建插件", "新建插件", "添加插件", "plugin 编写",
  or when user needs to create a .claude-plugin/plugin.json file.
argument-hint: <plugin-name>
allowed-tools: Read, Write, Bash(mkdir:*)
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, plugin, creation]
---

# Skill: 创建新 Plugin

## Purpose

引导用户创建符合规范的 Claude Code Plugin 配置文件。
确保产出物遵循 plugin-writing.md 规范和 plugin.template.json 模板。

## Trigger Conditions

- 用户说"创建插件"、"新建插件"、"添加插件"
- 用户需要创建 .claude-plugin/plugin.json 文件
- 用户说"plugin 编写"

## Inputs

- `$ARGUMENTS`: 插件名称（kebab-case）
  - 示例: `pentest-toolkit`, `code-review-assistant`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/plugin.template.json` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/plugin-writing.md` 获取编写规范
3. 使用 `Write` 创建 `.claude-plugin/plugin.json` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含必选字段
   - 包含示例 skills/agents/hooks
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/plugin.template.json` 作为结构基准
- ALWAYS 遵循 `.claude/rules/plugin-writing.md` 规范
- ALWAYS 使用 kebab-case 命名插件
- ALWAYS 提供清晰的 description（≤100 字符）
- NEVER 跳过 name 和 description 字段
- NEVER 硬编码路径

## Output Format

### 创建摘要

```text
✅ Plugin 已创建: .claude-plugin/plugin.json

名称: [plugin-name]
版本: [version]
描述: [description]

下一步:
1. 编辑 .claude-plugin/plugin.json 添加 skills/agents/hooks
2. 创建对应的 skills/agents/hooks 文件
3. 使用 /reload-plugins 加载插件
```

## Examples

### ✅ Do This

```text
User: /new-plugin pentest-toolkit

Claude:
1. 读取模板和规范
2. 创建 .claude-plugin/plugin.json
3. 输出: "✅ Plugin 已创建: .claude-plugin/plugin.json"
```

### ❌ Not This

```text
User: /new-plugin pentest-toolkit

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过必选字段
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可发现，步骤 3 缺少必选字段导致不可用 -->
