---
description: "Review a rule file for best practices compliance"
argument-hint: "<path/to/rule.md>"
---

# Rule Review Command

Review the rule file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Rule Type Validation** — Is it global (no `paths`) or path-scoped (has `paths`)?
   Does the type match its purpose? Global = thinking framework, path-scoped = file writing spec.

2. **Frontmatter Quality** — Is `description` present, specific, and does it include
   trigger scenarios ("对 X 生效")? For path-scoped rules, does `paths` cover the right file types?

3. **Scope Definition** — Is there a `>` blockquote after the H1 title?
   Does it precisely define what the rule constrains?

4. **Constraint Quality** — Does every constraint start with ALWAYS or NEVER?
   Does every NEVER have an alternative (`— 改为 [correct做法]`)?
   Are constraints ordered by importance (most critical first)?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable?
   Does the ❌ example have an HTML comment explaining why it's wrong?

6. **Line Count** — Is the file ≤ 150 lines? If over, it should be split.

## Output Format

```markdown
## Review: [rule-filename]

### Rule Type: [global | path-scoped]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Rule Type | ✅/❌ | [notes] |
| Frontmatter | ✅/❌ | [notes] |
| Scope | ✅/❌ | [notes] |
| Constraints | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Line Count | ✅/❌ | [N lines] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/rule-writing.md` — Rule writing spec (L2)
- `.claude/rules/yaml-frontmatter.md` — Frontmatter field specifications
- `.claude/rules/markdown-output.md` — Markdown formatting rules
- `templates/RULE.md.template` — Canonical template (L3)
