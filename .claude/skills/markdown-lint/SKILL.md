---
name: markdown-lint
description: >
  Run markdownlint on skills files and fix violations.
  Use when: user mentions "lint", "markdownlint", "格式检查",
  "check format", "fix markdown", or after editing any .md file.
allowed-tools: Bash(npx:*), Read, Edit
disable-model-invocation: false
context: default
tags: [meta, quality, formatting]
version: 1.0.0
---

# Skill: Markdown Lint Checker

## Purpose

对本项目中所有 Markdown 文件运行 markdownlint 检查，报告违规项，并可自动修复。

## Trigger Conditions

- 用户说"lint"、"check format"、"格式检查"、"markdownlint"
- 用户完成 SKILL.md 的编辑后要求验证

## Inputs

- `$ARGUMENTS` (可选): 指定文件路径或 glob 模式，默认检查所有 `skills/**/*.md`

## Workflow

1. 确定检查范围：若 `$ARGUMENTS` 非空则用 `$ARGUMENTS`，否则用 `"skills/**/*.md" "templates/**/*.md" "CLAUDE.md" ".claude/rules/*.md"`
2. 运行检查：`npx markdownlint <files> 2>&1`
3. 解析输出：
   - 退出码 0 = 全部通过 → 报告成功
   - 退出码 1 = 有违规 → 列出每个违规的文件、行号、规则编号和描述
4. 若用户要求修复，运行：`npx markdownlint --fix <files> 2>&1`，然后重复步骤 2 验证

## Constraints

- ALWAYS 在修复前先展示违规列表，让用户确认
- ALWAYS 自动检测 `.markdownlint.json`（无需 `--config` 参数）
- NEVER 对 node_modules 目录运行 lint
- NEVER 在无违规时执行 `--fix`

## Output Format

### 全部通过时

```markdown
## Markdown Lint: ✅ All Clear

Checked [N] files — [M] violations found: 0
```

### 有违规时

```markdown
## Markdown Lint: ❌ [M] Violations

| File | Line | Rule | Description |
|------|------|------|-------------|
| skills/foo/SKILL.md | 14 | MD022 | Headings should be surrounded by blank lines |
| skills/foo/SKILL.md | 15 | MD032 | Lists should be surrounded by blank lines |

### Fix

Run again with "fix" to auto-correct.
```

## Quality Checklist

- [ ] 检查范围是否正确（未包含 node_modules）？
- [ ] 违规输出是否包含文件路径、行号、规则编号？
- [ ] 修复后是否重新运行验证了？

## Edge Cases

- 当未找到匹配文件时：提示 "No .md files found matching pattern"
- 当 markdownlint 未安装时：提示 "Run: npm install" （通常不存在，因为 package.json 已包含）
- 当 `package.json` 中的 lint:md 脚本与参数冲突时：使用直接 npx 调用而非 npm run
