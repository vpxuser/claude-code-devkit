---
paths:
  - ".claude/workflows/*.js"
description: "Workflow 编写规范 — 对 .claude/workflows/ 下所有工作流文件生效"
---

# Workflow 编写规范

> 本规则约束 .claude/workflows/*.js 文件的编写方式。
> 官方文档: https://docs.anthropic.com/en/docs/claude-code/workflows

## 核心原则

- 每个 workflow 只做一件事
- 使用官方 API：agent(), parallel(), pipeline(), phase(), log()
- 脚本必须以 `export const meta = {...}` 开头

## 必选结构

```javascript
export const meta = {
  name: '[workflow-name]',
  description: '[One-line description]',
  phases: [
    { title: '[Phase 1]', detail: '[What this phase does]' },
  ],
}

phase('[Phase 1]')
const result = await agent('[prompt]', { label: '[label]', phase: '[Phase 1]' })
return result
```

## meta 字段

| 字段 | 必选 | 说明 |
| --- | --- | --- |
| name | ✅ | 工作流名称 |
| description | ✅ | 一行描述，显示在权限对话框中 |
| phases | ✅ | phase() 调用的条目列表 |

## 可用 API

| 函数 | 用途 |
| --- | --- |
| `agent(prompt, opts)` | 生成子代理 |
| `parallel(thunks)` | 并行执行，等待全部完成 |
| `pipeline(items, ...stages)` | 流水线处理，逐项执行 |
| `phase(title)` | 开始新阶段 |
| `log(message)` | 输出进度信息 |
| `args` | 全局变量，用户输入 |
| `budget` | Token 预算管理 |

## 行为约束

- ALWAYS 以 `export const meta = {...}` 开头
- ALWAYS 为每个 phase() 调用在 meta.phases 中添加条目
- ALWAYS 使用 label 标记 agent 调用
- ALWAYS 处理 null 结果（agent 返回 null 表示用户跳过）
- NEVER 使用 `Date.now()` / `Math.random()` / `new Date()` — 会破坏 resume
- NEVER 在脚本中访问文件系统或 Node.js API
- NEVER 创建超过 meta.phases 定义数量的 phase() 调用

## 示例

### ✅ Do This

```javascript
export const meta = {
  name: 'review-changes',
  description: 'Review changed files across dimensions',
  phases: [{ title: 'Review' }, { title: 'Verify' }],
}

phase('Review')
const findings = await agent('Find bugs in changed files', {
  label: 'review:bugs',
  phase: 'Review',
  schema: FINDINGS_SCHEMA,
})

phase('Verify')
const verified = await parallel(
  findings.map(f => () =>
    agent(`Verify: ${f.title}`, { label: `verify:${f.id}`, phase: 'Verify' })
  )
)

return { confirmed: verified.filter(Boolean) }
```

### ❌ Not This

```javascript
export default async function workflow(args) {
  // 缺少 meta 对象
  // 缺少 phase() 调用
  // 使用自定义函数而非官方 API
  const result = await doEverything(args)
  return result
}
```

<!-- 为什么错: 缺少 meta 导致无法在 /workflows 中显示，缺少 phase() 导致无法追踪进度 -->
