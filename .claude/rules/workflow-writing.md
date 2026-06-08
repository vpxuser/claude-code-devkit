---
paths:
  - ".claude/workflows/*.js"
description: "Workflow 编写规范 — 对 .claude/workflows/ 下所有工作流文件生效"
---

# Workflow 编写规范

> 本规则约束 .claude/workflows/*.js 文件的编写方式。
> 设计哲学见 `references/philosophy.md`。

## 核心原则

### W1: 单一职责

- 每个 workflow 只做一件事
- 如果发现自己写了 "and also..."，立刻拆分为两个 workflow
- 组合优于堆砌：3 个 50 步骤 workflow > 1 个 150 步骤 workflow

### W2: 阶段清晰

- 每个阶段有明确的输入/输出
- 阶段之间通过返回值传递数据
- 每个阶段有注释说明用途

### W3: 可恢复性

- 支持从任意阶段恢复执行
- 中间结果持久化到文件
- 失败时提供重试机制

### W4: 可观测性

- 每个阶段输出进度信息
- 关键决策点记录日志
- 最终结果结构化输出

## 结构规范

### 必选结构

```javascript
/**
 * Workflow: [NAME]
 *
 * Purpose: [一句话描述]
 * Trigger: [触发条件]
 */

// args 是全局变量，由运行时注入
const { target } = args;

// Phase 1: [名称]
// Phase 2: [名称]
// Phase 3: [名称]
```

### 阶段命名

- 使用 `phase1()`, `phase2()`, `phase3()` 格式
- 每个阶段函数有 JSDoc 注释
- 阶段数量 ≤ 7（超过则拆分）

## 行为约束

- ALWAYS 使用 `export default` 导出主函数
- ALWAYS 为每个阶段添加 JSDoc 注释
- ALWAYS 在关键决策点使用 `console.log()` 记录
- ALWAYS 处理异常并提供有意义的错误信息
- NEVER 在 workflow 中硬编码配置 — 改为从 args 或配置文件读取
- NEVER 跳过错误处理 — 改为 try-catch 并记录失败原因
- NEVER 创建超过 7 个阶段的 workflow — 改为拆分为多个 workflow
- NEVER 在阶段之间共享可变状态 — 改为通过返回值传递数据

## 输出格式

### 进度输出

```javascript
console.log(`[Phase 1] 开始执行: ${description}`);
console.log(`[Phase 1] 完成: ${result.summary}`);
```

### 最终结果

```javascript
return {
  success: true,
  summary: "工作流完成摘要",
  results: {
    phase1: phase1Result,
    phase2: phase2Result,
    phase3: phase3Result,
  },
};
```

## 示例

### ✅ Do This

```javascript
/**
 * Workflow: pentest-full-scan
 *
 * Purpose: 执行完整的渗透测试扫描流程
 * Trigger: 用户请求完整扫描
 */

export default async function workflow(args) {
  const { target } = args;

  // Phase 1: 侦察
  const recon = await reconPhase(target);

  // Phase 2: 扫描
  const scan = await scanPhase(recon);

  // Phase 3: 报告
  const report = await reportPhase(scan);

  return { success: true, results: { recon, scan, report } };
}
```

### ❌ Not This

```javascript
export default async function workflow(args) {
  // 没有阶段划分
  // 没有 JSDoc 注释
  // 没有错误处理
  const result = await doEverything(args);
  return result;
}
```

<!-- 为什么错: 没有阶段划分导致不可维护，没有注释导致不可理解，没有错误处理导致不可靠 -->
