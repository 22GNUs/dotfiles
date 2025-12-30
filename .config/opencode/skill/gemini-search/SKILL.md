---
name: gemini-search
description: Use Gemini CLI for Google Search and deep web research. Triggers on phrases like "search", "look up", "research", "latest info", "find out", "google", or when current/real-time information is needed.
license: MIT
compatibility: opencode
---

# Gemini Search Skill

Leverage Gemini CLI to perform Google Search with optimized modes for different use cases.

## Capabilities

1. **Quick Search** - Uses `gemini-3-flash-preview` for fast Google Search queries
2. **Deep Research** - Uses `gemini-3-pro-preview` for comprehensive analysis with extended thinking

Both scripts support **parallel execution** for multiple concurrent searches.

## Usage

### Quick Search (for simple queries)

Execute with Bash tool:

```bash
~/.config/opencode/skill/gemini-search/scripts/quick_search.sh "your search query"
```

Best for:

- Looking up API documentation
- Finding quick factual information
- Searching for error message solutions
- Verifying version numbers or dates

### Deep Research (for complex topics)

Execute with Bash tool:

```bash
~/.config/opencode/skill/gemini-search/scripts/deep_research.sh "your research question"
```

Best for:

- Technical architecture research
- Multi-perspective problem analysis
- Topics requiring synthesis from multiple sources
- Comprehensive technology comparisons

### Parallel Execution

Both scripts can be run concurrently for multiple queries:

```bash
# Run multiple quick searches in parallel
quick_search.sh "query1" &
quick_search.sh "query2" &
quick_search.sh "query3" &
wait

# Mix quick and deep searches
quick_search.sh "what is rust" &
deep_research.sh "rust vs go performance comparison" &
wait
```

When running multiple searches in parallel, all queries execute simultaneously and complete in the time of the slowest query.

## Output Format

Results include structured information with confidence indicators:

**Quick Search Output:**

```
ANSWER: [Direct answer]

FACTS:
- [statement] [FACT|CONFIDENCE] (source: [url])
- [statement] [OPINION|CONFIDENCE] (source: [url])
```

**Deep Research Output:**

```
SUMMARY: [Overview]

KEY_FINDINGS:
- [statement] [FACT|CONFIDENCE] (source: [url])
- [statement] [OPINION|CONFIDENCE] (source: [url])

ANALYSIS: [Deeper insights]

SOURCES:
- [url]: [description]
```

**Confidence Levels:**

- `HIGH`: Verified by multiple authoritative sources
- `MEDIUM`: Single authoritative source or multiple less authoritative
- `LOW`: Unverified or conflicting sources

**Fact vs Opinion:**

- `FACT`: Objectively verifiable (dates, numbers, definitions, technical specs)
- `OPINION`: Subjective assessments, interpretations, recommendations

## Performance

- Quick search: ~10-30s (optimized for speed)
- Deep research: ~30-60s (optimized for comprehensiveness)
- Parallel execution: Same as single search (runs concurrently)

**Performance optimizations:**

- Uses `gemini-3-flash-preview` for quick searches (fastest model)
- Headless mode with JSON output for minimal overhead
- Compact prompts to reduce token usage
- Suppressed debug logs for clean output

## Requirements

- Gemini CLI installed (`npm install -g @anthropic-ai/gemini-cli`)
- Logged into Gemini CLI (run `gemini` for first-time login)

## Notes

- Scripts already exist, do not create them
- All searches use headless mode for clean, parseable output
- Results are optimized for AI agent consumption
- Deep research mode uses extended thinking for better analysis
- Both scripts are stateless and safe for concurrent execution
