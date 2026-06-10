# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.3.0] - 2026-06-10

### Added

- `templates/settings.json.template`：Settings 文件模板
- `.claude/rules/settings-writing.md`：Settings 编写规范（L2 行为约束层）
- `.claude/agents/settings-reviewer.md`：Settings 质量校验 agent（L4 层）
- `scripts/check-constraints.sh`：L2 确定性约束检查脚本（L5 脚本校验层）
  - 检查 frontmatter 存在性、必选字段
  - 检查必选 section 存在性
  - 检查代码块语言标签
  - 检查禁用词（应该/建议/考虑/可以）
  - 检查 NEVER 规则替代方案
  - 检查 JSON 语法
  - 检查 workflow meta 结构
  - 检 hook 规范（set -euo pipefail、jq、hookSpecificOutput）

### Changed

- `templates/WORKFLOW.js.template`：更新为官方 API 规范（export const meta, agent/parallel/pipeline/phase）
- `.claude/rules/workflow-writing.md`：更新为官方 API 规范
- `.claude/agents/workflow-reviewer.md`：更新检查项
- `templates/HOOK.sh.template`：更新为官方 JSON 输出格式（hookSpecificOutput）
- `.claude/rules/hook-writing.md`：更新为官方规范
- `.claude/agents/hook-reviewer.md`：更新检查项
- `templates/SKILL.md.template`：添加完整 frontmatter 字段（when_to_use, argument-hint, arguments 等）
- `templates/AGENT.md.template`：添加 isolation, skills, hooks, paths 字段
- `templates/OUTPUT-STYLE.md.template`：添加 force-for-plugin 字段
- `templates/plugin.template.json`：添加 author 对象
- `.claude/rules/skill-writing.md`：添加完整 Frontmatter 字段表
- `.claude/rules/agent-writing.md`：添加 hooks, paths 字段
- `.claude/rules/output-style-writing.md`：添加 force-for-plugin 字段
- `.claude/rules/plugin-writing.md`：更新 author 字段格式
- `.claude/rules/design-thinking.md`：决策树新增 settings/script 判断路径，复杂度预算新增 Rule 行数
- `scripts/check-limits.sh`：重构为函数式，新增 settings.json/scripts 检查
- `scripts/check-placement.sh`：重构为函数式
- `CLAUDE.md`：覆盖矩阵从 L1-L4 扩展为 L1-L5
- `README.md`：更新架构说明、文件类型表、项目结构

## [1.2.0] - 2026-06-10

### Added

- `templates/RULE.md.template`：Rule 文件模板（基于 Claude 官方定义 + 行业最佳实践）
- `.claude/rules/rule-writing.md`：Rule 编写规范（L2 行为约束层）
  - L0 设计决策：全局 vs 路径级、载体选择、拆分策略
  - L1 语言风格：ALWAYS/NEVER 句式、祈使句、范围定义
  - L2 结构约束：frontmatter、section 模式、文件命名、行数控制
  - L3 质量验证：✅/❌ 示例、边界案例、可测试性
- `.claude/agents/rule-reviewer.md`：Rule 质量校验 agent（L4 层）
- `.claude/commands/review-rule.md`：`/review-rule` 命令（6 维度评分）
- `.claude/skills/new-rule/SKILL.md`：`/new-rule` 脚手架技能
- `.claude/output-styles/rule-author.md`：Rule 编写输出风格
- CLAUDE.md 新增 L1-L4 四层约束架构说明
- CLAUDE.md 模板→规则覆盖矩阵新增 L4 Reviewer Agent 列

### Changed

- `scripts/check-placement.sh`：新增 `.md` in `.claude/` 目录校验
- `scripts/install.sh`：`DEVKIT_RULES` 数组新增 `rule-writing.md`
- `scripts/check-limits.sh`：Rule 行数限制从 200 修正为 150
- `templates/CLAUDE.md.template`：Rule 行数限制从 200 修正为 150
- `.claude/skills/new-claude-md/SKILL.md`：CLAUDE.md 行数限制从 200 修正为 150
- `.claude/skills/new-agent/SKILL.md`：review 命令引用从 `/review-skill` 修正为 `/review-agent`
- `.claude/commands/review-claude-md.md`：required sections 引用修正为 `claude-md-writing.md` 定义的标准
- `.github/CONTRIBUTING.md`：Rules frontmatter 描述修正、Skills 行数限制修正为 500
- README 更新：
  - Supported File Types 新增 Rule.md 行
  - Commands 新增 `/new-rule` 和 `/review-rule`
  - Project Structure 新增 `RULE.md.template` 和 `rule-writing.md`
  - 计数更新：Rules 14→15, Agents 9→10, Skills 10→11, Commands 10→11
  - Badge 更新：File_Types 9→12

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
