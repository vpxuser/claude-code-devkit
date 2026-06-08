---
paths:
  - "references/**/*.md"
  - "skills/*/references/**/*.md"
  - ".claude/skills/*/references/**/*.md"
description: "参考文档编写规范 — 对 references/ 下所有 .md 文件生效"
---

# 参考文档编写规范

> 参考文档按需加载（不随 SKILL.md 一起注入上下文），因此需要自足、可独立理解。

## 结构规范

- 文件以 `# H1` 标题开头，描述文档主题
- 必选 section：`## Purpose`、`## Scope`、`## Content`、`## Related`
- Content 按逻辑组织为 H2 section，每个 section 聚焦单一主题
- 没有 YAML frontmatter（参考文档不是独立技能）

## 内容规范

- 每个文件必须声明 Scope — 明确覆盖和不覆盖的范围
- 不覆盖的内容用路径指向替代文档（`See [other.md] for ...`）
- 示例在上下文中有意义时才提供（不填充无意义占位符）
- 链接使用相对路径（`../skills/foo/SKILL.md`，而非绝对路径）

## 格式规范

- 代码块必须指定语言标签
- 表格必须首尾带 `|`，列对齐
- 列表缩进 2 空格
- 行宽 120 字符以内

## 质量要求

- 每个文件有至少一个 "Related" 链接指向相关文档
- Content section 至少有一个 H3 小节
- 文件控制在 200 行以内（参考文档应聚焦，大文档拆分为多个文件）
