---
paths:
  - ".claude/hooks/*.sh"
description: "Hook 编写规范 — 对 .claude/hooks/ 下所有钩子脚本生效"
---

# Hook 编写规范

> 本规则约束 `.claude/hooks/*.sh` 文件的编写方式。
> 官方文档: https://docs.anthropic.com/en/docs/claude-code/hooks

## 目录与路径

- ALWAYS hook 脚本放在 `.claude/hooks/` 目录下
- ALWAYS 使用 `${CLAUDE_PROJECT_DIR}/.claude/hooks/xxx.sh` 引用 hook 脚本
- NEVER 将 hook 脚本放在 `scripts/` 目录 — 改为 `.claude/hooks/`
- NEVER 使用绝对路径或 `~` 引用 hook — 改为 `${CLAUDE_PROJECT_DIR}` 变量

## 核心原则

- ALWAYS 每个 hook 只处理一个事件类型
- ALWAYS 使用 `set -euo pipefail`
- ALWAYS 使用 stderr 输出日志（`>&2`），stdout 输出决策
- ALWAYS PostToolUse timeout 设 5000ms，Stop 设 10000ms
- NEVER 省略 timeout 字段 — 改为显式声明
- NEVER 修改输入数据 — 改为只读取 stdin 内容

## 事件选择

| 事件 | 适用场景 | matcher |
| --- | --- | --- |
| PostToolUse | 单文件检查（Write/Edit 后） | `"Write\|Edit"` |
| Stop | 全局扫描（turn 结束前） | `""` |
| PreToolUse | 阻止危险操作 | 工具名 |

- ALWAYS 单文件验证用 PostToolUse，全局扫描用 Stop
- NEVER 在 PostToolUse 中做全项目扫描 — 改为 Stop hook

## 输入格式 (JSON on stdin)

PostToolUse: `{"tool_name":"Write","tool_input":{"file_path":".claude/rules/example.md"}}`
Stop: `{"stop_hook_active":true}`

## 输出格式 (exit 2)

```json
{"hookSpecificOutput":{"hookEventName":"PostToolUse","permissionDecision":"deny","permissionDecisionReason":"原因"}}
```

| 退出码 | 含义 |
| --- | --- |
| 0 | 成功，无决策 |
| 1 | 错误 |
| 2 | 决策（allow/deny） |

## 示例

### ✅ Do This

```bash
#!/bin/bash
set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if [[ "$COMMAND" == *"rm -rf"* ]]; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",
    permissionDecision:"deny",permissionDecisionReason:"Blocked"}}'
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
