#!/bin/bash
# quick_search.sh - Quick Google Search using Gemini CLI (headless mode)
# Model: gemini-2.5-flash-lite (fast, efficient)
# Usage: ./quick_search.sh "search query"

set -e

QUERY="${1:-}"

if [[ -z "$QUERY" ]]; then
  echo "Error: Please provide a search query"
  echo "Usage: $0 \"your search query\""
  exit 1
fi

# Performance optimizations:
# - Use flash model for speed
# - Headless mode already enabled via -p
# - JSON output parsing is fast
# - Suppress unnecessary stderr output

gemini -m gemini-2.5-flash-lite -p "You MUST use Google Search. Do NOT rely on training data.

Query: ${QUERY}

REQUIREMENTS:
1. Search the web and visit pages to verify facts
2. Cross-reference multiple sources
3. Distinguish facts from opinions
4. Assess confidence level based on source quality and consensus
5. Be concise - this output is for an AI agent

OUTPUT FORMAT (strict):
ANSWER: [1-2 sentence direct answer]

FACTS:
- [statement] [FACT|CONFIDENCE] (source: [url])
- [statement] [OPINION|CONFIDENCE] (source: [url])

CONFIDENCE levels: HIGH (verified by multiple authoritative sources), MEDIUM (single authoritative source or multiple less authoritative), LOW (unverified or conflicting sources)

FACT vs OPINION:
- FACT: Objectively verifiable information (dates, numbers, definitions, technical specs)
- OPINION: Subjective assessments, interpretations, recommendations, predictions

Keep response under 200 words. No introductions or explanations." --output-format json 2>/dev/null | jq -r '.response // .error.message // "No response received"'
