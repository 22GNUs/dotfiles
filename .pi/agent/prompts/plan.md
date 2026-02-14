---
description: Collaboratively plan a task before implementation
---
I want to plan the following task before implementing anything: $@

## Planning Workflow

Follow these phases strictly. **Do NOT modify any source code during planning.**

### Phase 1: Explore & Understand

Read relevant code, configs, and docs to build a thorough understanding of the current state.
Read full files when needed — don't rely on snippets. List the key files and components involved.

### Phase 2: Clarify & Design

This is a **collaborative** phase. Do NOT write any plan file yet.

**Proactively ask me questions** about anything unclear — requirements, constraints, preferences,
edge cases, trade-offs. Present your questions naturally in your response so I can use `/answer`
to respond efficiently. If you have many questions, group them by topic.

After I answer, continue the conversation:
- Share your understanding of the problem
- Propose an approach with clear reasoning
- Call out risks, alternatives, and open questions
- If new uncertainties arise from my answers, **ask follow-up questions** — don't guess

**Keep iterating** until I explicitly confirm the plan (e.g., "looks good", "approved", "go ahead").
Do not assume silence or partial feedback means approval. If my feedback is ambiguous, ask to clarify.

### Phase 3: Persist

Only after I explicitly confirm, persist in this **exact order**:

1. **Create todos first** via the `todo` tool for each implementation step:
   - Keep tasks atomic and actionable
   - Tag each todo with the plan slug (e.g., `["oauth-refactor"]`) for traceability
   - Order them logically (dependencies first)
   - **Write a detailed body** for each todo — include specific file paths, function names,
     expected behavior, and any relevant code snippets or patterns. The executing agent
     may have no context beyond this todo and the plan file.
   - **Record the returned TODO IDs** — you need them for the plan file

2. **Then write the plan** to `.pi/plans/<date>-<slug>.md` (or `$PI_PLAN_PATH/<date>-<slug>.md` if set):
   - `<date>` is today in `YYYY-MM-DD` format
   - `<slug>` is a short kebab-case summary derived from the task (e.g., `oauth-refactor`)
   - Create the plans directory if needed
   - **Include the TODO IDs** from step 1 in the Todos section
   - **Be as detailed as possible** — the plan may be executed in a completely different session
     by an agent with zero prior context. Include enough background, reasoning, and implementation
     details so that agent can execute without guessing. Reference specific file paths, function
     names, data structures, and code patterns discovered during Phase 1.
   - Use this structure:

   ```markdown
   # <Title>

   **Status**: confirmed
   **Date**: YYYY-MM-DD
   **Tags**: <slug>

   ## Goal
   What we're trying to achieve and why.

   ## Context
   Current state, relevant background, key constraints.

   ## Approach
   Numbered steps of the implementation plan.

   ## Key Files
   Files to be created or modified, with brief notes.

   ## Todos
   - TODO-<hex> <title>
   - TODO-<hex> <title>
   - ...

   ## Risks & Notes
   Things to watch out for, open questions, alternatives considered.
   ```

After persisting, summarize: plan file path, and the list of created todo IDs with titles.
