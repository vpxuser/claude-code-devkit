---
name: new-claude-md
description: >
  创建新的 Claude Code CLAUDE.md 文件。
  Use when user says "create CLAUDE.md", "new CLAUDE.md", "add CLAUDE.md",
  "创建 CLAUDE.md", "新建 CLAUDE.md", "添加 CLAUDE.md", "CLAUDE.md 编写",
  or when user needs to create a CLAUDE.md or CLAUDE.local.md file.
argument-hint: <project-name>
allowed-tools: Read, Write
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, claude-md, creation]
---

# Skill: 创建新 CLAUDE.md

## Purpose

引导用户创建符合规范的 Claude Code CLAUDE.md 文件。
确保产出物遵循 claude-md-writing.md 规范和 CLAUDE.md.template 模板。

## Trigger Conditions

- 用户说"创建 CLAUDE.md"、"新建 CLAUDE.md"、"添加 CLAUDE.md"
- 用户需要创建 CLAUDE.md 或 CLAUDE.local.md 文件
- 用户说"CLAUDE.md 编写"

## Inputs

- `$ARGUMENTS`: 项目名称（kebab-case）
  - 示例: `my-project`, `pentest-skills`, `web-app`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/CLAUDE.md.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/claude-md-writing.md` 获取编写规范
3. 使用 `Write` 创建 `CLAUDE.md` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含项目信息
   - 包含开发规范
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/CLAUDE.md.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/claude-md-writing.md` 规范
- ALWAYS 提供清晰的项目描述
- ALWAYS 包含开发规范
- NEVER 跳过项目信息
- NEVER 创建超过 150 行的 CLAUDE.md
- NEVER 内嵌大段参考内容 — 改为用文件路径指向

## Output Format

### 创建摘要

```text
✅ CLAUDE.md 已创建

项目: [project-name]
描述: [description]

下一步:
1. 编辑 CLAUDE.md 添加项目特定规范
2. 使用 /init 自动发现项目信息
3. 考虑创建 CLAUDE.local.md 存放个人偏好
```

## Examples

### ✅ Do This

```text
User: /new-claude-md my-project

Claude:
1. 读取模板和规范
2. 创建 CLAUDE.md
3. 输出: "✅ CLAUDE.md 已创建"
```

### ❌ Not This

```text
User: /new-claude-md my-project

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过项目信息
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少项目信息导致不可用 -->
