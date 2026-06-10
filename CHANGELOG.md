# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.3.0] - 2026-06-09

### Added

- `templates/.mcp.json.template`：MCP 配置文件模板
- `.claude/rules/mcp-writing.md`：MCP 配置编写规范（14 条规则）
  - 命名规范：kebab-case，≤30 字符
  - 结构规范：必选/可选字段定义
  - 配置模式：npx/本地/环境变量/工作目录
  - 安全规范：禁止硬编码密钥
- `scripts/check-limits.sh`：新增 MCP 配置文件检查
  - JSON 语法检查
  - 行数限制检查（≤100 行）

### Changed

- README 更新：
  - Supported File Types 新增 .mcp.json 行
  - Project Structure 新增 mcp-writing.md 和 .mcp.json.template
  - 规则数量从 13 更新为 14

## [1.2.0] - 2026-06-09

### Added

- `scripts/` 目录：质量检查脚本
  - `check-limits.sh`：行数限制检查（覆盖所有 devkit 产出物）
  - `pre-commit.sh`：Git pre-commit hook（markdownlint + 行数检查）
- `templates/package.json.template`：项目配置模板（npm scripts）
- `templates/.markdownlint.json.template`：Markdownlint 配置模板
- CLAUDE.md 新增 ALWAYS 约束：
  - 修改 .md 文件后运行 `npx markdownlint <file>`
  - 完成任务前运行 `npm run check:all`
  - 提交前运行 `npm run check:all`
- 产出检查清单扩展：覆盖所有 .md 文件类型

### Changed

- `markdown-lint` skill 检查范围扩展：从 `skills/**/*.md` 扩展到所有 `.md` 文件
- README 更新：
  - Project Structure 新增 scripts/ 目录
  - Quick Start 新增质量检查设置步骤
  - Supported File Types 新增 Scripts 列
  - Commands 新增 Quality 检查命令

## [1.1.0] - 2026-06-09

### Added

- P7 原则：Prefer Existing Tools（优先包装成熟工具，不重写核心功能）
- 决策树新增 Step 1：检查是否有现成工具可复用
- 反模式表新增：重写已有成熟工具、跳过工具选型
- README 两种使用方式：直接使用、集成到已有项目
- README 完整 junction/symlink 安装教程（Windows + macOS/Linux）
- devkit skills 和 references 的 junction 映射说明
- GitHub 社区文件：Issue 模板、PR 模板、CONTRIBUTING.md
- CHANGELOG.md

### Changed

- README 美化：新增 Why、Contributing、License footer
- README badges：stars、forks、issues、last commit
- Design Principles 表格增加编号列

## [1.0.0] - 2026-06-08

### Added

- 初始发布
- 9 种文件类型的四层约束体系
- 13 条 rules
- 9 个 reviewer agents
- 10 个 creator skills
- 10 个 review commands
- 6 个 output styles
- 10 个文件模板
- 设计哲学文档（references/philosophy.md）
