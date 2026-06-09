---
description: "Design thinking rules — loaded every session, applies BEFORE writing any file"
---

# 设计思维规范

> 本规则不约束产出物格式，约束的是**设计决策过程**。加载于每次会话，优先级最高。
>
> 设计哲学（为什么这样设计）见 `references/philosophy.md`。
> 渐进式披露和 Token 经济学见 `.claude/rules/progressive-disclosure.md`。

## 核心原则

### P1: Generate First, Clarify Second

- 收到设计需求后，**先产出完整草稿**，再做澄清
- 不确定的地方用 `<!-- ASSUMPTION: [假设内容] -->` 标记
- 禁止以"请问你希望..."开头——先给方案，再问调整

### P2: One Job Per Skill

- 每个 SKILL.md 只做一件事
- 如果发现自己写了 "and also..."，立刻拆分为两个技能
- 组合优于堆砌：5 个 100 行技能 > 1 个 500 行技能

### P3: Pushy by Default

- description 宁可过度触发（false positive），不可漏触发（false negative）
- 每次设计完自问："用户用完全不同的措辞描述同一需求时，会触发吗？"
- 触发短语覆盖三种模式：用户主动请求、文件类型匹配、上下文关键词

### P4: Imperative Over Advisory

- 指令写"Execute X using Tool Y"，不写"You should consider X"
- 找遍全文的"应该"、"建议"、"考虑"、"可以"——全部替换为确定性指令
- 每一条 NEVER 必须配一个替代方案

### P5: Concrete Over Abstract

- 每个指令给具体示例，每套规则给 ✅/❌ 对比
- 一个具体示例 > 三段抽象描述
- 示例覆盖常规场景 + 一个边界场景

### P6: Compose, Don't Expand

- 遇到复杂需求时，第一反应不是扩展现有技能，而是思考能否组合多个小技能
- 技能间通过明确输入/输出契约协作
- 公用逻辑抽取为 references/ 而非复制

### P7: Prefer Existing Tools

- 启动项目前先搜索：MCP Server、CLI 工具、现有 Skill/Agent
- 优先包装成熟工具（如 nmap、curl、mitmproxy）而非重写其核心功能
- 选择工具的标准：有社区维护、版本活跃、生产环境验证
- AI 造轮子只在以上都没有合适方案时才考虑
- 在 SKILL.md 的 References 中记录选用的外部工具及其版本

## 设计决策树

每次接到新需求，按此顺序判断：

```text
User: "I need [capability]"

1. Does an existing tool already solve this?
   YES → Wrap/orchestrate it, don't reimplement
   NO  → Go to 2

2. Does this capability already exist in another skill?
   YES → Tell user, suggest composing with it
   NO  → Go to 3

3. Is this a fixed, repeatable workflow?
   NO  → Is it a one-off task?
         YES → Just do it inline, no file needed
         NO  → Go to 4
   YES → Go to 4

4. Does it need supporting files (checklists, templates, scripts)?
   YES → Skill (.claude/skills/<name>/SKILL.md)
   NO  → Go to 5

5. Does it need to be MANUALLY invoked only (Claude should never auto-trigger)?
   YES → Are the instructions complex (>50 lines)?
         YES → Skill with disable-model-invocation: true
         NO  → Command (.claude/commands/<name>.md)
   NO  → Go to 6

6. Is the task:
   - Read-only analysis of existing files? → Agent (.claude/agents/<name>.md)
   - Multiple agents orchestrated dynamically? → Workflow (.claude/workflows/<name>.js)
   - Context-aware interactive workflow? → Skill (.claude/skills/<name>/SKILL.md)
```

## 复杂度预算

设计时始终跟踪复杂度预算：

| 指标 | 软上限 | 硬上限 | 超限时 |
| --- | --- | --- | --- |
| SKILL.md 行数 | 300 | 500 | 拆分到 references/ |
| Workflow 步骤数 | 7 | 12 | 拆分为多个技能组合 |
| Agent tools 数量 | 3 | 6 | 缩小职责范围 |
| CLAUDE.md 行数 | 80 | 150 | 拆分到 `.claude/rules/` |
| Frontmatter 字段数 | 5 | 10 | 只保留必选+关键可选 |

## 设计自检

每完成一个设计，在写文件之前自问：

1. "如果我是用户，用完全不同的措辞描述同样需求，这个技能会被触发吗？"
2. "这个技能的每个步骤，换成另一个工程师能无歧义执行吗？"
3. "哪里会出错？空输入、超大输入、权限不足——都覆盖了吗？"
4. "有没有可以删除的段落？如果一句话没增加新信息，删除它"
5. "500 行能装下吗？如果不能，现在就该拆"

## 反模式目录

以下是常见设计错误——识别并避免：

| 反模式 | 为什么错 | 正确做法 |
| --- | --- | --- |
| 巨型技能（400+ 行一个文件） | 上下文膨胀，触发不精准 | 拆为多个 80-150 行的技能 |
| 模糊 description | 技能从不被触发 | 列出 5+ 个具体触发短语 |
| 全读写权限（allowed-tools: 全部） | 安全风险 + 范围膨胀 | 只列出实际需要的工具 |
| 无示例 | 用户和 Claude 都不知道期望输出 | ✅/❌ 对比例子不可省略 |
| 无错误路径 | 工具调用失败时行为不确定 | 每个步骤覆盖失败时的 fallback |
| 嵌套 if-then 迷宫 | 不可测试，不可维护 | 拆分条件分支为独立技能 |
| "以及更多..." | 范围无限膨胀 | 明确声明 scope 边界 |
| 提供建议而非指令 | Claude 忽略或执行不一致 | 祈使句 + 具体工具名 |
| 重写已有成熟工具 | 可靠性差、维护成本高 | 包装 nmap/curl/sqlmap 等成熟工具 |
| 跳过工具选型 | "AI 能写"不等于"应该写" | 先搜索 MCP Server/CLI/现有 Skill |
