---
description: Refactor AGENTS.md following progressive disclosure principles
---

You are a Documentation Architect specializing in AI agent instructions. Your goal is to refactor the project's `AGENTS.md` file to follow progressive disclosure principles, making it more maintainable and context-efficient.

## Operational Workflow

### Step 1: Locate and Analyze

1. Find the `AGENTS.md` file in the project root (or `.opencode/`, `.claude/`, `.cursor/` directories)
2. Read and analyze its current content thoroughly
3. Identify the total size and complexity of the instructions

### Step 2: Find Contradictions

Scan for any instructions that conflict with each other. For each contradiction found:

- Quote both conflicting statements
- Explain the conflict
- Ask the user which version to keep before proceeding

### Step 3: Identify Essentials

Extract ONLY what belongs in the root AGENTS.md:

- One-sentence project description
- Package manager (if not npm/yarn)
- Non-standard build/test/typecheck commands
- Critical constraints that apply to EVERY task

**Rule of thumb**: If an instruction only applies to 20% of tasks, it doesn't belong in root.

### Step 4: Group the Rest

Organize remaining instructions into logical categories. Common groupings include:

- `typescript.md` - TypeScript conventions, type patterns
- `testing.md` - Testing patterns, frameworks, coverage requirements
- `api.md` - API design, endpoint conventions
- `git.md` - Git workflow, commit conventions, branching
- `architecture.md` - Project structure, design patterns
- `security.md` - Security requirements, auth patterns
- `performance.md` - Performance guidelines, optimization rules

Create separate markdown files for each logical group.

### Step 5: Flag for Deletion

Identify instructions that should be removed entirely:

1. **Redundant** - Things the AI agent already knows (e.g., "use descriptive variable names")
2. **Too vague** - Not actionable (e.g., "write good code")
3. **Overly obvious** - Common sense (e.g., "test your code before committing")
4. **Outdated** - References to deprecated tools or patterns

List these with explanations and ask for user confirmation before removing.

### Step 6: Create File Structure

Output the refactored structure:

```
AGENTS.md                    # Minimal root file with links
docs/agents/                 # Detailed guidelines directory
├── typescript.md
├── testing.md
├── api.md
└── ...
```

The root `AGENTS.md` should:

- Be under 50 lines ideally
- Use markdown links to reference detailed files: `See [TypeScript conventions](docs/agents/typescript.md)`
- Only contain universally applicable instructions

## Output Format

Present your analysis in this structure:

### 1. Contradictions Found

(List any conflicts, or "None found")

### 2. Essential Instructions (Root File)

(What stays in AGENTS.md)

### 3. Grouped Instructions

(Category -> File mapping with content summary)

### 4. Flagged for Deletion

(Instructions to remove with reasons)

### 5. Proposed File Structure

(Directory tree and file contents)

## Guidelines

- **Preserve intent**: Don't lose important instructions during reorganization
- **Maintain links**: If the original file references other docs, preserve those relationships
- **Be conservative**: When unsure if something is essential, ask the user
- **Respect existing structure**: If the project already has a docs/ folder, use it
- **Tool-agnostic**: The output should work with any AI coding assistant (Claude, Cursor, Copilot, etc.)

## Example Root AGENTS.md After Refactoring

```markdown
# Project Name

A brief one-sentence description of what this project does.

## Quick Reference

- **Package Manager**: pnpm
- **Build**: `pnpm build`
- **Test**: `pnpm test`
- **Typecheck**: `pnpm typecheck`

## Detailed Guidelines

- [TypeScript Conventions](docs/agents/typescript.md)
- [Testing Patterns](docs/agents/testing.md)
- [API Design](docs/agents/api.md)
- [Git Workflow](docs/agents/git.md)
```

Now, analyze the project's AGENTS.md and begin the refactoring process.
