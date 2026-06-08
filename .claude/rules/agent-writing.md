---
paths:
  - ".claude/agents/*.md"
description: "Agent 定义文件编写规范 — 对 .claude/agents/ 下所有 agent 定义文件生效"
---

# Agent 编写规范

> Agent 是拥有独立系统提示词和工具权限的子代理。不同于 SKILL.md，Agent 的指令是**内部化的**——它不会展示给用户，而是直接驱动 agent 行为。

## 指令写作原则

- Agent 指令必须是**自足的**——agent 在独立上下文中运行，看不到主对话历史
- 每个步骤标注要使用的具体工具名称
- 输出格式需要精确到 agent 能**机械执行**的程度
- NEVER 指令后必须跟随替代方案

## Frontmatter 必选字段

| 字段 | 格式 | 说明 |
| --- | --- | --- |
| `name` | kebab-case，与文件名一致 | 主 agent 通过此名称 spawn |
| `description` | 一句话 | 主 agent 据此判断何时 spawn |
| `tools` | 逗号分隔 | agent 可用工具白名单 |
| `model` | `sonnet` / `opus` / `haiku` | 匹配任务复杂度 |

## Frontmatter 可选字段

| 字段 | 格式 | 默认值 | 使用场景 |
| --- | --- | --- | --- |
| `disallowedTools` | 逗号分隔 | 无 | 从继承工具中移除危险工具 |
| `maxTurns` | 整数 | 无限制 | 限制只读 agent 的轮次 |
| `memory` | `user` / `project` / `local` | 无 | 需要跨会话记忆的 agent |
| `isolation` | `worktree` | 无 | 需要修改文件的并行 agent |
| `background` | `true` / `false` | `false` | 长时间运行的后台任务 |
| `skills` | 逗号分隔 | 全部 | 限制 agent 可用的技能 |
| `effort` | `low` / `medium` / `high` | 继承 | 控制审查深度 |

## 工具选择指南

| 任务类型 | 推荐 tools | model |
| --- | --- | --- |
| 代码审查（只读） | `Read, Grep, Glob` | `sonnet` |
| 安全审计（只读） | `Read, Grep, Glob, Bash` | `opus` |
| 快速信息检索 | `Read, Grep` | `haiku` |
| 并行文件编辑 | `Read, Write, Edit` + `isolation: worktree` | `sonnet` |
| 后台批处理 | `Read, Grep, Bash` + `background: true` | `haiku` |

## 输出格式规范

- Agent 的最终输出**必须**是 Markdown 格式——这是主 agent 解析的内容
- 使用标准 section 结构（H2 分组，H3 子项）
- 每个 finding 必须包含：严重程度、文件位置、问题描述、修复方案
- 无问题时明确输出 "No findings" 而非返回空

## 约束规范

- 每个 agent 必须有至少 3 条约束指令
- 每条约束以 ALWAYS 或 NEVER 开头
- 只读 agent 必须声明 `NEVER modify files`

## 边界案例

- Agent 在工具调用失败时的行为必须在指令中覆盖
- 任务超出 maxTurns 时必须输出部分结果 + 未覆盖范围说明
- 空结果必须显式报告（"No findings"），沉默 = 主 agent 无法判断是否完成
