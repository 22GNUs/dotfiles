---
description: Read handoff doc, understand context, then wait for user instruction
argument-hint: "<handoff-file>"
---

Read handoff document from: `$1`

## Requirements

1. Verify argument is present. If missing, ask user for handoff file path and stop.

2. Read file at `$1`.

3. Understand context, constraints, artifacts, suggested skills, next steps, risks, and open questions.

4. Do not start implementation, editing, research, commands, or delegated work yet.

5. If handoff references other artifacts that are necessary to understand context, read only enough to understand current state. Do not modify anything.

6. After reading, respond with concise acknowledgement and wait for user instruction.

## Response shape

```text
Context loaded from: <path>

Understood:
- <key point>
- <key point>
- <key point>

Waiting for next instruction.
```
