# PROJECT: claude-code-devkit

Stack: Markdown (90%+), YAML frontmatter.
Purpose: Claude Code 开发规范 — 模板、规则、输出风格、设计哲学。覆盖所有文件类型（Skills、Agents、Commands、Workflows、Hooks、Plugins、References、Output Styles、CLAUDE.md）。

## 官方规范 Fallback

- ALWAYS 当本项目约束未覆盖某个场景时，优先参考 Claude 官方文档: https://docs.anthropic.com/en/docs/claude-code
- NEVER 以"devkit 没有规定"为由跳过最佳实践 — 改为查阅官方文档后执行

## 设计思维 — 动手前必读

> 设计哲学: `references/philosophy.md` | 决策树/复杂度预算: `.claude/rules/design-thinking.md` | 渐进式披露/Token经济学: `.claude/rules/progressive-disclosure.md`

接到任何设计需求时，按以下思维链执行：

1. **Generate first, clarify second** — 先产出草稿再澄清，不确定处用 `<!-- ASSUMPTION: -->` 标记
2. **One job per skill** — 一个技能只做一件事；发现 "and also..." 立刻拆分
3. **Pushy by default** — description 宁可过度触发，不可漏触发；覆盖三种触发模式
4. **Imperative over advisory** — 找不到"应该/建议/考虑/可以"；每条 NEVER 配替代方案
5. **Concrete over abstract** — 一个具体 ✅/❌ 示例 > 三段抽象描述
6. **Compose, don't expand** — 复杂需求先想组合，不堆砌单体

### 选择正确的载体

| 需求特征 | 载体 | 位置 |
| --- | --- | --- |
| 可复用工作流，需捆绑支持文件 | **Skill** | `.claude/skills/<name>/SKILL.md` |
| 手动触发，简单操作，≤50 行 | **Command** | `.claude/commands/<name>.md` |
| 只读审查/分析，独立上下文 | **Agent** | `.claude/agents/<name>.md` |
| 多 Agent 编排，动态流程 | **Workflow** | `.claude/workflows/<name>.js` |
| 按需加载的长文档 | **Reference** | `references/<name>.md` |

### 复杂度预算（超过即拆分）

| Skill ≤ 500 行 | CLAUDE.md ≤ 150 行 | Workflow ≤ 12 步骤 | Agent ≤ 6 tools |

### 渐进式披露：信息放哪层

| 信息类型 | 放哪层 | 为什么 |
| --- | --- | --- |
| 触发条件 | L1: frontmatter description | Claude 扫描决定是否加载 |
| 核心指令 | L2: SKILL.md body (≤500行) | 触发必加载，必须精悍 |
| 详细规格/边界手册 | L3: references/*.md | 按需 Read，不浪费 session token |

### 反模式速查

- ❌ 巨型单体 → ✅ 拆分为多个小技能组合
- ❌ 模糊 description → ✅ 5+ 个具体触发短语
- ❌ "以及更多..." → ✅ 明确 scope 边界
- ❌ 无错误路径 → ✅ 每个步骤覆盖三种失败（空/超大/权限）
- ❌ 建议句式 → ✅ 祈使句 + 具体工具名

## ALWAYS — 硬性规则

- ALWAYS 新建文件时使用对应的 `templates/*.template` 作为结构基准：
  - SKILL.md → `templates/SKILL.md.template`
  - Agent.md → `templates/AGENT.md.template`
  - CLAUDE.md → `templates/CLAUDE.md.template`
  - Reference.md → `templates/REFERENCE.md.template`
  - Command.md → `templates/COMMAND.md.template`
  - Output Style.md → `templates/OUTPUT-STYLE.md.template`
  - README.md → `templates/README.md.template`
- ALWAYS 将文件放在正确的目录：
  - Skills → `skills/` 或 `.claude/skills/`
  - Agents → `.claude/agents/`
  - Commands → `.claude/commands/`
  - Output Styles → `.claude/output-styles/`
  - References → `references/` 或 `skills/<name>/references/`
- ALWAYS 将 SKILL.md 控制在 500 行以内；长参考内容拆分到 `references/` 子目录
- ALWAYS CLAUDE.md 控制在 150 行以内；超限内容拆分到 `.claude/rules/`
- ALWAYS 在 YAML frontmatter 中填写 `name` 和 `description`（description 要"侵略性"——列出触发短语）
- ALWAYS 使用**祈使句**写指令（"执行 X"而非"你应该执行 X"）
- ALWAYS 为代码块指定语言标签（`markdown`、`bash`、`json`、`yaml`）
- ALWAYS 在 section 标题前后留一个空行
- ALWAYS 每个文件只包含一个 `# H1` 标题
- ALWAYS 给出"✅ 正确示例"和"❌ 错误示例"对比
- ALWAYS 修改 .md 文件后运行 `npx markdownlint <file>` 确保格式通过
- ALWAYS 完成任务前运行 `npm run check:all` 确保所有文件符合行数限制
- ALWAYS 提交前运行 `npm run check:all` 确保格式和行数限制通过

## NEVER — 禁止事项

- NEVER 产出"考虑做 X"或"建议做 X"的模糊指令 — 写成确定性指令或不做
- NEVER 跳过 YAML frontmatter — 每个 .md 产出必须以 `---` 开头
- NEVER 在 Heading 层级间跳跃（H1→H2→H3，不能 H1→H3）
- NEVER 在 CLAUDE.md 中内嵌大段参考内容 — 用文件路径指向代替
- NEVER 产出没有 `language` 标签的代码块
- NEVER 使用 tab 缩进 — 全部 2-space

## Markdown 格式规范

- 行宽上限 120 字符（代码块例外）
- 列表项以 `-` 开头，缩进 2 空格
- 强调用 `**bold**` 或 `*italic*`，不用 `__underline__`
- 链接使用 reference-style 或 inline，不裸写 URL
- 表格必须对齐，首尾加 `|`

## 产出检查清单

每产出或修改文件，按文件类型自检：

1. 是否使用了对应的 `templates/*.template` 作为结构基准？
2. 文件是否放在了正确的目录下？
3. frontmatter（如适用）包含 name / description，字段按 `.claude/rules/yaml-frontmatter.md` 顺序排列？
4. 必选 section 是否完整（以对应模板为准）？
5. 是否有 Constraints section，且每条是 ALWAYS/NEVER 指令？
6. 代码块都有语言标签？
7. 行宽是否 > 120? 若是，折行
8. 总行数是否超限？Skill/Agent ≤ 500，CLAUDE.md ≤ 150

## 模板→规则 覆盖矩阵

| 文件类型 | 模板 | 路径规则 (auto-triggered) |
| --- | --- | --- |
| SKILL.md | `templates/SKILL.md.template` | `skill-writing.md` |
| Agent.md | `templates/AGENT.md.template` | `agent-writing.md` |
| CLAUDE.md | `templates/CLAUDE.md.template` | `claude-md-writing.md` |
| Reference.md | `templates/REFERENCE.md.template` | `reference-writing.md` |
| Command.md | `templates/COMMAND.md.template` | `command-writing.md` |
| Output Style.md | `templates/OUTPUT-STYLE.md.template` | `output-style-writing.md` |
| Workflow.js | `templates/WORKFLOW.js.template` | `workflow-writing.md` |
| Hook.sh | `templates/HOOK.sh.template` | `hook-writing.md` |
| plugin.json | `templates/plugin.template.json` | `plugin-writing.md` |
| README.md | `templates/README.md.template` | `markdown-output.md` |
| ALL .md | — | `markdown-output.md` + `yaml-frontmatter.md` |
