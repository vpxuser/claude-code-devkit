---
name: philosophy
description: 设计哲学 — 解释为什么这样设计，是所有规则的源头
---

# 设计哲学

> 这份文档解释**为什么**这样设计。它不约束任何具体行为——它是所有规则的源头。

## 核心价值观

### 1. Simplicity > Completeness (简单优于完备)

覆盖 80% 场景的 100 行 Skill > 覆盖 100% 场景的 500 行 Skill。

**为什么**: 上下文窗口是有限资源。一个试图处理所有边界情况的 Skill，大部分时间在浪费 token 描述不会发生的场景。把边界情况放到 references/，Claude 只在遇到时才读。

**应用**:

- Skill body 写主路径，Edge Cases section 写已知异常
- 详细的 API 规格放 references/，SKILL.md 只写"See references/api-spec.md"
- 反模式：为了覆盖 5% 的罕见情况，让 95% 的常规调用都多消耗 200 tokens

### 2. Clarity > Cleverness (清晰优于聪明)

一个任何人都能无歧义执行的步骤列表 > 一个精妙但需要解释的算法。

**为什么**: SKILL.md 的读者是人类（审阅者、协作者）和 AI（Claude）。两者都需要**精确的可执行性**，不需要欣赏巧妙的设计。

**应用**:

- 每步写"Use `ToolName` to do X"，不写"Appropriately handle Y"
- 示例是完整可复制的代码块，不是伪代码
- 反模式：写了 200 行推理过程但不给一个可执行的命令

### 3. Action > Explanation (行动优于解释)

告诉 Claude **做什么**，不告诉 Claude **为什么做**（除非"为什么"影响决策）。

**为什么**: Claude 需要指令来执行，不需要被说服。解释放 references/，让主路径保持精悍。

**应用**:

- "Run `grep -r 'TODO' skills/`" 而非 "TODOs are important to track, so you should search for them"
- 为什么做放 `references/philosophy.md`（就像这份文档）
- 反模式：每个 ALWAYS 指令后面跟一段解释段落

### 4. Composability > Monolith (可组合优于整体)

5 个 100 行 Skill 能被 10 种方式组合 > 1 个 500 行 Skill 只能被 1 种方式使用。

**为什么**: 可组合性是杠杆。每个新 Skill 不只是增加一个功能——它和现有 Skill 产生 N×N 的组合可能性。

**应用**:

- 设计时先问"这可以拆成哪两个独立的步骤？"
- Skill 通过明确的输入/输出契约协作
- 引用其他 Skill 时用触发短语：`When the user asks for X after completing Y, /y-skill's output becomes /x-skill's input`
- 反模式：Skill A 内部硬编码调用 Skill B 的步骤，破坏了独立性

### 5. Frictionless First (零摩擦优先)

用户说一句话就能触发 > 用户需要记住精确的命令名。

**为什么**: 可发现性是 Skill 生态的第一指标。用户不应该需要读文档才知道一个 Skill 存在。

**应用**:

- Description 覆盖口头表达、技术术语、非母语表达
- 技能名是 kebab-case 标识符，description 才是用户界面
- 反模式：description 写 "Advanced template-based scaffolding system"，用户永远不知道说"create a skill"时应该触发它

### 6. Self-Healing (自愈能力)

每次纠正都应该变成永久规则。

**为什么**: 人会犯错，AI 也会。错一次 = 规则化 = 永不再犯。这是整个约束体系的演进机制。

**应用**:

- 每次纠正 Claude 后追加："Update the relevant rule file so this doesn't happen again"
- 不要手动记住经验——写入 CLAUDE.md 或 rules/
- 反模式：三次纠正同一个问题但没更新任何规则文件

## 优先级排序

当这些价值观冲突时，按此优先：

```text
Simplicity > Clarity > Composability > Action > Frictionless > Self-Healing
```

**为什么**: 如果 Skill 太复杂（违反 Simplicity），其他所有优点都无法补救——因为 Claude 的上下文已经被浪费了。

## 这份文档的自我定位

- 不加载到日常会话（它不在 rules/ 中，没有 paths）
- 人工审阅者阅读它来理解项目设计意图
- 当价值观冲突需要 trade-off 决策时引用它
- 新协作者的第一份阅读材料
