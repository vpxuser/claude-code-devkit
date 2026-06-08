---
paths:
  - "skills/**/*.md"
  - "templates/**/*.md"
  - "**/SKILL.md"
  - "**/CLAUDE.md"
description: "Markdown 输出格式规则 — 对 skills/ 和 templates/ 下所有 .md 文件生效"
---

# Markdown 输出规范

> 本规则的优先级：与 CLAUDE.md 冲突时，以本规则为准（路径级规则 > 全局规则）。

## YAML Frontmatter 规范

- 必须以 `---` 开头和结尾
- `name`: kebab-case，与目录名一致
- `description`: 包含 `>` 折行符号，第二段开始列出触发短语
- 可选字段: `allowed-tools`, `disable-model-invocation`, `context`, `model`, `version`, `tags`
- 字段顺序固定: name → description → allowed-tools → disable-model-invocation → context → model → version → tags

## Heading 层次结构

- 全局唯一 `# H1` — SKILL.md 的文件标题
- `## H2` — 顶级 section（Purpose, Workflow, Constraints 等）
- `### H3` — 子 section（如 Examples 下的 ✅ Do This / ❌ Not This）
- `#### H4` — 仅在必要时使用（极少数深层嵌套）
- 严格顺序：禁止 H1→H3 跳跃，禁止 H2→H4 跳跃

## Section 必选 & 顺序

每个 SKILL.md 必须包含且按此顺序排列：

1. `## Purpose`
2. `## Trigger Conditions`
3. `## Inputs`
4. `## Workflow`
5. `## Constraints`
6. `## Output Format`
7. `## Examples`
8. `## Quality Checklist`
9. `## Edge Cases`（可选，有则放在最后）

## 代码块规则

- 每个代码块必须指定语言: `markdown`, `bash`, `yaml`, `json`, `text`
- 禁止裸 \`\`\` 无语言标签
- YAML/JSON 代码块中的缩进必须一致
- 在代码块前后各空一行

## 空白与对齐

- Section 标题前空一行（文件开头的 H1 除外）
- Section 标题后空一行
- 列表项缩进 2 空格
- 禁止行尾空白（trailing spaces）
- 文件以单个空行结尾

## 链接与引用

- 外部链接: `[显示文字](URL)` — inline 或 reference-style 均可
- 内部文件引用: `` `relative/path.md` `` 用反引号包裹
- 禁止裸 URL

## ALWAYS / NEVER 指令风格

- Constraints section 中每条指令必须以 `- ALWAYS` 或 `- NEVER` 开头
- NEVER 指令必须给出替代方案: `— 改为 [正确做法]`
- ALWAYS 指令后直接跟动作，不额外解释

## 示例风格

- ✅ Do This 示例: 展示正确完整输出
- ❌ Not This 示例: 展示错误输出，后跟 `<!-- 为什么错: [原因] -->` 注释
