---
name: new-output-style
description: >
  创建新的 Claude Code Output Style。
  Use when user says "create output style", "new output style", "add output style",
  "创建输出风格", "新建输出风格", "添加输出风格", "output style 编写",
  or when user needs to create a .claude/output-styles/*.md file.
argument-hint: <style-name>
allowed-tools: Read, Write
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, output-style, creation]
---

# Skill: 创建新 Output Style

## Purpose

引导用户创建符合规范的 Claude Code Output Style 文件。
确保产出物遵循 output-style-writing.md 规范和 OUTPUT-STYLE.md.template 模板。

## Trigger Conditions

- 用户说"创建输出风格"、"新建输出风格"、"添加输出风格"
- 用户需要创建 .claude/output-styles/*.md 文件
- 用户说"output style 编写"

## Inputs

- `$ARGUMENTS`: 输出风格名称（kebab-case）
  - 示例: `skill-author`, `agent-author`, `command-author`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/OUTPUT-STYLE.md.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/output-style-writing.md` 获取编写规范
3. 使用 `Write` 创建 `.claude/output-styles/<name>.md` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含完整的 YAML frontmatter
   - 包含 Tone、Format、Content Rules 三个核心 section
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/OUTPUT-STYLE.md.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/output-style-writing.md` 规范
- ALWAYS 使用 kebab-case 命名输出风格
- ALWAYS 提供清晰的 description（≤100 字符）
- NEVER 跳过 YAML frontmatter
- NEVER 创建不完整的输出风格
- NEVER 忽略 Tone、Format、Content Rules 三个核心 section

## Output Format

### 创建摘要

```text
✅ Output Style 已创建: .claude/output-styles/<name>.md

名称: [style-name]
描述: [description]

下一步:
1. 编辑 .claude/output-styles/<name>.md 定义输出风格
2. 在 SKILL.md frontmatter 中引用: "output-style: <name>"
```

## Examples

### ✅ Do This

```text
User: /new-output-style skill-author

Claude:
1. 读取模板和规范
2. 创建 .claude/output-styles/skill-author.md
3. 输出: "✅ Output Style 已创建: .claude/output-styles/skill-author.md"
```

### ❌ Not This

```text
User: /new-output-style skill-author

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过 YAML frontmatter
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少 frontmatter 导致不可发现 -->
