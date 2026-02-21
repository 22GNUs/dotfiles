---
name: exa-search
description: Search the web. Use when you need to find information, documentation, or research content online.
---

# Exa Search

Neural search via Exa API. **Default: use `--highlights`** to get search results with key excerpts in a single request.

## Setup

Set `EXA_API_KEY` environment variable. Get key from [Exa Dashboard](https://dashboard.exa.ai/).

## Content Strategy

| Need | Approach |
|------|----------|
| Search + quick overview | `--highlights` — **default choice**, one request, least tokens |
| Search + conclusion only | `--summary` |
| Links only (no content) | plain search — only when URLs are needed for other tools |
| Search + full content | `--text` — expensive, use sparingly |

## Usage

```bash
# Basic search
./search.sh "your query"
./search.sh "query" --num-results 10

# With inline highlights (recommended — saves a separate contents call)
./search.sh "React hooks best practices" --highlights
./search.sh "Python asyncio" --highlights --max-chars 1500

# With inline summary
./search.sh "Rust ownership" --summary
./search.sh "Docker networking" --summary --summary-query "how to configure container communication"

# With full text (use sparingly)
./search.sh "query" --text
./search.sh "query" --text --verbosity standard

# Filters
./search.sh "query" --start-date 2024-01-01 --end-date 2024-12-31
./search.sh "query" --include-domains "github.com,stackoverflow.com"
./search.sh "query" --exclude-domains "pinterest.com"
./search.sh "query" --type news

# Find similar pages
./similar.sh "https://example.com/article"
```

## Options

| Flag | Description |
|------|-------------|
| `--num-results N` | Number of results (default: 5) |
| `--type TYPE` | `news`, `blog`, etc. |
| `--start-date DATE` | Filter by date (YYYY-MM-DD) |
| `--end-date DATE` | Filter by date (YYYY-MM-DD) |
| `--include-domains` | Comma-separated domains to include |
| `--exclude-domains` | Comma-separated domains to exclude |
| `--highlights` | Inline key excerpts per result |
| `--max-chars N` | Max chars per highlight (default: 2000) |
| `--summary` | Inline AI summary per result |
| `--summary-query STR` | Custom query for summary |
| `--text` | Inline full text, compact verbosity |
| `--verbosity LEVEL` | `compact`/`standard`/`full` (with `--text`) |

For more details, see [Exa Docs](https://docs.exa.ai/).
