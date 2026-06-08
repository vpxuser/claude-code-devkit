---
name: new-workflow
description: >
  创建新的 Claude Code Workflow。
  Use when user says "create workflow", "new workflow", "add workflow",
  "创建工作流", "新建工作流", "添加工作流", "workflow 编写",
  or when user needs to create a .claude/workflows/*.js file.
argument-hint: <workflow-name>
allowed-tools: Read, Write, Bash(mkdir:*)
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, workflow, creation]
---

# Skill: 创建新 Workflow

## Purpose

引导用户创建符合规范的 Claude Code Workflow 文件。
确保产出物遵循 workflow-writing.md 规范和 WORKFLOW.js.template 模板。

## Trigger Conditions

- 用户说"创建工作流"、"新建工作流"、"添加工作流"
- 用户需要创建 .claude/workflows/*.js 文件
- 用户说"workflow 编写"

## Inputs

- `$ARGUMENTS`: 工作流名称（kebab-case）
  - 示例: `pentest-full-scan`, `code-review-pipeline`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/WORKFLOW.js.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/workflow-writing.md` 获取编写规范
3. 使用 `Write` 创建 `.claude/workflows/<name>.js` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含完整的 JSDoc 注释
   - 包含阶段划分
4. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/WORKFLOW.js.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/workflow-writing.md` 规范
- ALWAYS 为每个阶段添加 JSDoc 注释
- ALWAYS 使用 `args` 全局变量（由运行时注入）
- NEVER 创建超过 7 个阶段的 workflow
- NEVER 跳过错误处理
- NEVER 硬编码配置

## Output Format

### 创建摘要

```text
✅ Workflow 已创建: .claude/workflows/<name>.js

结构:
- Phase 1: [名称]
- Phase 2: [名称]
- Phase 3: [名称]

下一步:
1. 编辑 .claude/workflows/<name>.js 实现各阶段逻辑
2. 使用 /<name> 测试工作流
```

## Examples

### ✅ Do This

```text
User: /new-workflow pentest-full-scan

Claude:
1. 读取模板和规范
2. 创建 .claude/workflows/pentest-full-scan.js
3. 输出: "✅ Workflow 已创建: .claude/workflows/pentest-full-scan.js"
```

### ❌ Not This

```text
User: /new-workflow pentest-full-scan

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 跳过阶段划分
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少阶段划分导致不可扩展 -->
