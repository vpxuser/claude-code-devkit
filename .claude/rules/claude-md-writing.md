---
paths:
  - "**/CLAUDE.md"
  - "**/CLAUDE.local.md"
description: "CLAUDE.md 编写规范 — 对所有 CLAUDE.md 和 CLAUDE.local.md 文件生效"
---

# CLAUDE.md 编写规范

> CLAUDE.md 是每次会话加载的项目指令文件。它竞争 Claude 有限的注意力预算——每个字都有成本。

## 长度控制

- 硬上限：150 行
- 推荐：60-80 行
- 超过 100 行的内容应拆分到 `.claude/rules/` 并设置 `paths` 条件加载

## 必选 Section

按此顺序排列：

1. `# PROJECT: [name]` — H1 标题，包含项目名
2. Stack + Purpose — 紧跟 H1，2 行以内
3. `## ALWAYS — 硬性规则` — 确定性指令，每条以 ALWAYS 开头
4. `## NEVER — 禁止事项` — 禁止项 + 替代方案
5. `## 格式规范` — Markdown/代码风格
6. `## 产出检查清单` — 编号列表，静默自检项
7. `## 关键参考文件` — 指向模板和规则，不内嵌内容

## 指令风格

- 每条指令以 ALWAYS 或 NEVER 开头
- NEVER 后必须跟随 `— 改为 [替代方案]`
- 不用 "consider"、"might"、"should"、"建议"
- 不用 `@` 引用文件（会内嵌整个文件）——用路径文字指向

## 格式规范

- 行宽 120 字符
- 列表缩进 2 空格
- 代码块必须指定语言标签
- Section 标题前后各空一行
- 文件以单个空行结尾

## 禁止事项

- NEVER 内嵌大段参考内容 — 用文件路径指向代替
- NEVER 超过 150 行 — 拆分到 `.claude/rules/`
- NEVER 使用模糊词汇（"考虑"、"建议"、"可能"、"应该"）
- NEVER 在 CLAUDE.md 中重复已在 rules/ 中定义的内容
