---
name: new-skill
description: >
  Create a new Claude Code skill from the project template.
  Use when: user mentions "create skill", "new skill", "add skill",
  "make a skill", "新建技能", or when setting up a new SKILL.md file.
argument-hint: <skill-name>
allowed-tools: Read, Write, Bash(mkdir:*, cp:*)
disable-model-invocation: false
context: default
tags: [meta, scaffolding]
version: 1.0.0
---

# Skill: New Skill Scaffolder

## Purpose

从项目模板 `templates/SKILL.md.template` 快速搭建符合 Claude 官方最佳实践的新技能目录。

## Trigger Conditions

- 用户说"创建技能"、"新建 skill"、"add skill"、"create skill"
- 用户在对话中描述一个新技能的功能，尚未创建文件

## Inputs

- `$ARGUMENTS`: 技能名称（kebab-case），如 `security-review`

如果未提供名称，先询问 "What's the skill name (kebab-case)?" 再继续。

## Workflow

1. 验证技能名称是 kebab-case：`echo "$ARGUMENTS" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'`
2. 检查是否已存在同名技能目录：`ls -d "skills/$ARGUMENTS" 2>/dev/null` — 若存在则报错退出
3. 创建技能目录：`mkdir -p "skills/$ARGUMENTS/references"`
4. 复制模板：`cp "templates/SKILL.md.template" "skills/$ARGUMENTS/SKILL.md"`
5. 替换 `name` 和 `# Skill:` 占位符为实际名称
6. 运行 `npx markdownlint "skills/$ARGUMENTS/SKILL.md"` 验证格式
7. 输出成功摘要

## Constraints

- ALWAYS 保持模板的完整 section 结构不动
- ALWAYS 创建 `references/` 子目录
- ALWAYS 运行 markdownlint 验证后再宣布完成
- NEVER 跳过名称验证步骤
- NEVER 覆盖已有的技能目录 — 改为报错提示用户

## Output Format

```markdown
## Skill Created: `$ARGUMENTS`

### Files
- `skills/$ARGUMENTS/SKILL.md` — 技能入口文件
- `skills/$ARGUMENTS/references/` — 参考文档目录

### Next Steps
1. 编辑 SKILL.md 填写实际逻辑
2. 将长参考内容拆分到 references/
3. 运行 `npx markdownlint skills/$ARGUMENTS/SKILL.md` 验证格式
4. 用 `/review-skill skills/$ARGUMENTS/SKILL.md` 做内容审查
```

## Examples

### ✅ Do This

```markdown
User: /new-skill pentest-recon
Claude: [creates skills/pentest-recon/SKILL.md from template, validates with lint]
```

### ❌ Not This

```markdown
User: /new-skill MySkill
Claude: [creates without validating kebab-case, name mismatch in frontmatter]
```

<!-- 为什么错: 名称必须是 kebab-case，且 frontmatter name 与目录名不一致 -->

## Quality Checklist

- [ ] 技能名称是否通过了 kebab-case 验证？
- [ ] 目标目录是否不存在（不覆盖已有技能）？
- [ ] SKILL.md 是否通过了 markdownlint？
- [ ] frontmatter 的 name 字段是否与目录名一致？

## Edge Cases

- 当技能名包含非法字符时，拒绝并给出正确的 kebab-case 示例
- 当目标目录已存在时，报错："Skill already exists: skills/<name>/"
- 当模板文件缺失时，报错："Template not found: templates/SKILL.md.template"
