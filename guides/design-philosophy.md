# Claude Code Design Philosophy Reference

This document distills Claude Code's official design philosophy. Use this when generating any configuration file.

## Source

Derived from:
- [Claude Code Overview](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- Agent Skills Specification ([agentskills.io](https://agentskills.io))

## The Three Laws

1. **Progressive disclosure** — Load only what's needed, when it's needed. Metadata is always loaded (~100 tokens). Body loads on trigger (<5k tokens). Resources load on demand (unlimited).
2. **Filesystem-based** — Files exist on disk. Claude reads them via bash. Scripts execute via bash — only output enters context.
3. **Context is precious** — Every token competes with system prompt, conversation history, and other metadata. Be concise.

## YAML Frontmatter Rules

- All config files use YAML frontmatter (between `---` delimiters)
- `name` field: lowercase letters, numbers, hyphens only. Max 64 chars. No XML tags. No reserved words ("anthropic", "claude")
- `description` field: Third person. Max 1024 chars. No XML tags. Include both what AND when
- Descriptions are injected into the system prompt — write them for that context

## Naming Conventions

- Kebab-case: `my-skill-name`, `code-reviewer`, `db-integration`
- Gerund form preferred for skills: `processing-pdfs`, `analyzing-data`
- Agent names: 3-50 characters, no underscores
- Plugin names: unique across installed plugins

## Writing Style

- **Imperative/infinitive**: "Extract text" not "You should extract text"
- **Third person descriptions**: "Processes PDFs" not "I can process" or "You can process"
- **Commands are for Claude**: Write as directives TO Claude, not messages TO the user
- **Assume Claude knows basics**: Only teach domain-specific knowledge

## Progressive Disclosure Patterns

### Pattern 1: SKILL.md with references
```
skill/
├── SKILL.md         # ~1,500-2,000 words, covers core workflow
└── references/
    └── detailed.md  # Loaded when Claude needs depth
```

### Pattern 2: Domain-organized references
```
skill/
├── SKILL.md              # Navigation hub
└── references/
    ├── domain-a.md
    └── domain-b.md
```

### Pattern 3: Bundled scripts
```
skill/
├── SKILL.md
└── scripts/
    └── automate.py       # Executed via bash, not loaded into context
```

## Body Writing Conventions

Official rules for writing SKILL.md body content.

### 1. Be Concise
Claude is already smart. Only add context it doesn't have. Challenge every paragraph. A good rule of thumb: the concise version is about 50 tokens, the verbose version wastes ~100 tokens explaining what Claude already knows.

### 2. Imperative Voice
Write instructions as commands: "Extract text" not "You should extract text". This applies to skills, commands, and agent system prompts.

### 3. Three Degrees of Freedom
Match specificity to the task's fragility:
- **High** (text): multiple approaches valid → general steps
- **Medium** (pseudocode): preferred pattern exists → templates with parameters
- **Low** (exact): operations fragile → exact commands, no deviation

### 4. Body Structure
- Start with **Quick Start** (the most common task)
- Follow with **Core Workflows** (step-by-step procedures)
- End with **Guidelines** (domain-specific rules)
- Keep under **500 lines**; split into `references/` when approaching limit

### 5. References Must Be Flat
All reference files linked directly from SKILL.md. Never nest references (SKILL.md → ref.md → detail.md means Claude may partial-read ref.md).

### 6. Workflow Checklists
For multi-step processes, provide a checklist Claude can copy and check off:
```
Task Progress:
- [ ] Step 1: ...
- [ ] Step 2: ...
```
Include validation loops: act → validate → fix → proceed.

### 7. Examples as Input/Output Pairs
Provide concrete examples like regular prompting. Show both input and expected output.

### 8. Consistent Terminology
Choose one term and use it throughout: always "API endpoint", not mixing "endpoint/URL/route/path".

## Anti-Patterns to Avoid

| Anti-pattern | Fix |
|-------------|-----|
| Explaining programming basics | Delete — Claude already knows |
| Time-sensitive info (dates, versions) | Use `<details>` legacy section |
| Multiple options without a default | Pick one default |
| Deeply nested references | Link everything from SKILL.md |
| Verbose introductions | Start with the task |
| "You should", "I recommend" | Use imperative |
| Writing TO the user (commands) | Write as instructions FOR Claude |

## Validation Checklist

- [ ] Name is kebab-case
- [ ] Description is third person
- [ ] Description includes trigger conditions
- [ ] No reserved words in name
- [ ] Body is under 500 lines (SKILL.md)
- [ ] Body uses imperative voice (not "you should")
- [ ] Body doesn't explain programming basics
- [ ] References are flat (one level deep from SKILL.md)
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Scripts are executable
- [ ] Portability: uses `${CLAUDE_PLUGIN_ROOT}` in plugins
