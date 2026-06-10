---
name: new-rule
description: >
  Create a new Claude Code rule file from the project template.
  Use when: user mentions "create rule", "new rule", "add rule",
  "make a rule", "新建规则", "添加规则", or when setting up a new .claude/rules/*.md file.
argument-hint: <rule-name>
allowed-tools: Read, Write, Bash(mkdir:*, cp:*)
disable-model-invocation: false
context: default
tags: [meta, scaffolding]
version: 1.0.0
---

# Skill: New Rule Scaffolder

## Purpose

从项目模板 `templates/RULE.md.template` 快速搭建符合项目规范的新规则文件。

## Trigger Conditions

- 用户说"创建规则"、"新建 rule"、"add rule"、"create rule"
- 用户描述一个文件编写规范或约束需求，尚未创建文件

## Inputs

- `$ARGUMENTS`: 规则名称（kebab-case），如 `api-design`、`testing-standards`

如果未提供名称，先询问 "What's the rule name (kebab-case)?" 再继续。

## Workflow

1. 验证规则名称是 kebab-case：`echo "$ARGUMENTS" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'`
2. 检查是否已存在同名规则：`ls ".claude/rules/$ARGUMENTS.md" 2>/dev/null` — 若存在则报错退出
3. 判断规则类型：询问用户是全局规则还是路径级规则
4. 复制模板：`cp "templates/RULE.md.template" ".claude/rules/$ARGUMENTS.md"`
5. 替换 `# [领域名称] 规范` 为实际名称
6. 如果是全局规则，删除 `paths` 字段；如果是路径级规则，提示用户填写 glob
7. 运行 `npx markdownlint ".claude/rules/$ARGUMENTS.md"` 验证格式
8. 输出成功摘要

## Constraints

- ALWAYS 保持模板的完整 section 结构不动
- ALWAYS 验证名称是 kebab-case
- ALWAYS 运行 markdownlint 验证后再宣布完成
- ALWAYS 判断全局/路径级并正确设置 frontmatter
- NEVER 跳过名称验证步骤
- NEVER 覆盖已有的规则文件 — 改为报错提示用户

## Output Format

```markdown
## Rule Created: `$ARGUMENTS`

### Files
- `.claude/rules/$ARGUMENTS.md` — 规则文件

### Rule Type
[global | path-scoped with paths: ["..."]]

### Next Steps
1. 编辑规则文件填写实际约束
2. 用 ALWAYS/NEVER 写每条约束
3. 添加 ✅/❌ 示例对比
4. 运行 `npx markdownlint .claude/rules/$ARGUMENTS.md` 验证格式
5. 用 `/review-rule .claude/rules/$ARGUMENTS.md` 做内容审查
```

## Examples

### ✅ Do This

```markdown
User: /new-rule api-design
Claude: [creates .claude/rules/api-design.md from template, asks global vs path-scoped, validates with lint]
```

### ❌ Not This

```markdown
User: /new-rule API_Design
Claude: [creates without validating kebab-case, name has underscores and uppercase]
```

<!-- 为什么错: 名称必须是 kebab-case，不能有下划线或大写字母 -->

## Quality Checklist

- [ ] 规则名称是否通过了 kebab-case 验证？
- [ ] 目标文件是否不存在（不覆盖已有规则）？
- [ ] 全局/路径级类型是否正确设置？
- [ ] .md 文件是否通过了 markdownlint？

## Edge Cases

- 当规则名包含非法字符时，拒绝并给出正确的 kebab-case 示例
- 当目标文件已存在时，报错："Rule already exists: .claude/rules/<name>.md"
- 当模板文件缺失时，报错："Template not found: templates/RULE.md.template"
