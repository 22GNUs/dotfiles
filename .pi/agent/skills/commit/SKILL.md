---
name: commit
description: "Read this skill before making git commits"
---

Create 1-3 git commits for the current changes. Merge related changes together—do NOT split finely.
Use concise Conventional Commits-style subjects.

## Grouping strategy

- Group related file changes into ONE commit. Same topic → same commit.
- Result MUST be 1-3 commits total. If changes are all one theme, use 1 commit.
- Split into separate commits ONLY when changes address clearly unrelated concerns.
- Examples of good grouping:
  - All config tweaks → 1 commit (`chore(config): update dotfiles`)
  - Feature + unrelated bugfix → 2 commits (`feat(ui): ...` + `fix(api): ...`)

## Format

`<type>(<scope>): <summary>`

- `type` REQUIRED. `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `perf`, `style`.
- `scope` OPTIONAL. Short noun for affected area (e.g., `api`, `ui`, `config`).
- `summary` REQUIRED. Short, imperative, <= 72 chars, no trailing period.

## Notes

- Body is OPTIONAL. If needed, add a blank line after the subject and write short paragraphs.
- Do NOT include breaking-change markers or footers.
- Do NOT add sign-offs (no `Signed-off-by`).
- Only commit; do NOT push.
- If it is unclear whether a file should be included, ask the user which files to commit.
- Treat any caller-provided arguments as additional commit guidance. Common patterns:
  - Freeform instructions should influence scope, summary, and body.
  - File paths or globs should limit which files to commit. If files are specified, only stage/commit those unless the user explicitly asks otherwise.
  - If arguments combine files and instructions, honor both.

## Steps

1. Infer from the prompt if the user provided specific file paths/globs and/or additional instructions.
2. Review `git status` and `git diff` to understand the current changes (limit to argument-specified files if provided).
3. Run `git log -n 30 --pretty=format:%s` to see recent commit style and scopes.
4. Group changes into 1-3 logical commits. If ambiguous, briefly show your proposed grouping and ask for confirmation.
5. For each commit: stage the intended files, then run `git commit -m "<subject>"` (and `-m "<body>"` if needed).
