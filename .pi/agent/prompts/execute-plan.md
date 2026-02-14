---
description: Execute a plan by working through its todos in order
---
Execute the plan `.pi/plans/$1` (or `$PI_PLAN_PATH/$1` if set).

## Execution Workflow

1. **Read the plan** file to understand the full goal, approach, and context.
2. **Locate todos** from the plan's `## Todos` section — use the TODO IDs listed there to `get` each one.
3. **Work through each open todo** in the order listed in the plan:
   - **Claim** the todo before starting work
   - Implement the task fully — write code, run tests, verify
   - **Close** the todo when done (update status to "done")
   - Move on to the next open todo
4. After all todos are completed, give a brief summary of what was done.

## Rules

- Follow the plan's approach. If you encounter a conflict or blocker, stop and explain before deviating.
- If a todo is ambiguous, ask me to clarify before proceeding — do not guess.
- Run relevant tests or checks after each step when possible.
- Do not skip todos or change their order unless a dependency requires it.
