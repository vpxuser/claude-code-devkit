---
paths:
  - "skills/**/SKILL.md"
  - "templates/**/SKILL.md*"
description: "SKILL.md 编写规范 — 对 skills/ 和 templates/ 下的 SKILL.md 文件生效"
---

# SKILL.md 编写规范

> 本规则约束 SKILL.md 的**内容质量**，配合 `markdownlint` 的**格式校验**和 `yaml-frontmatter.md` 的**元数据规范**构成三层约束。

## 目录结构约束

每个 skill 是自包含单元，目录结构固定：

```text
.claude/skills/<name>/
├── SKILL.md              # 必选 — 技能定义（根目录仅此文件）
├── scripts/              # 可选 — 辅助脚本（.sh/.py/.js）
├── references/           # 可选 — 参考文档（.md/.txt）
├── data/                 # 可选 — 数据文件（.txt/.json/.yaml/.csv/.xml/.dat）
└── templates/            # 可选 — 该技能专属的模板文件
```

- ALWAYS 根目录只放 `SKILL.md`，其他文件必须放入对应子目录
- ALWAYS `scripts/` 只放 `.sh`、`.py`、`.js` 可执行脚本
- ALWAYS `references/` 只放 `.md`、`.txt` 参考文档
- ALWAYS `data/` 放数据文件：字典、配置、CSV 等（`.txt/.json/.yaml/.csv/.xml/.dat`）
- ALWAYS `templates/` 放该技能专属的模板（任意类型）
- NEVER 在 skill 根目录放置辅助文件（如 `helper.sh`、`notes.md`）— 放入对应子目录
- NEVER 在子目录中放置不属于该目录的文件类型（如 `references/` 中放 `.sh`）
- NEVER 创建 `scripts/`、`references/`、`data/`、`templates/` 以外的子目录

## 指令写作原则

- 每一条指令必须是**可执行的动作**：指明用什么工具、对什么对象、产出什么结果
- 使用祈使句："Run `grep` on..."，而非 "You should run grep..."
- 指令按优先级排列：最重要的步骤排在最前
- 每条 NEVER 指令后必须跟随替代方案（`— 改为 [方案]`）

## 触发条件规范

- Description 字段至少包含 3 个触发短语（mention/working with/asked to）
- 触发短语覆盖：用户主动请求、文件类型匹配、上下文关键词三种触发模式
- 宁可过度触发（false positive），不可漏触发（false negative）

## 示例规范

- 每个技能必须包含至少一组 ✅/❌ 对比示例
- ✅ 示例必须是**完整可复制**的代码块
- ❌ 示例后必须用 HTML 注释标注错误原因：`<!-- 为什么错: [原因] -->`
- 示例覆盖：常规场景 + 一个边界场景

## 步骤可测试性

- Workflow 中每个步骤命名具体的工具名（Read, Grep, Bash, Write 等）
- 每个步骤有明确的**验证点**："确认输出包含 X" 或 "若返回空则停止"
- 错误处理覆盖：工具失败、结果为空、结果过多三种情况

## 边界案例

- Edge Cases section 至少覆盖：空输入、超大输入、权限不足三种情况
- 每个边界案例给出**确定性处理方式**，不留下判断空白
