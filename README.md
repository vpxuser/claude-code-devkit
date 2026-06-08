<div align="center">

# 🛠️ claude-code-devkit

**Claude Code 开发规范工具箱**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude-Code-orange.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![File Types](https://img.shields.io/badge/File_Types-9-green.svg)](#supported-file-types)

*Templates · Rules · Output Styles · Reviewers*

</div>

---

## What

为 Claude Code 的所有文件类型提供**四层约束**体系：

```
L1: 思考模式 → 设计决策过程
L2: 行为约束 → 怎么写、怎么设计
L3: 输出模板 → 结构约束
L4: 模板校验 → 质量验证
```

## Supported File Types

| 文件类型 | Template | Rule | Output Style | Reviewer | Creator |
|----------|:--------:|:----:|:------------:|:--------:|:-------:|
| SKILL.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| AGENT.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| COMMAND.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| WORKFLOW.js | ✅ | ✅ | ✅ | ✅ | ✅ |
| HOOK.sh | ✅ | ✅ | ✅ | ✅ | ✅ |
| plugin.json | ✅ | ✅ | ✅ | ✅ | ✅ |
| REFERENCE.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| OUTPUT-STYLE.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| CLAUDE.md | ✅ | ✅ | ✅ | ✅ | ✅ |

## Quick Start

### Install

```bash
git clone https://github.com/vpxuser/claude-code-devkit.git
```

### Link to your project

```bash
# Option A: Symlink (recommended)
ln -s /path/to/claude-code-devkit/templates /path/to/your-project/templates
ln -s /path/to/claude-code-devkit/.claude /path/to/your-project/.claude

# Option B: Copy
cp -r /path/to/claude-code-devkit/templates /path/to/your-project/
cp -r /path/to/claude-code-devkit/.claude /path/to/your-project/
```

### Use

```bash
# Create
/new-skill my-skill          # 创建新 Skill
/new-agent my-agent          # 创建新 Agent
/new-command my-command      # 创建新 Command
/new-workflow my-workflow    # 创建新 Workflow
/new-hook my-hook            # 创建新 Hook
/new-plugin my-plugin        # 创建新 Plugin
/new-reference my-ref        # 创建新 Reference
/new-output-style my-style   # 创建新 Output Style
/new-claude-md my-project    # 创建新 CLAUDE.md

# Review
/review-skill path/to/SKILL.md
/review-agent path/to/AGENT.md
/review-command path/to/COMMAND.md
/review-workflow path/to/WORKFLOW.js
/review-hook path/to/HOOK.sh
/review-plugin path/to/plugin.json
/review-reference path/to/REFERENCE.md
/review-output-style path/to/OUTPUT-STYLE.md
/review-claude-md path/to/CLAUDE.md
```

## Project Structure

```
claude-code-devkit/
├── CLAUDE.md                              # 开发规范入口
├── templates/                             # 文件模板
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
│   ├── rules/                             # 行为约束
│   │   ├── design-thinking.md             # 设计思维
│   │   ├── progressive-disclosure.md      # 渐进式披露
│   │   ├── yaml-frontmatter.md            # YAML 规范
│   │   ├── markdown-output.md             # Markdown 规范
│   │   ├── skill-writing.md               # Skill 编写
│   │   ├── agent-writing.md               # Agent 编写
│   │   ├── command-writing.md             # Command 编写
│   │   ├── reference-writing.md           # Reference 编写
│   │   ├── output-style-writing.md        # Output Style 编写
│   │   ├── claude-md-writing.md           # CLAUDE.md 编写
│   │   ├── workflow-writing.md            # Workflow 编写
│   │   ├── hook-writing.md                # Hook 编写
│   │   └── plugin-writing.md              # Plugin 编写
│   ├── output-styles/                     # 输出风格
│   ├── agents/                            # Reviewer Agents
│   ├── skills/                            # Creator Skills
│   └── commands/                          # Review Commands
├── references/
│   └── philosophy.md                      # 设计哲学
├── LICENSE
└── README.md
```

## Design Principles

| 原则 | 说明 |
|------|------|
| Generate First, Clarify Second | 先产出草稿再澄清 |
| One Job Per Skill | 一个技能只做一件事 |
| Pushy by Default | 宁可过度触发，不可漏触发 |
| Imperative Over Advisory | 祈使句，不用"应该/建议" |
| Concrete Over Abstract | 具体示例 > 抽象描述 |
| Compose, Don't Expand | 组合优于堆砌 |

## Official Fallback

当本项目约束未覆盖某个场景时，优先参考 [Claude 官方文档](https://docs.anthropic.com/en/docs/claude-code)。

## License

[MIT](LICENSE)
