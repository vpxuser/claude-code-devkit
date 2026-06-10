<div align="center">

# 🛠️ claude-code-devkit

**The missing style guide for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/vpxuser/claude-code-devkit?style=social)](https://github.com/vpxuser/claude-code-devkit/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/vpxuser/claude-code-devkit?style=social)](https://github.com/vpxuser/claude-code-devkit/network/members)
[![GitHub issues](https://img.shields.io/github/issues/vpxuser/claude-code-devkit)](https://github.com/vpxuser/claude-code-devkit/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/vpxuser/claude-code-devkit)](https://github.com/vpxuser/claude-code-devkit/commits/main)
[![Claude Code](https://img.shields.io/badge/Claude-Code-orange.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![File Types](https://img.shields.io/badge/File_Types-12-green.svg)](#supported-file-types)

*Templates · Rules · Output Styles · Reviewers · Scaffolding*

</div>

---

> ⭐ **If you find this useful, give it a star!** It helps others discover the project.

---

## Why

Claude Code 是强大的 AI 编程助手，但默认行为缺乏一致性：

- Skills 写法因人而异，质量参差不齐
- 没有统一的审查标准，错误难以发现
- 每个项目都从零开始，重复劳动

**claude-code-devkit** 提供四层约束体系，让 Claude Code 的产出物**可预测、可审查、可复用**。

## What

```
L1: 思考模式 → design-thinking.md    （设计决策过程）
L2: 行为约束 → *.md rules            （怎么写、怎么设计）
L3: 输出模板 → templates/            （结构约束）
L4: 模板校验 → reviewer agents       （AI 质量验证）
L5: 脚本校验 → scripts/*.sh          （确定性约束检查）
```

## Supported File Types

| 文件类型 | Template | Rule | Output Style | Reviewer | Creator | L5 Script |
|----------|:--------:|:----:|:------------:|:--------:|:-------:|:---------:|
| SKILL.md | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| AGENT.md | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| COMMAND.md | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| WORKFLOW.js | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| HOOK.sh | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| plugin.json | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| REFERENCE.md | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| OUTPUT-STYLE.md | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| CLAUDE.md | ✅ | ✅ | ✅ | ✅ | ✅ | check-constraints |
| Rule.md | ✅ | ✅ | — | ✅ | ✅ | check-constraints |
| .mcp.json | ✅ | ✅ | — | — | — | check-constraints |
| settings.json | ✅ | ✅ | — | ✅ | — | check-constraints |
| package.json | ✅ | — | — | — | — | — |
| .markdownlint.json | ✅ | — | — | — | — | — |

## Quick Start

### 方式一：一键安装（推荐）

用安装脚本将 devkit 部署到已有项目。**纯复制，无 symlink/junction，跨平台。**

```bash
cd your-project

# 1. 克隆 devkit（或下载 release）
git clone https://github.com/vpxuser/claude-code-devkit.git /tmp/devkit

# 2. 一键部署（全部组件）
bash /tmp/devkit/scripts/install.sh deploy /tmp/devkit

# 3. 安装依赖
npm install
```

**选择性部署** — 只装需要的部分：

```bash
# 只装通用规则
bash /tmp/devkit/scripts/install.sh deploy /tmp/devkit --universal

# 只装 skills + agents
bash /tmp/devkit/scripts/install.sh deploy /tmp/devkit --skills --agents

# 预览（不实际复制）
bash /tmp/devkit/scripts/install.sh deploy /tmp/devkit --dry-run

# 强制覆盖已有文件
bash /tmp/devkit/scripts/install.sh deploy /tmp/devkit --force
```

**管理已部署的 devkit：**

```bash
# 查看已部署文件及状态
bash scripts/install.sh list

# 卸载（保留配置文件）
bash scripts/install.sh uninstall --keep-config

# 完全卸载
bash scripts/install.sh uninstall
```

**可用选项：** `--universal` `--rules` `--skills` `--agents` `--commands` `--output-styles` `--templates` `--scripts` `--configs` `--hooks` `--references` `--claudemd` `--dry-run` `--force`

### 方式二：直接使用（新项目 / devkit 贡献者）

```bash
git clone https://github.com/vpxuser/claude-code-devkit.git my-project
cd my-project

# 1. 安装依赖
npm install

# 2. 复制配置文件
cp templates/package.json.template package.json
cp templates/.markdownlint.json.template .markdownlint.json
cp templates/.mcp.json.template .mcp.json

# 3. 安装 pre-commit hook
npm run precommit:install

# 4. 直接在 .claude/skills/ 中创建项目技能，模板在 templates/ 中
```

更新：`git pull origin main`

## Commands

```bash
# Create — 脚手架
/new-skill my-skill          # 创建新 Skill
/new-agent my-agent          # 创建新 Agent
/new-command my-command      # 创建新 Command
/new-workflow my-workflow    # 创建新 Workflow
/new-hook my-hook            # 创建新 Hook
/new-plugin my-plugin        # 创建新 Plugin
/new-reference my-ref        # 创建新 Reference
/new-output-style my-style   # 创建新 Output Style
/new-claude-md my-project    # 创建新 CLAUDE.md
/new-rule my-rule            # 创建新 Rule

# Review — 质量校验
/review-skill path/to/SKILL.md
/review-agent path/to/AGENT.md
/review-command path/to/COMMAND.md
/review-workflow path/to/WORKFLOW.js
/review-hook path/to/HOOK.sh
/review-plugin path/to/plugin.json
/review-reference path/to/REFERENCE.md
/review-output-style path/to/OUTPUT-STYLE.md
/review-claude-md path/to/CLAUDE.md
/review-rule path/to/rule.md

# Quality — 质量检查
npm run lint:md              # Markdown 格式检查
npm run lint:md:fix          # 自动修复 Markdown 格式
npm run check:limits         # 行数限制检查
npm run check:placement      # 目录结构检查
npm run check:constraints    # L2 确定性约束检查（frontmatter、section 等）
npm run check:all            # 全部检查（格式 + 行数 + 目录 + 约束）
npm run test                 # 同 check:all
```

## Project Structure

```
claude-code-devkit/
├── CLAUDE.md                              # 开发规范入口
├── templates/                             # 文件模板（L3）
│   ├── SKILL.md.template
│   ├── AGENT.md.template
│   ├── COMMAND.md.template
│   ├── CLAUDE.md.template
│   ├── REFERENCE.md.template
│   ├── OUTPUT-STYLE.md.template
│   ├── WORKFLOW.js.template
│   ├── HOOK.sh.template
│   ├── plugin.template.json
│   ├── settings.json.template
│   ├── package.json.template
│   ├── .markdownlint.json.template
│   ├── .mcp.json.template
│   ├── RULE.md.template
│   └── README.md.template
├── scripts/                               # 质量检查脚本
│   ├── check-limits.sh                    # 行数限制检查
│   ├── check-placement.sh                 # 目录结构检查（PostToolUse hook）
│   ├── check-constraints.sh               # L2 确定性约束检查（frontmatter、section 等）
│   ├── install.sh                         # 一键安装脚本
│   └── pre-commit.sh                      # Git pre-commit hook
├── .claude/
│   ├── rules/                             # 行为约束（L2）
│   │   ├── design-thinking.md             # 设计思维（7 条原则）
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
│   │   ├── plugin-writing.md              # Plugin 编写
│   │   ├── mcp-writing.md                 # MCP 配置编写
│   │   ├── settings-writing.md            # Settings 编写
│   │   └── rule-writing.md                # Rule 编写
│   ├── output-styles/                     # 输出风格（6 个）
│   ├── agents/                            # Reviewer Agents（10 个）
│   ├── skills/                            # Creator Skills（11 个）
│   └── commands/                          # Review Commands（11 个）
├── references/
│   └── philosophy.md                      # 设计哲学
├── .github/
│   ├── ISSUE_TEMPLATE/                    # Issue 模板
│   └── PULL_REQUEST_TEMPLATE.md           # PR 模板
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Design Principles

| # | 原则 | 说明 |
|---|------|------|
| P1 | Generate First, Clarify Second | 先产出草稿再澄清 |
| P2 | One Job Per Skill | 一个技能只做一件事 |
| P3 | Pushy by Default | 宁可过度触发，不可漏触发 |
| P4 | Imperative Over Advisory | 祈使句，不用"应该/建议" |
| P5 | Concrete Over Abstract | 具体示例 > 抽象描述 |
| P6 | Compose, Don't Expand | 组合优于堆砌 |
| P7 | Prefer Existing Tools | 优先包装成熟工具，不重写核心功能 |

## Contributing

欢迎贡献！请阅读 [CONTRIBUTING.md](.github/CONTRIBUTING.md)。

1. Fork 本仓库
2. 创建 feature 分支：`git checkout -b feat/my-feature`
3. 提交更改：`git commit -m "feat: add my-feature"`
4. 推送：`git push origin feat/my-feature`
5. 创建 Pull Request

## Official Fallback

当本项目约束未覆盖某个场景时，优先参考 [Claude 官方文档](https://docs.anthropic.com/en/docs/claude-code)。

## License

[MIT](LICENSE) © [vpxuser](https://github.com/vpxuser)
