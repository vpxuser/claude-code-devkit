# Contributing to claude-code-devkit

感谢你的贡献！

## 开发流程

1. Fork 本仓库
2. Clone 到本地：`git clone https://github.com/your-username/claude-code-devkit.git`
3. 创建分支：`git checkout -b feat/my-feature`
4. 修改文件
5. 验证：`npx markdownlint .claude/**/*.md templates/**/*.md`
6. 提交：`git commit -m "feat: add my-feature"`
7. 推送：`git push origin feat/my-feature`
8. 创建 Pull Request

## 文件规范

### Rules（`.claude/rules/`）

- 文件名：kebab-case，如 `skill-writing.md`
- 无 YAML frontmatter
- 以 `# H1` 标题开头
- 约束用 `ALWAYS` / `NEVER` 前缀
- `NEVER` 必须配替代方案

### Skills（`.claude/skills/`）

- 目录名：kebab-case，如 `new-skill/`
- 入口文件：`SKILL.md`
- YAML frontmatter 必选：`name`、`description`
- ≤ 200 行，长内容拆到 `references/`

### Templates（`templates/`）

- 文件名：`<TYPE>.template`，如 `SKILL.md.template`
- 占位符用 `{{PLACEHOLDER}}` 格式

## 提交信息格式

```
<type>: <description>

type: feat | fix | docs | refactor | chore | test
```

示例：
- `feat: add workflow-writing rule`
- `fix: correct YAML frontmatter field order`
- `docs: update README with install instructions`

## Code of Conduct

尊重所有参与者，保持专业和友善。
