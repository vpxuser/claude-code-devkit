---
name: new-reference
description: >
  创建新的 Claude Code Reference 文件。
  Use when user says "create reference", "new reference", "add reference",
  "创建参考文档", "新建参考文档", "添加参考文档", "reference 编写",
  or when user needs to create a references/*.md file.
argument-hint: <reference-name>
allowed-tools: Read, Write
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, reference, creation]
---

# Skill: 创建新 Reference

## Purpose

引导用户创建符合规范的 Claude Code Reference 文件。
确保产出物遵循 reference-writing.md 规范和 REFERENCE.md.template 模板。

## Trigger Conditions

- 用户说"创建参考文档"、"新建参考文档"、"添加参考文档"
- 用户需要创建 references/*.md 文件
- 用户说"reference 编写"

## Inputs

- `$ARGUMENTS`: 参考文档名称（kebab-case）
  - 示例: `api-spec`, `architecture-guide`, `troubleshooting`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/REFERENCE.md.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/reference-writing.md` 获取编写规范
3. 使用 `Write` 创建 `references/<name>.md` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含完整的 YAML frontmatter
   - 包含详细内容
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/REFERENCE.md.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/reference-writing.md` 规范
- ALWAYS 使用 kebab-case 命名参考文档
- ALWAYS 提供清晰的 description（≤100 字符）
- NEVER 跳过 YAML frontmatter
- NEVER 创建不完整的参考文档
- NEVER 忽略交叉引用

## Output Format

### 创建摘要

```text
✅ Reference 已创建: references/<name>.md

名称: [reference-name]
描述: [description]

下一步:
1. 编辑 references/<name>.md 添加详细内容
2. 在 SKILL.md 中引用: "See references/<name>.md"
```

## Examples

### ✅ Do This

```text
User: /new-reference api-spec

Claude:
1. 读取模板和规范
2. 创建 references/api-spec.md
3. 输出: "✅ Reference 已创建: references/api-spec.md"
```

### ❌ Not This

```text
User: /new-reference api-spec

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过 YAML frontmatter
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少 frontmatter 导致不可发现 -->
