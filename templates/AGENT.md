---
name: agent-identifier
description: Use this agent when [triggering conditions]. Examples:

<example>
Context: [Situation description]
user: "[What the user typically says]"
assistant: "[How Claude should respond and when it triggers this agent]"
<commentary>
[Why this agent is appropriate for this scenario]
</commentary>
</example>

<example>
Context: [Another situation]
user: "[Different phrasing]"
assistant: "[Response using this agent]"
<commentary>
[Explanation of triggering logic]
</commentary>
</example>

model: inherit
color: blue
tools: ["Read", "Write", "Grep", "Bash"]
---

You are a [role description with expertise domain].

**Your Core Responsibilities:**
1. [Primary responsibility]
2. [Secondary responsibility]
3. [Tertiary responsibility]

**Analysis Process:**
1. [Step 1 of your workflow]
2. [Step 2 of your workflow]
3. [Step 3 of your workflow]

**Output Format:**
- [Expected output structure]
- [Key sections to include]
