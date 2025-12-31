#!/bin/bash
# deep_research.sh - Deep web research using Gemini CLI (headless mode)
# Model: gemini-3-flash-preview (extended thinking, comprehensive analysis)
# Usage: ./deep_research.sh "research question"

set -e

QUERY="${1:-}"

if [[ -z "$QUERY" ]]; then
  echo "Error: Please provide a research question"
  echo "Usage: $0 \"your research question\""
  exit 1
fi

gemini -m gemini-3-flash-preview -p "You MUST conduct thorough web research. Do NOT rely on training data.

Topic: ${QUERY}

REQUIREMENTS:
1. Perform extensive Google Search
2. Visit and read multiple authoritative web pages
3. Cross-reference facts across different sources
4. Distinguish facts from opinions/interpretations
5. Assess confidence level based on source consensus and authority
6. This output is for an AI agent - be structured and concise

OUTPUT FORMAT (strict):

SUMMARY: [2-3 sentence overview]

KEY_FINDINGS:
- [statement] [FACT|CONFIDENCE] (source: [url])
- [statement] [OPINION|CONFIDENCE] (source: [url])
- [statement] [FACT|CONFIDENCE] (source: [url])
- [statement] [OPINION|CONFIDENCE] (source: [url])
- [statement] [FACT|CONFIDENCE] (source: [url])

CONFIDENCE levels: 
- HIGH: verified by multiple authoritative sources
- MEDIUM: single authoritative source or multiple less authoritative
- LOW: unverified or conflicting sources

FACT vs OPINION:
- FACT: objectively verifiable (dates, numbers, definitions, technical specs)
- OPINION: subjective assessments, interpretations, recommendations

ANALYSIS: [3-5 sentences of deeper insight with confidence indicators where relevant]

SOURCES:
- [url1]: [brief description]
- [url2]: [brief description]
- [url3]: [brief description]

Keep response under 500 words. No introductions or filler text." --output-format json 2>/dev/null | jq -r '.response // .error.message // "No response received"'
