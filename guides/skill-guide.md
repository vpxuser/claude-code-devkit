# SKILL.md Generation Guide

Rules for generating SKILL.md files that follow official Anthropic design.

## Structure

```
skill-name/
├── SKILL.md                  # Required
├── references/               # Optional: detailed docs
│   └── topic.md
├── scripts/                  # Optional: executable code
│   └── tool.py
└── examples/                 # Optional: usage examples
    └── example.md
```

## Frontmatter

```yaml
---
name: skill-name
description: Third-person description with trigger conditions
---
```

### Name Rules
- Max 64 characters
- Lowercase letters, numbers, hyphens
- No XML tags (`<`, `>`)
- No reserved words: "anthropic", "claude"
- Gerund form recommended: `processing-pdfs`

### Description Rules
- Max 1024 characters
- Third person: "Processes PDF files..."
- Include both capability AND trigger context
- Be specific with terms Claude will encounter
- "Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."

## Body Writing Rules

Official Anthropic conventions for writing SKILL.md body content.

### Rule 1: Be Concise — Claude Is Already Smart

Only add context Claude doesn't have. Challenge each paragraph:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Good (concise, ~50 tokens):**
````markdown
## Extract PDF text
Use pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**Bad (verbose, ~150 tokens):**
```markdown
## Extract PDF text
PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing...
```

### Rule 2: Use Imperative / Infinitive Form

Write instructions as commands TO Claude:

| Correct | Incorrect |
|---------|-----------|
| "Extract text with pdfplumber" | "You should extract text using pdfplumber" |
| "Run the validation script" | "The user can then run the validation script" |
| "Use pdfplumber for extraction" | "I recommend using pdfplumber for extraction" |

### Rule 3: Three Degrees of Freedom

| Degree | When | Format |
|--------|------|--------|
| **High** (text) | Multiple approaches valid | General steps, trust Claude's judgment |
| **Medium** (pseudocode) | Preferred pattern exists | Templates with parameters |
| **Low** (exact) | Fragile ops, must be exact | Exact commands, no deviation |

**High freedom** example:
```markdown
## Code review
1. Analyze code structure and organization
2. Check for potential bugs or edge cases
```

**Medium freedom** example:
````markdown
## Generate report
Use this template:
```python
def generate_report(data, format="md", include_charts=True):
    ...
```
````

**Low freedom** example:
````markdown
## Database migration
Run exactly:
```bash
python scripts/migrate.py --verify --backup
```
Do not modify or add flags.
````

### Rule 4: Body Structure

**Section ordering:**
```
# Skill Name
## Quick Start          ← Most common task FIRST
## Core Workflows       ← Step-by-step procedures
## Advanced Usage       ← References for depth
## Guidelines           ← Domain-specific rules
```

**Length:** Keep under 500 lines. Split into `references/` when approaching limit.

**References flat:** ALL reference files linked directly from SKILL.md. Never nest:
- Correct: SKILL.md → `See [advanced.md](references/advanced.md)`
- Wrong: SKILL.md → advanced.md → details.md (Claude may partial-read the middle file)

**Reference files** should have a table of contents so Claude can jump to sections.

### Rule 5: Workflow with Checklists

Break complex ops into clear sequential steps. Provide a checklist Claude can copy and track:

```markdown
## PDF processing workflow
Copy this checklist and track progress:
```
Task Progress:
- [ ] Step 1: Analyze form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill form (run fill_form.py)
```
**Step 1: Analyze form** — Run `python scripts/analyze_form.py input.pdf`
...
```

Include **validation loops**: act → validate → fix → proceed.

### Rule 6: Examples as Input/Output Pairs

````markdown
## Commit message format
**Example 1:** Added user auth
```
feat(auth): implement JWT auth
- Add login endpoint
```
**Example 2:** Fixed date bug
```
fix(ui): correct date formatting
```
````

### Rule 7: Output Templates

For structured output, provide a template:
```markdown
## Report format
```markdown
# [Title]
## Executive summary
[Overview]
## Key findings
- Finding
## Recommendations
1. Action item
```
```

### Rule 8: Consistent Terminology

Choose one term and use it throughout the entire skill.

| Good | Bad |
|------|-----|
| Always "API endpoint" | Mixes "endpoint", "URL", "route", "path" |
| Always "field" | Mixes "field", "property", "attribute" |

### Rule 9: Anti-Patterns to Avoid

| Anti-pattern | Why | Fix |
|-------------|-----|-----|
| Explaining programming basics | Claude already knows | Delete |
| Time-sensitive info | Becomes outdated | Use `<details>` legacy section |
| Multiple options without default | Confusing | Pick one default |
| References nested >1 level | Partial reads | Link everything from SKILL.md |
| Verbose introductions | Wastes context | Start with the task |
| Writing TO the user | Not instructions FOR Claude | Rewrite as directives |

## Examples

### Good description
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

### Bad description
```yaml
description: Helps with documents
```

### Good body (concise)
````markdown
## Extract PDF text
Use pdfplumber for text extraction:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

### Bad body (verbose)
```markdown
PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available...
```
