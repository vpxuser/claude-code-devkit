---
description: "Test whether a skill's description triggers correctly with varied natural language"
argument-hint: "<skill-name>"
---

# Trigger Test Command

Test whether the skill `$ARGUMENTS` will be triggered by different user phrasings.

## Workflow

1. Read the skill's description: `grep -A 10 "^description:" .claude/skills/$ARGUMENTS/SKILL.md`
2. Generate 5 paraphrased user requests that SHOULD trigger this skill
3. For each paraphrase, simulate: would Claude match this request to the skill's description?
4. Report any paraphrase that would NOT trigger

## Trigger Coverage Matrix

For each test phrase, classify the trigger mode:

| # | User Phrase | Mode | Should Trigger? | Would Trigger? |
| --- | --- | --- | --- | --- |
| 1 | [phrase] | explicit request | ✅ | ✅/❌ |
| 2 | [phrase] | file type match | ✅ | ✅/❌ |
| 3 | [phrase] | contextual keyword | ✅ | ✅/❌ |
| 4 | [phrase] | colloquial/slang | ✅ | ✅/❌ |
| 5 | [phrase] | non-native speaker | ✅ | ✅/❌ |

## Output Format

```markdown
## Trigger Test: `$ARGUMENTS`

### Current Description
[description text]

### Coverage
- Explicit requests: [N]/5 trigger
- File type matches: [N]/5 trigger
- Contextual keywords: [N]/5 trigger
- Colloquial variants: [N]/5 trigger
- Non-native variants: [N]/5 trigger

### Paraphrases That Fail
| Phrase | Why It Fails | Suggested Fix |
| --- | --- | --- |

### Recommendation
[Update description to include: ...]
```

## Reference

- Trigger engineering rules: `.claude/rules/progressive-disclosure.md`
- Design principle: P3 (Pushy by default)
