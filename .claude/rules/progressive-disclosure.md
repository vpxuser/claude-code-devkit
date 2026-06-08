---
description: "Progressive disclosure and token economics — loaded every session"
---

# 渐进式披露与 Token 经济学

> 这条规则管的是**信息如何分层**，是 Claude Code Skills 架构中最基础的设计模式。

## 渐进式披露：三层加载模型

每个 Skill 的信息分为三个加载层级，逐层深入：

```text
Layer 1: Frontmatter description
    ↓ 加载时机：Claude 扫描所有 Skill 的 description
    ↓ Token 成本：~50 tokens per skill
    ↓ 作用：让 Claude 决定"是否加载这个 Skill"

Layer 2: SKILL.md body
    ↓ 加载时机：Claude 判断 description 匹配 → 加载整个文件
    ↓ Token 成本：全部内容（因此必须 ≤ 500 行）
    ↓ 作用：核心指令，Claude 执行任务的最小必要信息

Layer 3: references/
    ↓ 加载时机：Claude 执行过程中遇到引用 → 按需 Read
    ↓ Token 成本：仅当被读取时
    ↓ 作用：API 规格、详细示例、边界案例手册
```

### 设计准则

- L1 必须**自足**：只看 description，Claude 就能准确判断是否触发
- L2 必须**完整**：不依赖 references 也能完成 80% 的常规任务
- L3 必须**可索引**：文件名描述内容，L2 中用清晰的路径引用指向它
- 永远不要把所有信息放在一层：500 行全在 L2 = 每次都消耗 500 行 token

## Token 经济学

### 成本公式

```text
Session Cost = CLAUDE.md (~100 lines)
             + design-thinking.md (~80 lines)
             + progressive-disclosure.md (~50 lines)
             + yaml-frontmatter.md (~60 lines)
             + all triggered SKILL.md bodies (variable)
             + all Read references (on-demand)
```

### 设计决策的 Token 影响

| 设计决策 | Token 影响 | 建议 |
| --- | --- | --- |
| 在 CLAUDE.md 中内嵌长规则 | 每会话 100+ tokens | 拆分到 `.claude/rules/` 并设置 paths |
| Skill description 模糊 | 该 Skill 永远不被触发 = 浪费 | 写 5+ 个具体触发短语 |
| 巨型 SKILL.md (500+ 行) | 每次触发浪费 200+ tokens | 拆分为 references/ |
| references/ 无引用路径 | Claude 不知道该读什么 | 明确的 "See references/x.md" |
| 规则文件无 paths 过滤 | 每会话都加载 = 累积成本 | 能加 paths 就加 paths |

### Token 预算意识

- 无 paths 过滤的规则文件 = **每个会话**的固定成本
- 当前无 paths 规则：`design-thinking.md`、`progressive-disclosure.md`
- 有 paths 的规则仅在编辑对应文件时加载 = 零日常成本
- 原则：只有**每次会话都需要的思维框架**才设为无 paths

## 触发工程

### Description 的三种触发模式

```yaml
description: >
  [一句话功能摘要].

  Use when user mentions: [关键词列表 — 用户可能说的任何措辞].
  Use when user asks to: [任务描述 — 用户请求的目标].
  Use when working with: [文件类型/目录 — 上下文触发].
```

### 触发测试清单

写完 description 后，用以下变体自测：

| 原始需求 | 变体 1（同义） | 变体 2（更口语） | 变体 3（更技术） |
| --- | --- | --- | --- |
| "create a skill" | "add a new skill" | "make a skill" | "scaffold SKILL.md" |

三个变体都应该触发同一个 Skill。如果有一个不行，description 需要扩展。

### 触发精准度权衡

| | 过度触发 (False Positive) | 漏触发 (False Negative) |
| --- | --- | --- |
| 用户体验 | Claude 加载了不需要的 Skill | 用户需要用精确措辞重复请求 |
| 成本 | 浪费 Skill body 的 token | 用户挫败，任务无法完成 |
| **策略** | **可接受** | **不可接受** |

> 宁可 10% 的 session 多加载一个不必要的 Skill，也不可 1% 的 session 用户找不到功能。
