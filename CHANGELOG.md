# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-06-10

### Added

- `scripts/` 目录：质量检查脚本
  - `check-limits.sh`：行数限制检查（覆盖所有 devkit 产出物）
  - `check-placement.sh`：目录结构检查（PostToolUse hook + 扫描模式）
  - `pre-commit.sh`：Git pre-commit hook（markdownlint + 行数 + 目录检查）
- `templates/package.json.template`：项目配置模板（npm scripts）
- `templates/.markdownlint.json.template`：Markdownlint 配置模板
- `templates/.mcp.json.template`：MCP 配置文件模板
- `.claude/rules/mcp-writing.md`：MCP 配置编写规范
  - 命名规范：kebab-case，≤30 字符
  - 结构规范：必选/可选字段定义
  - 配置模式：npx/本地/环境变量/工作目录
  - 安全规范：禁止硬编码密钥
- CLAUDE.md 新增 ALWAYS 约束：
  - 修改 .md 文件后运行 `npx markdownlint <file>`
  - 完成任务前运行 `npm run check:all`
  - 提交前运行 `npm run check:all`
  - `.mcp.json` 模板映射
- 产出检查清单扩展：覆盖所有文件类型 + MCP 配置

### Changed

- `markdown-lint` skill 检查范围扩展：从 `skills/**/*.md` 扩展到所有 `.md` 文件
- `scripts/check-limits.sh`：集成 check-placement.sh
- README 更新：
  - Project Structure 新增 scripts/ 目录
  - Quick Start 新增质量检查设置步骤
  - Supported File Types 新增 Scripts、.mcp.json 列
  - Commands 新增 Quality 检查命令
  - 规则数量从 13 更新为 14

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
