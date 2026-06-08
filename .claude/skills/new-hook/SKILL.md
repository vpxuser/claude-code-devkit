---
name: new-hook
description: >
  创建新的 Claude Code Hook。
  Use when user says "create hook", "new hook", "add hook",
  "创建钩子", "新建钩子", "添加钩子", "hook 编写",
  or when user needs to create a .claude/hooks/*.sh or *.js file.
argument-hint: <hook-name>
allowed-tools: Read, Write, Bash(mkdir:*, chmod:*)
disable-model-invocation: false
context: default
version: 1.0.0
tags: [devkit, hook, creation]
---

# Skill: 创建新 Hook

## Purpose

引导用户创建符合规范的 Claude Code Hook 文件。
确保产出物遵循 hook-writing.md 规范和 HOOK.sh.template 模板。

## Trigger Conditions

- 用户说"创建钩子"、"新建钩子"、"添加钩子"
- 用户需要创建 .claude/hooks/*.sh 或 *.js 文件
- 用户说"hook 编写"

## Inputs

- `$ARGUMENTS`: 钩子名称（kebab-case）
  - 示例: `block-dangerous-commands`, `validate-file-changes`
  - 未提供时提示用户输入

## Workflow

1. 使用 `Read` 读取 `templates/HOOK.sh.template` 获取模板结构
2. 使用 `Read` 读取 `.claude/rules/hook-writing.md` 获取编写规范
3. 使用 `Write` 创建 `.claude/hooks/<name>.sh` 文件
   - 基于模板结构
   - 遵循编写规范
   - 包含完整的日志和决策函数
   - 包含示例逻辑
4. 使用 `Bash` 设置执行权限: `chmod +x .claude/hooks/<name>.sh`
5. 输出创建摘要

## Constraints

- ALWAYS 使用 `templates/HOOK.sh.template` 作为结构基准
- ALWAYS 遵循 `.claude/rules/hook-writing.md` 规范
- ALWAYS 使用 `set -euo pipefail` (Bash) 或 try-catch (JavaScript)
- ALWAYS 使用 stderr 输出日志
- ALWAYS 设置执行权限 (chmod +x)
- NEVER 创建超过 50 行的 hook
- NEVER 忽略错误
- NEVER 修改输入数据

## Output Format

### 创建摘要

```text
✅ Hook 已创建: .claude/hooks/<name>.sh

事件: [PreToolUse|PostToolUse|Stop|...]
匹配: [tool name|file pattern|...]

下一步:
1. 编辑 .claude/hooks/<name>.sh 实现钩子逻辑
2. 在 .claude/settings.json 中配置 hook
3. 测试 hook 触发条件
```

## Examples

### ✅ Do This

```text
User: /new-hook block-dangerous-commands

Claude:
1. 读取模板和规范
2. 创建 .claude/hooks/block-dangerous-commands.sh
3. 设置执行权限
4. 输出: "✅ Hook 已创建: .claude/hooks/block-dangerous-commands.sh"
```

### ❌ Not This

```text
User: /new-hook block-dangerous-commands

Claude:
1. 不读取模板
2. 创建不符合规范的文件
3. 不设置执行权限
```

<!-- 为什么错: 步骤 1 未读取模板导致结构不符合规范，步骤 2 创建的文件不可维护，步骤 3 缺少执行权限导致 hook 无法运行 -->
