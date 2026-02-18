---
description: Refactor AGENTS.md with progressive disclosure and modular docs
---
Refactor this project's `AGENTS.md` using progressive disclosure principles so it is concise, maintainable, and context-efficient.

## Workflow

Follow these steps in order.

### 1) Locate and analyze

1. Find `AGENTS.md` in the project root and any assistant-specific locations if present (for example: `.pi/agent/`, `.opencode/`, `.claude/`, `.cursor/`)
2. Read the relevant files thoroughly
3. Assess instruction size, overlap, and complexity

### 2) Detect contradictions

Identify conflicting instructions. For each conflict:

- Quote both conflicting statements
- Explain why they conflict
- Ask the user which version to keep before proceeding

### 3) Keep only root essentials

Extract only instructions that should stay in root `AGENTS.md`:

- One-sentence project description
- Package manager (only if non-default for the ecosystem)
- Non-standard build/test/typecheck commands
- Constraints that apply to every task

Rule of thumb: if guidance only applies to a minority of tasks, move it out of root.

### 4) Group non-essential guidance

Propose logical split files, for example:

- `docs/agents/typescript.md`
- `docs/agents/testing.md`
- `docs/agents/api.md`
- `docs/agents/git.md`
- `docs/agents/architecture.md`
- `docs/agents/security.md`
- `docs/agents/performance.md`

Adjust categories to match the actual project.

### 5) Flag deletion candidates

List instructions that should be removed, with reasons:

1. Redundant (model already knows)
2. Vague (not actionable)
3. Obvious (adds no signal)
4. Outdated (deprecated tools/patterns)

Ask for user confirmation before deleting.

### 6) Propose final structure

Provide:

- A minimal root `AGENTS.md` (ideally under 50 lines)
- Linked detailed docs using markdown links
- A clear directory tree of new guidance files

## Output format

Use this structure in your response:

### 1. Contradictions Found

### 2. Essential Instructions (Root File)

### 3. Grouped Instructions

### 4. Flagged for Deletion

### 5. Proposed File Structure

## Guardrails

- Preserve intent and important constraints
- Keep existing cross-file references when useful
- Be conservative: ask when unsure
- Reuse existing `docs/` structure if present
- Keep output tool-agnostic so it works across coding assistants

Start by locating and analyzing the current AGENTS guidance files.
