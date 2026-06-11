---
paths:
  - ".claude/rules/*.md"
description: >
  Rule 文件编写规范 — 对 .claude/rules/ 下所有 .md 文件生效.
  覆盖设计决策、写作风格、结构约束、质量验证四层规范。
---

# Rule 编写规范

> 本规则是项目 L1-L5 约束体系的 **L2 层**，约束 `.claude/rules/` 下所有 `.md` 文件的编写方式。
> L1 思考模式见 `design-thinking.md` | L3 输出模板见 `templates/RULE.md.template` | L4 校验见 `*-reviewer.md` agents | L5 脚本校验见 `scripts/check-constraints.sh`。
>
> 官方规范来源：https://docs.anthropic.com/en/docs/claude-code/memory

## L0: 设计决策 — 要不要写、写什么类型

### 选择正确的载体

- ALWAYS 先判断需求是否已被现有 rule 覆盖 — 重复约束制造冲突
- ALWAYS 超过 100 行的文件类型特定指令从 CLAUDE.md 拆分到 `.claude/rules/`
- ALWAYS 超过 150 行的单条 rule 拆分为多条，用 `paths` 分别作用域
- NEVER 在 CLAUDE.md 中内嵌大段文件编写规范 — 改为 rule + `paths` 精确触发

### 两种规则类型

| 类型 | paths 字段 | 加载时机 | Token 成本 | 适用场景 |
| --- | --- | --- | --- | --- |
| 全局规则 | 省略 | 每会话无条件加载 | 固定成本 | 思维框架、设计哲学 |
| 路径级规则 | 填写 | 匹配文件时才加载 | 零日常成本 | 文件编写规范、格式约束 |

- ALWAYS 只有**每次会话都需要的思维框架**才设为全局规则
- ALWAYS 文件编写规范一律路径级 — 用 `paths` 精确控制加载时机
- NEVER 为全局思维框架设置 `paths` — 改为省略字段
- NEVER 为文件类型特定规则省略 `paths` — 改为填写精确 glob

### 优先级

```text
路径级规则 > 全局规则 > CLAUDE.md
```

冲突时高优先级规则生效。

## L1: 怎么写 — 语言风格与指令模式

### 指令句式

- ALWAYS 每条约束以 `ALWAYS` 或 `NEVER` 开头
- ALWAYS `NEVER` 后必须跟 `— 改为 [正确做法]`
- ALWAYS 使用祈使句："填写 `description`"，而非 "你应该填写 description"
- NEVER 使用"建议"、"考虑"、"可以"、"应该" — 改为 ALWAYS/NEVER 祈使句
- NEVER 只写禁止不给替代方案 — 每条 NEVER 必须配一个可执行的替代

### 范围定义

- ALWAYS 正文开头用 `>` blockquote 说明：约束什么、对什么生效、配合什么构成约束体系
- NEVER 写模糊的范围（如"适用于各种文件"） — 改为精确列出文件类型

### 约束排列

- ALWAYS 按优先级排列：最重要的约束排在最前
- ALWAYS 涉及字段/格式/结构时用表格列出：项目、标准、示例
- NEVER 写无法验证的抽象标准（如"写得清晰"） — 改为可检查的具体规则

## L2: 结构约束 — frontmatter、section、命名、行数

> 模板见 `templates/RULE.md.template`。以下为模板的强制约束。

### Frontmatter

- ALWAYS 以 `---` 开头、`---` 闭合，闭合后空一行
- ALWAYS 填写 `description` — 一句话说明约束什么、对什么生效
- ALWAYS `description` 使用中文，与规则正文语言一致
- ALWAYS `description` 包含触发场景（"对 X 生效"、"用户做 Y 时加载"）
- ALWAYS 路径级规则的 `paths` 至少覆盖一个文件类型
- ALWAYS glob 精确到文件类型（如 `*.md`），避免过于宽泛的 `**/*`

### Section 结构

- ALWAYS 正文以 `# H1` 标题开头，每个文件只有一个 H1
- ALWAYS H1 后紧跟 `>` blockquote 说明范围（见 L1 范围定义）
- ALWAYS 约束内容按维度分 section（H2），每个 section 聚焦一个主题
- ALWAYS section 按重要性降序排列 — 最核心的约束排最前
- NEVER 在 Heading 层级间跳跃（H1→H2→H3，不能 H1→H3）

### Section 模式

从以下模式中按需组合，不强制全部使用：

| 模式 | 适用场景 | 模板 section |
| --- | --- | --- |
| 核心约束 | ALWAYS/NEVER 指令 | `## [核心原则/约束名称]` |
| 字段规范 | 涉及 frontmatter/配置字段 | `## [字段/结构规范]`（表格） |
| 行为约束 | 写作/设计行为 | `## [行为约束]` |
| 示例对比 | ✅/❌ 对比 | `## 示例` |
| 边界案例 | 工具调用/输入处理 | `## 边界案例` |

### 文件命名

- ALWAYS 使用 kebab-case
- ALWAYS 文件名描述约束内容（如 `skill-writing.md`、`api-design.md`）
- NEVER 使用通用名（如 `rules.md`、`standards.md`） — 改为具体领域名

### 行数控制

- ALWAYS 单条规则控制在 150 行以内
- 超过 150 行时拆分为多条规则，用 `paths` 分别精确作用域
- 全局规则尤其要精简 — 每会话都消耗 token

## L3: 质量验证 — 示例、边界、可测试性

### 示例规范

- ALWAYS 每条规则至少包含一组 `✅ Do This` / `❌ Not This` 对比
- ALWAYS `✅ 示例` 必须是**完整可复制**的代码块
- ALWAYS `❌ 示例` 后用 HTML 注释标注错误原因：`<!-- 为什么错: [原因] -->`
- ALWAYS 代码块指定语言标签（`markdown`、`bash`、`json`、`yaml`）
- NEVER 只给正确示例不给反例 — 对比才能让 Claude 识别边界

### 边界案例

> 仅当规则涉及**工具调用、输入处理或错误路径**时需要。纯格式规范或纯思维框架可省略。

- 涉及文件操作时覆盖：文件不存在、权限不足、文件过大
- 涉及输入时覆盖：空输入、超大输入、格式错误
- 每个边界案例给出**确定性处理方式**，不留下判断空白

### 可测试性

- ALWAYS 每条约束能被**机械验证**：grep 能搜到、lint 能检出、行数能数清
- ALWAYS 涉及字段/格式时给出可运行的验证命令
- NEVER 写只能靠"判断"验证的约束（如"写得合理"） — 改为可量化标准
