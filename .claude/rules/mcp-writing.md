---
paths:
  - ".mcp.json"
description: "MCP 配置文件编写规范 — 对 .mcp.json 文件生效"
---

# MCP 配置编写规范

> MCP（Model Context Protocol）配置文件定义 Claude Code 可用的外部工具服务器。

## 结构规范

### 必选字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `$schema` | JSON Schema 地址 | `"https://code.claude.com/schemas/mcp.json"` |
| `mcpServers` | 服务器配置对象 | 见下方 |

### 可选字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `_comment` | 配置说明（人类可读） | `"项目 MCP 服务器配置"` |

## mcpServers 规范

### 服务器命名

- ALWAYS 使用 kebab-case 命名服务器
- ALWAYS 名称与实际工具/功能对应
- NEVER 使用驼峰或下划线
- NEVER 使用过长名称（≤30 字符）

✅ 正确：

```json
"playwright": { ... }
"ast-grep": { ... }
"nodriver-proxy-mcp": { ... }
```

❌ 错误：

```json
"Playwright": { ... }      <!-- 为什么错: 大写开头 -->
"ast_grep": { ... }        <!-- 为什么错: 下划线 -->
"my-very-long-server-name-for-testing": { ... }  <!-- 为什么错: 过长 -->
```

### 服务器配置字段

| 字段 | 必选 | 说明 | 示例 |
|------|------|------|------|
| `command` | ✅ | 可执行命令 | `"npx"`, `"node"`, `"python"` |
| `args` | ❌ | 命令参数数组 | `["@playwright/mcp@latest"]` |
| `env` | ❌ | 环境变量对象 | `{"API_KEY": "xxx"}` |
| `cwd` | ❌ | 工作目录 | `"./scripts"` |

### 配置模式

#### 模式一：npx 直接运行

```json
{
  "command": "npx",
  "args": ["@scope/package@latest"]
}
```

#### 模式二：本地可执行文件

```json
{
  "command": "my-mcp-server"
}
```

#### 模式三：带环境变量

```json
{
  "command": "npx",
  "args": ["@scope/package"],
  "env": {
    "API_KEY": "${MCP_API_KEY}"
  }
}
```

#### 模式四：带工作目录

```json
{
  "command": "python",
  "args": ["server.py"],
  "cwd": "./mcp-servers/my-server"
}
```

## 格式规范

- ALWAYS 使用 2 空格缩进
- ALWAYS 服务器配置按字母顺序排列
- ALWAYS `args` 数组每项占一行（≤3 项时可单行）
- NEVER 使用 tab 缩进
- NEVER 在 JSON 中使用注释（`_comment` 字段除外）
- NEVER 尾随逗号

## 安全规范

- NEVER 硬编码密钥/令牌到 `.mcp.json` — 改为使用环境变量引用
- NEVER 提交包含敏感信息的 `.mcp.json` — 改为加入 `.gitignore`
- ALWAYS 使用 `${ENV_VAR}` 语法引用环境变量
- ALWAYS 在 `_comment` 中说明服务器用途

## 行为约束

- ALWAYS 在 `_comment` 中说明项目用途和服务器列表
- ALWAYS 使用 `@latest` 或明确版本号（避免 `@*` 通配符）
- ALWAYS 服务器名称与实际功能对应（不要用 `server1`, `server2`）
- NEVER 配置未使用的服务器 — 改为删除或注释说明
- NEVER 使用 `file://` 协议 — 改为 `npx` 或本地命令

## 输出格式

```json
{
  "$schema": "https://code.claude.com/schemas/mcp.json",
  "_comment": "[项目名称] MCP 服务器配置。[用途说明]",
  "mcpServers": {
    "server-a": {
      "command": "npx",
      "args": ["@scope/package@latest"]
    },
    "server-b": {
      "command": "local-command",
      "env": {}
    }
  }
}
```

## 示例

### ✅ 正确示例

```json
{
  "$schema": "https://code.claude.com/schemas/mcp.json",
  "_comment": "pentest-skills MCP 服务器配置。Playwright 用于 API 发现，ast-grep 用于 JS AST 分析",
  "mcpServers": {
    "ast-grep": {
      "command": "npx",
      "args": ["@notprolands/ast-grep-mcp"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### ❌ 错误示例

```json
{
  "mcpServers": {
    "Playwright": {                      <!-- 为什么错: 大写命名 -->
      "command": "npx",
      "args": ["@playwright/mcp"]        <!-- 为什么错: 缺少版本号 -->
    },
    "server1": {                         <!-- 为什么错: 无意义名称 -->
      "command": "python server.py",     <!-- 为什么错: command 和 args 混淆 -->
      "API_KEY": "sk-xxx"                <!-- 为什么错: 硬编码密钥 -->
    }
  }
}
```

## 质量检查

- [ ] `$schema` 字段存在且指向正确地址？
- [ ] `_comment` 说明了项目用途？
- [ ] 服务器名称使用 kebab-case？
- [ ] 没有硬编码的密钥或令牌？
- [ ] JSON 语法正确（无尾随逗号、无注释）？
- [ ] 服务器按字母顺序排列？

## 边界案例

- 当服务器需要特殊权限时：在 `_comment` 中说明，不要硬编码
- 当服务器配置复杂时：拆分为多个简单配置，不要堆砌
- 当环境变量缺失时：服务器启动会失败，这是预期行为
