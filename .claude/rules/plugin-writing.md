---
paths:
  - ".claude-plugin/plugin.json"
description: "Plugin 编写规范 — 对 .claude-plugin/ 下所有插件配置文件生效"
---

# Plugin 编写规范

> 本规则约束 .claude-plugin/plugin.json 文件的编写方式。
> 设计哲学见 `references/philosophy.md`。

## 核心原则

### P1: 单一职责

- 每个 plugin 只做一件事
- 如果发现自己做了多件事，立刻拆分为多个 plugin
- 组合优于堆砌：3 个单一功能 plugin > 1 个全能 plugin

### P2: 最小依赖

- 只依赖必要的外部工具
- 避免依赖特定操作系统或环境
- 提供降级方案（如果依赖不可用）

### P3: 可发现性

- 提供清晰的 description
- 使用有意义的 keywords
- 包含使用示例

### P4: 可维护性

- 版本号遵循语义化版本
- 提供 CHANGELOG
- 包含测试用例

## 结构规范

### 必选字段

```json
{
  "name": "[plugin-name]",
  "description": "[一句话描述]"
}
```

### 可选字段

```json
{
  "version": "1.0.0",
  "author": {
    "name": "[作者名]"
  }
}
```

### 字段规范

| 字段 | 类型 | 必选 | 说明 |
|------|------|------|------|
| name | string | ✅ | 插件名称（kebab-case） |
| description | string | ✅ | 一句话描述 |
| version | string | ❌ | 版本号（semver），可选 |
| author | object | ❌ | 作者信息，包含 name 字段 |

### 目录结构

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # 插件清单
├── skills/                  # 技能目录
│   └── <skill-name>/
│       └── SKILL.md
├── agents/                  # Agent 定义
├── hooks/                   # Hook 配置
│   └── hooks.json
├── .mcp.json                # MCP 服务器配置
├── .lsp.json                # LSP 服务器配置
├── monitors/                # 后台监控配置
├── bin/                     # 可执行文件
└── settings.json            # 默认设置
```

## 行为约束

- ALWAYS 使用 kebab-case 命名插件
- ALWAYS 提供清晰的 description（≤100 字符）
- ALWAYS 使用语义化版本号（semver）
- ALWAYS 包含 keywords 以提高可发现性
- NEVER 使用过长的 description — 改为 ≤100 字符
- NEVER 跳过 version 字段 — 改为始终提供 semver 版本
- NEVER 硬编码路径 — 改为使用相对路径
- NEVER 忽略依赖声明 — 改为在 description 或文档中说明

## 输出格式

### plugin.json

```json
{
  "name": "my-plugin",
  "description": "My awesome Claude Code plugin",
  "version": "1.0.0"
}
```

## 示例

### ✅ Do This

```json
{
  "name": "pentest-toolkit",
  "description": "渗透测试工具集",
  "version": "1.0.0",
  "author": {
    "name": "Security Team"
  }
}
```

### ❌ Not This

```json
{
  "name": "pentest-toolkit"
}
```

<!-- 为什么错: 缺少 description 导致不可发现 -->
