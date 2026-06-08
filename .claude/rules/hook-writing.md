---
paths:
  - ".claude/hooks/*.sh"
  - ".claude/hooks/*.js"
description: "Hook 编写规范 — 对 .claude/hooks/ 下所有钩子文件生效"
---

# Hook 编写规范

> 本规则约束 .claude/hooks/*.sh 和 *.js 文件的编写方式。
> 设计哲学见 `references/philosophy.md`。

## 核心原则

### H1: 单一职责

- 每个 hook 只处理一个事件类型
- 如果发现自己处理多个事件，立刻拆分为多个 hook
- 组合优于堆砌：3 个单一事件 hook > 1 个多事件 hook

### H2: 最小权限

- 只读取必要的输入字段
- 只输出必要的决策字段
- 避免访问文件系统或网络（除非必要）

### H3: 快速执行

- Hook 必须在 5 秒内完成执行
- 避免耗时操作（网络请求、大量文件读写）
- 如果需要耗时操作，改为异步执行

### H4: 可观测性

- 使用 stderr 输出日志
- 关键决策点记录原因
- 错误时提供有意义的错误信息

## 结构规范

### Bash Hook 结构

```bash
#!/bin/bash
set -euo pipefail

# 读取输入
INPUT=$(cat)

# 解析输入
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 日志函数
log() {
  echo "[HOOK] $1" >&2
}

# 决策函数
decision() {
  local decision="$1"
  local reason="$2"
  echo "{\"decision\": \"$decision\", \"reason\": \"$reason\"}"
  exit 2
}

# 主逻辑
# ...
```

### JavaScript Hook 结构

```javascript
/**
 * Hook: [NAME]
 *
 * Purpose: [一句话描述]
 * Event: [触发事件]
 */

module.exports = async function hook(input) {
  const { tool_name, tool_input } = input;

  // 日志
  console.error(`[HOOK] 触发: ${tool_name}`);

  // 决策
  return {
    decision: "allow",
    reason: "Hook 通过",
  };
};
```

## 行为约束

- ALWAYS 使用 `set -euo pipefail` (Bash) 或 try-catch (JavaScript)
- ALWAYS 使用 stderr 输出日志（`>&2` 或 `console.error`）
- ALWAYS 提供有意义的决策原因
- ALWAYS 在 5 秒内完成执行
- NEVER 修改输入数据
- NEVER 访问文件系统（除非必要且有权限）
- NEVER 执行网络请求（除非必要且有权限）
- NEVER 忽略错误 — 改为记录并返回错误决策
- NEVER 创建超过 50 行的 hook — 改为拆分为多个 hook

## 输出格式

### 决策输出（exit 2）

```json
{
  "decision": "allow|block",
  "reason": "决策原因"
}
```

### 日志输出（stderr）

```text
[HOOK] Hook 名称: 描述
[HOOK] 决策: allow|block - 原因
```

## 示例

### ✅ Do This

```bash
#!/bin/bash
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

log() {
  echo "[HOOK] $1" >&2
}

decision() {
  echo "{\"decision\": \"$1\", \"reason\": \"$2\"}"
  exit 2
}

log "触发: $TOOL_NAME"

if [[ "$TOOL_NAME" == "Bash" ]]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
  if [[ "$COMMAND" == *"rm -rf /"* ]]; then
    decision "block" "阻止危险命令: rm -rf /"
  fi
fi

exit 0
```

### ❌ Not This

```bash
#!/bin/bash
# 没有 set -euo pipefail
# 没有日志
# 没有错误处理
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
if [[ "$TOOL_NAME" == "Bash" ]]; then
  # 直接执行命令，不检查
  echo "allow"
fi
```

<!-- 为什么错: 没有 set -euo pipefail 导致错误不可靠，没有日志导致不可观测，没有错误处理导致不可恢复 -->
