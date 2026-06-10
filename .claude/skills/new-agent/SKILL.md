---
name: new-agent
description: >
  Create a new Claude Code agent definition from the project template.
  Use when: user mentions "create agent", "new agent", "add agent",
  "新建 agent", "agent definition", or when setting up a new agent file.
argument-hint: <agent-name>
allowed-tools: Read, Write, Bash(mkdir:*, cp:*)
disable-model-invocation: false
context: default
tags: [meta, scaffolding]
version: 1.0.0
---

# Skill: New Agent Scaffolder

## Purpose

从项目模板 `templates/AGENT.md.template` 快速搭建符合最佳实践的 Agent 定义文件。

## Trigger Conditions

- 用户说"创建 agent"、"新建 agent"、"add agent"
- 用户描述一个需要独立子代理完成的任务

## Inputs

- `$ARGUMENTS`: Agent 名称（kebab-case），如 `code-reviewer`、`security-auditor`

如果未提供名称，先询问 "What's the agent name (kebab-case)?" 再继续。

## Workflow

1. 验证名称是 kebab-case：`echo "$ARGUMENTS" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'`
2. 检查是否已存在：`ls ".claude/agents/$ARGUMENTS.md" 2>/dev/null` — 若存在则报错退出
3. 复制模板：`cp "templates/AGENT.md.template" ".claude/agents/$ARGUMENTS.md"`
4. 替换 `agent-name` 为 `$ARGUMENTS`（name 字段和标题）
5. 运行 `npx markdownlint ".claude/agents/$ARGUMENTS.md"` 验证格式
6. 输出成功摘要

## Constraints

- ALWAYS 保持模板的完整 section 结构
- ALWAYS 将 agent 放在 `.claude/agents/` 而非其他位置
- ALWAYS 运行 markdownlint 验证后再宣布完成
- NEVER 跳过名称验证步骤
- NEVER 覆盖已有 agent — 改为报错提示用户

## Output Format

```markdown
## Agent Created: `$ARGUMENTS`

### File
- `.claude/agents/$ARGUMENTS.md`

### Next Steps
1. 填写 agent 的 Expertise 和 Review Protocol
2. 根据任务类型选择 tools 和 model（参考 `.claude/rules/agent-writing.md`）
3. 运行 `npx markdownlint .claude/agents/$ARGUMENTS.md` 验证格式
4. 用 `/review-agent .claude/agents/$ARGUMENTS.md` 做内容审查
```

## Examples

### ✅ Do This

```markdown
User: /new-agent security-auditor
Claude: [creates .claude/agents/security-auditor.md from template, validates]
```

### ❌ Not This

```markdown
User: /new-agent SecurityAuditor
Claude: [creates with CamelCase — agents 也必须用 kebab-case]
```

<!-- 为什么错: Agent 名称也需要 kebab-case，与文件名一致 -->

## Quality Checklist

- [ ] Agent 名称是否通过了 kebab-case 验证？
- [ ] 文件是否创建在 `.claude/agents/` 下？
- [ ] 是否通过了 markdownlint？
- [ ] tools 字段是否根据任务类型正确选择？
- [ ] 只读 agent 是否声明了 NEVER modify files？

## Edge Cases

- 当名称包含非法字符时，拒绝并给出 kebab-case 示例
- 当文件已存在时，报错："Agent already exists: .claude/agents/<name>.md"
- 当模板文件缺失时，报错："Template not found: templates/AGENT.md.template"
