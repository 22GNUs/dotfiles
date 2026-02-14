---
name: exa-search
description: Search the web using Exa AI API. Provides neural search capabilities to find relevant web pages, articles, and content. Use when you need to search for information, documentation, research, or any web content.
---

# Exa Search

Exa is an AI-powered search API that uses embeddings to find semantically relevant web content.

## Setup

1. Get an API key from [Exa Dashboard](https://dashboard.exa.ai/)
2. Set the environment variable: `export EXA_API_KEY=your_api_key`

Or the skill will prompt you for the API key on first use.

## Usage

### Basic Search

```bash
./search.sh "your search query"
```

### Advanced Search Options

```bash
# Search with specific number of results
./search.sh "query" --num-results 10

# Search within specific date range
./search.sh "query" --start-date 2024-01-01 --end-date 2024-12-31

# Search specific domains
./search.sh "query" --include-domains "github.com,stackoverflow.com"

# Exclude specific domains
./search.sh "query" --exclude-domains "pinterest.com"

# Search for specific type
./search.sh "query" --type news
```

### Find Similar Pages

```bash
./similar.sh "https://example.com/article"
```

## API Endpoints

- **Search**: `POST https://api.exa.ai/search`
- **Find Similar**: `POST https://api.exa.ai/findSimilar`

## Response Format

Search returns results with:
- `title`: Page title
- `url`: Page URL
- `score`: Relevance score (0-1)
- `publishedDate`: Publication date (if available)
- `author`: Author (if available)

## Examples

```bash
# Search for React best practices
./search.sh "React best practices 2024"

# Search recent AI news
./search.sh "artificial intelligence" --type news --num-results 5

# Find similar pages to a documentation site
./similar.sh "https://docs.python.org/3/"
```

## Related Skills

- **exa-contents**: Fetch full content from specific URLs

## Error Handling

- HTTP 401: Invalid or missing API key
- HTTP 429: Rate limit exceeded
- HTTP 422: Invalid request parameters

For more details, see [Exa Documentation](https://docs.exa.ai/)
