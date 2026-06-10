---
paths:
  - ".claude/hooks/*.sh"
description: "Hook 编写规范 — 对 .claude/hooks/ 下所有钩子脚本生效"
---

# Hook 编写规范

> 本规则约束 .claude/hooks/*.sh 文件的编写方式。
> 官方文档: https://docs.anthropic.com/en/docs/claude-code/hooks

## 核心原则

- 每个 hook 只处理一个事件类型
- 必须在 5 秒内完成执行
- 使用 stderr 输出日志，stdout 输出决策

## 必选结构

```bash
#!/bin/bash
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

log() { echo "[HOOK] $1" >&2; }

decision() {
  jq -n --arg d "$1" --arg r "$2" '{
    hookSpecificOutput: {
      hookEventName: "[EVENT]",
      permissionDecision: $d,
      permissionDecisionReason: $r
    }
  }'
  exit 2
}

exit 0
```

## 事件类型

| 事件 | 触发时机 |
| --- | --- |
| PreToolUse | 工具调用前 |
| PostToolUse | 工具调用后 |
| SessionStart | 会话开始 |
| Stop | 响应结束 |

## 输入格式 (JSON on stdin)

```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "ls -la" }
}
```

## 输出格式 (exit 2)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny",
    "permissionDecisionReason": "原因"
  }
}
```

## 退出码

| 码 | 含义 |
| --- | --- |
| 0 | 成功，无决策 |
| 1 | 错误 |
| 2 | 决策（allow/deny） |

## 行为约束

- ALWAYS 使用 `set -euo pipefail`
- ALWAYS 使用 stderr 输出日志（`>&2`）
- ALWAYS 在 5 秒内完成
- NEVER 修改输入数据
- NEVER 访问文件系统（除非必要）
- NEVER 忽略错误

## 示例

### ✅ Do This

```bash
#!/bin/bash
set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ "$COMMAND" == *"rm -rf"* ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Dangerous command blocked"
    }
  }'
  exit 2
fi
exit 0
```

### ❌ Not This

```bash
#!/bin/bash
INPUT=$(cat)
echo "allow"
```

<!-- 为什么错: 无 set -euo pipefail、无 jq 格式化输出、无错误处理 -->
