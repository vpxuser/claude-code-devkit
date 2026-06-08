---
paths:
  - ".claude/commands/*.md"
description: "命令文件编写规范 — 对 .claude/commands/ 下所有命令定义文件生效"
---

# 命令编写规范

> 命令（Commands）是单文件提示词，通过 `/name` 手动调用。与 Skill 不同，命令不会被 Claude 自动触发。

## 与 Skill 的选择

| 场景 | 用 Command | 用 Skill |
| --- | --- | --- |
| 仅手动调用 | ✅ | ✅ |
| Claude 自动判断触发 | ❌ | ✅ |
| 需要捆绑支持文件 | ❌ | ✅ |
| 简单一步操作 | ✅ | 过度设计 |
| 多步骤工作流 | 可能 | ✅ |

> 新工作流建议优先用 Skill。Command 适用于简单的一步操作。

## 结构规范

- 文件以 YAML frontmatter 开头（`description` + `argument-hint`）
- 必选 section：`## Purpose`、`## Inputs`、`## Workflow`、`## Output Format`
- Workflow 每步编号，标注使用的工具
- Output Format 给出精确的输出模板

## Frontmatter 字段

| 字段 | 必选 | 说明 |
| --- | --- | --- |
| `description` | ✅ | 命令功能描述 |
| `argument-hint` | ❌ | 参数提示，如 `<file-path>` |

## 内容规范

- 步骤可测试：每步有明确的完成标准
- 输出格式精确：用户看到的内容必须预先定义
- 错误路径有处理：输入无效、文件不存在、工具失败
