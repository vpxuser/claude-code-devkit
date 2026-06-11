---
paths:
  - ".claude/settings.json"
  - ".claude/settings.local.json"
  - "templates/settings.json*"
description: "Settings 编写规范 — 对 .claude/settings.json 和 templates/settings.json 文件生效"
---

# Settings 编写规范

> 本规则约束 .claude/settings.json 文件的编写方式。
> 官方文档: https://docs.anthropic.com/en/docs/claude-code/settings

## 核心原则

- ALWAYS 使用 JSON schema 验证配置格式
- ALWAYS 将敏感文件加入 deny 列表
- ALWAYS 使用环境变量存储密钥
- NEVER 硬编码 API 密钥或令牌
- NEVER 授予过多的权限 — 改为按需授权
- NEVER 跳过权限配置 — 改为显式声明 allow/ask/deny

## 结构规范

### 必选字段

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings"
}
```

### 核心配置项

| 配置项 | 类型 | 说明 |
|------|------|------|
| `permissions` | object | 权限配置（allow、ask、deny） |
| `hooks` | object | 生命周期钩子 |
| `env` | object | 环境变量 |
| `model` | string | 默认模型 |
| `outputStyle` | string | 输出风格 |
| `language` | string | 响应语言 |

## 权限配置规范

- `allow`: 允许 Claude 自动执行的操作，无需用户确认
- `ask`: 需要用户确认的操作
- `deny`: 禁止 Claude 执行的操作

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)", "Read", "Write", "Edit"],
    "ask": ["Bash(rm *)", "Bash(curl *)"],
    "deny": ["Read(./.env)", "Read(./secrets/**)"]
  }
}
```

## Hooks 配置规范

### 路径引用

- ALWAYS 使用 `${CLAUDE_PROJECT_DIR}/.claude/hooks/xxx.sh` 引用 hook 脚本
- NEVER 使用 `$CLAUDE_FILE_PATH` 作为 hook 脚本路径 — 改为 `${CLAUDE_PROJECT_DIR}`
- NEVER 使用绝对路径或 `~` — 改为 `${CLAUDE_PROJECT_DIR}` 变量

### 事件类型

| 事件 | 触发时机 | 适用场景 |
|------|----------|----------|
| `PostToolUse` | 工具调用后 | 单文件检查（Write/Edit 后验证） |
| `Stop` | 响应结束 | 全局检查（turn 结束前扫描） |
| `PreToolUse` | 工具调用前 | 阻止危险操作 |
| `SessionStart` | 会话开始 | 环境初始化 |

### 配置格式

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/post-write-check.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/stop-check.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

- ALWAYS 每个 hook 配置包含 `timeout` 字段
- ALWAYS PostToolUse timeout 设为 5000ms
- ALWAYS Stop timeout 设为 10000ms

## 示例

### ✅ Do This

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings",
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)"],
    "deny": ["Read(./.env)", "Read(./secrets/**)"]
  }
}
```

### ❌ Not This

```json
{
  "permissions": {
    "allow": ["*"]
  }
}
```

<!-- 为什么错: 授予所有权限，违反最小权限原则 -->
