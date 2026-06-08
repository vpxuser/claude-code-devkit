# claude-code-devkit

Claude Code 开发规范工具包 — 模板、规则、输出风格、设计哲学。

## What

为 Claude Code 的所有文件类型提供**四层约束**：

```
L1: 思考模式 (design-thinking.md)
    ↓ 设计决策过程
L2: 行为约束 (xxx-writing.md)
    ↓ 怎么写、怎么设计
L3: 输出模板 (xxx.template)
    ↓ 结构约束
L4: 模板校验 (xxx-reviewer.md)
    ↓ 质量验证
```

## Supported File Types

| 文件类型 | 模板 | 规则 | 输出风格 | Reviewer |
|----------|------|------|----------|----------|
| SKILL.md | ✅ | ✅ | ✅ | ✅ |
| AGENT.md | ✅ | ✅ | ✅ | ✅ |
| COMMAND.md | ✅ | ✅ | ✅ | ✅ |
| WORKFLOW.js | ✅ | ✅ | ✅ | ✅ |
| HOOK.sh | ✅ | ✅ | ✅ | ✅ |
| plugin.json | ✅ | ✅ | ✅ | ✅ |
| REFERENCE.md | ✅ | ✅ | ✅ | ✅ |
| OUTPUT-STYLE.md | ✅ | ✅ | ✅ | ✅ |
| CLAUDE.md | ✅ | ✅ | ✅ | ✅ |

## Quick Start

### 1. Clone

```bash
git clone https://github.com/<your-username>/claude-code-devkit.git
```

### 2. Link to your project

```bash
# Option A: Symlink (recommended for local development)
ln -s /path/to/claude-code-devkit/templates /path/to/your-project/templates
ln -s /path/to/claude-code-devkit/.claude/rules /path/to/your-project/.claude/rules

# Option B: Copy (for standalone projects)
cp -r /path/to/claude-code-devkit/templates /path/to/your-project/
cp -r /path/to/claude-code-devkit/.claude /path/to/your-project/
```

### 3. Use

```bash
# Create a new skill
/new-skill my-awesome-skill

# Review a skill
/review-skill skills/my-awesome-skill/SKILL.md

# Create a new agent
/new-agent my-agent

# Review an agent
/review-agent .claude/agents/my-agent.md
```

## Project Structure

```
claude-code-devkit/
├── CLAUDE.md                          # 开发规范入口
├── templates/                         # 文件模板
│   ├── SKILL.md.template
│   ├── AGENT.md.template
│   ├── COMMAND.md.template
│   ├── CLAUDE.md.template
│   ├── REFERENCE.md.template
│   ├── OUTPUT-STYLE.md.template
│   ├── WORKFLOW.js.template
│   ├── HOOK.sh.template
│   ├── plugin.template.json
│   └── README.md.template
├── .claude/
│   ├── rules/                         # 行为约束
│   │   ├── design-thinking.md         # 设计思维（每次会话加载）
│   │   ├── progressive-disclosure.md  # 渐进式披露（每次会话加载）
│   │   ├── yaml-frontmatter.md        # YAML 规范
│   │   ├── markdown-output.md         # Markdown 规范
│   │   ├── skill-writing.md           # Skill 编写规范
│   │   ├── agent-writing.md           # Agent 编写规范
│   │   ├── command-writing.md         # Command 编写规范
│   │   ├── reference-writing.md       # Reference 编写规范
│   │   ├── output-style-writing.md    # Output Style 编写规范
│   │   ├── claude-md-writing.md       # CLAUDE.md 编写规范
│   │   ├── workflow-writing.md        # Workflow 编写规范
│   │   ├── hook-writing.md            # Hook 编写规范
│   │   └── plugin-writing.md          # Plugin 编写规范
│   ├── output-styles/                 # 输出风格
│   │   ├── skill-author.md
│   │   ├── agent-author.md
│   │   ├── command-author.md
│   │   ├── reference-author.md
│   │   ├── output-style-author.md
│   │   └── claude-md-author.md
│   ├── agents/                        # Reviewer Agents
│   │   ├── skill-reviewer.md
│   │   ├── agent-reviewer.md
│   │   ├── command-reviewer.md
│   │   ├── workflow-reviewer.md
│   │   ├── hook-reviewer.md
│   │   ├── plugin-reviewer.md
│   │   ├── reference-reviewer.md
│   │   ├── output-style-reviewer.md
│   │   └── claude-md-reviewer.md
│   ├── skills/                        # Creator Skills
│   │   ├── new-skill/
│   │   ├── new-agent/
│   │   ├── new-command/
│   │   ├── new-reference/
│   │   ├── new-output-style/
│   │   ├── new-claude-md/
│   │   ├── new-workflow/
│   │   ├── new-hook/
│   │   ├── new-plugin/
│   │   └── markdown-lint/
│   └── commands/                      # Review Commands
│       ├── review-skill.md
│       ├── review-agent.md
│       ├── review-command.md
│       ├── review-workflow.md
│       ├── review-hook.md
│       ├── review-plugin.md
│       ├── review-reference.md
│       ├── review-output-style.md
│       ├── review-claude-md.md
│       └── test-trigger.md
└── references/
    └── philosophy.md                  # 设计哲学
```

## Design Principles

1. **Generate First, Clarify Second** — 先产出草稿再澄清
2. **One Job Per Skill** — 一个技能只做一件事
3. **Pushy by Default** — 宁可过度触发，不可漏触发
4. **Imperative Over Advisory** — 祈使句，不用"应该/建议"
5. **Concrete Over Abstract** — 具体示例 > 抽象描述
6. **Compose, Don't Expand** — 组合优于堆砌

## Official Fallback

当本项目约束未覆盖某个场景时，优先参考 [Claude 官方文档](https://docs.anthropic.com/en/docs/claude-code)。

## License

MIT
