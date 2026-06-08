---
description: "Review a HOOK.sh file for best practices compliance"
argument-hint: "<path/to/HOOK.sh>"
---

# Hook Review Command

Review the HOOK.sh file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Structure Completeness** — Are all required sections present:
   Shebang, set -euo pipefail, input parsing, log function, decision function?

2. **Error Handling** — Does the hook handle errors gracefully?
   Are there proper exit codes? Are error messages meaningful?

3. **JSON Handling** — Does the hook parse JSON input correctly?
   Does it use jq for JSON parsing? Are there fallbacks for missing fields?

4. **Decision Output** — Does the hook output decisions in the correct format?
   Is it using exit code 2 for decisions? Is the JSON structure correct?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **Shell Compliance** — Run `shellcheck` on the file. Report every violation.

## Output Format

```markdown
## Review: [hook-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Structure | ✅/❌ | [notes] |
| Error Handling | ✅/❌ | [notes] |
| JSON Handling | ✅/❌ | [notes] |
| Decision Output | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Shell Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/hook-writing.md` — Content quality rules
- `templates/HOOK.sh.template` — Canonical template
