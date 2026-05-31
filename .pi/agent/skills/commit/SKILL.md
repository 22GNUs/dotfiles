---
name: commit
description: "Read this skill before making git commits"
---

Create 1-3 git commits for the current changes. Merge related changes together—do NOT split finely.
Use concise Conventional Commits-style subjects.

## Grouping strategy

- Prefer 1 commit. Only split if changes are clearly unrelated.
- Same topic → same commit. Do NOT over-split.

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

## Rules

- Minimal tool calls. One `git diff --stat` + one `git diff` is enough.
- Do NOT ask the user questions. Decide and commit.
- Do NOT run `git log` unless scope is truly unclear.
- Commit as fast as possible.

## Steps

1. Run `git diff --stat` and `git diff` together in one bash call (use `&&` or `;`).
2. If argument-specified files exist, add `-- <files>` to the diff commands.
3. Infer scope from changed files/paths. Infer type from change nature (new = feat, fix = fix, rest = chore/refactor).
4. `git add -A` (or `git add <files>`) then `git commit -m "<subject>"` in ONE bash call (chain with `&&`).
5. If changes are clearly 2 unrelated topics, do 2 commits at most. Otherwise 1 commit.
