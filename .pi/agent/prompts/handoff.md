---
description: Compact current conversation into handoff doc for next agent
argument-hint: "[next-session-focus]"
---

Write a handoff document summarizing current conversation so fresh agent can continue work.

Arguments from user, if any: `$ARGUMENTS`

## Requirements

1. Create destination path with cross-platform `mktemp` usage:

   ```bash
   mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX.md"
   ```

   This yields path like `/tmp/handoff-a1B2c3.md` on Linux or `$TMPDIR/handoff-a1B2c3.md` on macOS.

2. Read generated file path before writing to it.

3. Write handoff doc to that path.

4. If arguments are present, treat them as next-session focus and tailor handoff accordingly.

5. Suggest skills next session should use, if any.

6. Do not duplicate content already captured in other artifacts:
   - PRDs
   - plans
   - ADRs
   - issues
   - commits
   - diffs

   Reference existing artifacts by path or URL instead.

## Handoff doc shape

Use concise Markdown:

```markdown
# Handoff

## Next-session focus
<Use arguments if provided; otherwise infer likely next step.>

## Current state
<Brief status.>

## Decisions / constraints
<Key decisions, constraints, user prefs.>

## Work completed
<Only work not already captured elsewhere; reference artifacts instead of duplicating.>

## Relevant artifacts
- <path or URL>: <why relevant>

## Suggested skills
- <skill name>: <why>, or "None".

## Next steps
1. <action>
2. <action>

## Risks / open questions
- <item>
```

After saving, report only:

```text
Handoff saved: <path>
```
