---
description: Analyze git diff and generate Conventional Commits with emojis
---

Analyze `git status` and `git diff`, split changes into logical units, and generate commit messages following Conventional Commits.

Then **EXECUTE** the commit commands directly using bash tool, do not just output them.

## Commit Format

```
<type>(<scope>): <emoji> <subject>

[optional body]

[optional footer(s)]
```

## Types & Emojis

| Type | Emoji | Description |
|------|-------|-------------|
| feat | ✨ | New features |
| fix | 🐛 | Bug fixes |
| docs | 📝 | Documentation |
| style | 💄 | Code style/formatting |
| refactor | ♻️ | Code refactoring |
| perf | ⚡ | Performance improvements |
| test | ✅ | Adding/fixing tests |
| build | 📦 | Build system/dependencies |
| ci | 👷 | CI configuration |
| chore | 🔧 | Other changes |
| revert | ⏪ | Reverting commits |

## Guidelines

- **Language**: Use Simplified Chinese for subject, English for type
- **Subject**: Imperative mood, concise (e.g., "add login" not "added login")
- **Scope**: Module/component affected (e.g., `auth`, `ui`, `api`)
- **Atomic**: Split unrelated changes into separate commits

## Splitting Rules

**Do NOT split too granularly**. Only split when:

1. **Different functional modules** - e.g., auth module changes vs. payment module changes
2. **Different change types** - e.g., new feature vs. bug fix vs. refactoring
3. **Mixed logical units** - e.g., feature implementation + dependency upgrade

**Can be combined** when:
- Multiple files for the same feature (e.g., `add user login`, includes `auth.ts`, `login.tsx`, `api.ts`)
- Feature + its documentation
- Related files in the same module

## Breaking Changes

Append `!` after type/scope: `feat(api)!: ✨ 重构认证接口`

Or add in footer:
```
BREAKING CHANGE: description
```

## Example

```
feat(user): ✨ 新增头像上传功能

支持 jpg/png 格式，最大 5MB
使用 OSS 存储

Closes #123
```

## Output Format

Generate commit messages, then execute commit commands using bash tool:

```bash
git add <files>
git commit -m "<type>(<scope>): <emoji> <subject>"
```

Or for multi-line commits:

```bash
git add <files>
git commit -m "<type>(<scope>): <emoji> <subject>

<body line 1>
<body line 2>

Closes #123"
```
