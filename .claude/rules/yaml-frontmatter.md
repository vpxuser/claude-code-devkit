---
paths:
  - "skills/**/SKILL.md"
  - "templates/**/SKILL.md*"
  - ".claude/agents/*.md"
  - ".claude/output-styles/*.md"
  - ".claude/commands/*.md"
description: "YAML frontmatter 字段规范 — 对所有带 frontmatter 的 .md 配置文件生效"
---

# YAML Frontmatter 规范

## 通用规则

- 文件必须以 `---` 开头，以 `---` 闭合
- 闭合 `---` 后必须空一行
- 字段使用 2 空格缩进
- 字符串值超出 80 字符时使用 `>` 折行语法
- 列表值使用 `[item, item]` 行内格式（不超过 3 项）

## SKILL.md 必选字段

| 字段 | 格式 | 示例 |
| --- | --- | --- |
| `name` | kebab-case，与目录名一致 | `security-review` |
| `description` | `>` 折行，第二段起列出触发短语 | `"Reviews code for... Use when…"` |

## SKILL.md 可选字段

| 字段                          | 格式                        | 默认值    |
|-------------------------------|-----------------------------|-----------|
| `allowed-tools`               | 逗号分隔，可含范围限制      | 全部工具  |
| `disable-model-invocation`    | `true` / `false`            | `false`   |
| `user-invocable`              | `true` / `false`            | `true`    |
| `context`                     | `default` / `fork`          | `default` |
| `model`                       | `sonnet` / `opus` / `haiku` | 继承      |
| `version`                     | semver                      | —         |
| `tags`                        | `[tag1, tag2]`              | —         |
| `argument-hint`               | `[arg1] [arg2]`             | —         |

## Agents frontmatter 必选字段

| 字段            | 格式        | 示例                                           |
|-----------------|-------------|------------------------------------------------|
| `name`          | kebab-case  | `code-reviewer`                                |
| `description`   | 一句话      | `"Reviews code for correctness and security"`  |
| `tools`         | 逗号分隔    | `Read, Grep, Glob`                             |

## 字段顺序（固定）

所有 frontmatter 文件必须按此顺序排列字段：

name → description → argument-hint → allowed-tools → tools → disallowedTools →
disable-model-invocation → user-invocable → context → model → effort →
maxTurns → memory → isolation → skills → version → tags
