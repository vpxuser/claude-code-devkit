---
paths:
  - ".claude/output-styles/*.md"
description: "输出风格编写规范 — 对 .claude/output-styles/ 下所有输出风格文件生效"
---

# 输出风格编写规范

> 输出风格是追加到系统提示词的自定义段落，控制 Claude 的语调、格式和交互模式。

## 结构规范

- 文件以 YAML frontmatter 开头：`name` + `description` + `keep-coding-instructions`
- 必选 section：`## Tone`、`## Format`、`## Content Rules`
- 每个 section 下用 `-` 列表项，每条简短（一行）

## Frontmatter 字段

| 字段 | 必选 | 说明 |
| --- | --- | --- |
| `name` | ✅ | kebab-case，输出风格标识 |
| `description` | ✅ | 描述何时使用此风格 |
| `keep-coding-instructions` | ✅ | `true` 保留内置编码指令，`false` 替换 |
| `force-for-plugin` | ❌ | 插件专用：插件启用时自动应用此风格 |

## 内容规范

- Tone 定义语调特征（如 "direct and minimal"、"patient and educational"）
- Format 定义输出格式规则（如 "prefer tables over prose"）
- Content Rules 定义内容层面的约束（如 "always provide examples"）
- 每条规则简短、确定性、可判断对错
- 不做 Claude 已经默认做到的事
- 不要与 CLAUDE.md 中的规则冲突
