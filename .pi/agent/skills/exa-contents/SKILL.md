---
name: exa-contents
description: Fetch text content from URLs. Use when you have specific URLs and need their full page content.
---

# Exa Contents

Fetch text from known URLs. **Default: compact verbosity** (filters navigation/footer noise).

> **Token tip:** The `/contents` endpoint only supports full text. For token-efficient highlights or summary, use `exa-search --highlights` or `exa-search --summary` instead.

## Setup

Set `EXA_API_KEY` environment variable. Get key from [Exa Dashboard](https://dashboard.exa.ai/).

## Verbosity Comparison

| Mode | Tokens | Description |
|------|--------|-------------|
| `--compact` (default) | least | Main content only, filters noise |
| `--standard` | more | More detail |
| `--full` | most | Complete content, all sections |

> **Note:** `--verbosity` and `--exclude-sections` only take effect when Exa performs a live crawl. For cached pages (most common), these options are silently ignored and full text is returned regardless.

## Usage

```bash
# Default: compact verbosity
./contents.sh "https://example.com"
./contents.sh "https://url1.com" "https://url2.com"

# Control verbosity
./contents.sh --standard "https://example.com"
./contents.sh --full "https://example.com"

# Exclude noisy sections (auto-enables livecrawl)
./contents.sh --exclude-sections "navigation,footer,sidebar" "https://example.com"

# Force live crawl
./contents.sh --livecrawl "https://example.com"
```

## Options

| Flag | Description |
|------|-------------|
| `--compact` | Compact verbosity (default) |
| `--standard` | Standard verbosity |
| `--full` | Full verbosity |
| `--verbosity LEVEL` | `compact`/`standard`/`full` |
| `--exclude-sections S` | Comma-separated: `navigation,footer,sidebar,banner,header,metadata` |
| `--livecrawl` | Force live crawl instead of cache |

For more details, see [Exa Docs](https://docs.exa.ai/reference/contents-retrieval).
