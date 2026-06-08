---
description: "Review a plugin.json file for best practices compliance"
argument-hint: "<path/to/plugin.json>"
---

# Plugin Review Command

Review the plugin.json file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Field Completeness** — Are required fields present:
   `name`, `description`? Are optional fields correct:
   `version`, `author`?

2. **Field Quality** — Is `name` in kebab-case? Is `description` clear and concise (≤100 chars)?
   Is `version` in semver format?

3. **Directory Structure** — Does the plugin directory have the correct structure:
   `.claude-plugin/plugin.json`, `skills/`, `agents/`, `hooks/`?

4. **Component Quality** — Are skills, agents, and hooks correctly defined?
   Do they follow their respective writing rules?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **JSON Compliance** — Is the JSON valid? Are there any syntax errors?

## Output Format

```markdown
## Review: [plugin-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Fields | ✅/❌ | [notes] |
| Field Quality | ✅/❌ | [notes] |
| Directory | ✅/❌ | [notes] |
| Components | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| JSON Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/plugin-writing.md` — Content quality rules
- `templates/plugin.template.json` — Canonical template
