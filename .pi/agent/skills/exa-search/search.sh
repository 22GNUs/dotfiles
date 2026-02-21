#!/bin/bash

# Exa Search Script
# Usage: ./search.sh "query" [options]

set -e

API_KEY="${EXA_API_KEY:-}"
if [ -z "$API_KEY" ]; then
    echo "Error: EXA_API_KEY environment variable not set"
    echo "Get your API key from: https://dashboard.exa.ai/"
    exit 1
fi

# Parse arguments
QUERY=""
NUM_RESULTS=5
START_DATE=""
END_DATE=""
INCLUDE_DOMAINS=""
EXCLUDE_DOMAINS=""
SEARCH_TYPE=""

# Inline content options (default: none, use exa-contents skill separately)
CONTENT_MODE=""         # highlights | summary | text
MAX_CHARS=2000          # for highlights
SUMMARY_QUERY=""        # for summary
VERBOSITY="compact"     # for text

while [[ $# -gt 0 ]]; do
    case $1 in
        --num-results)
            NUM_RESULTS="$2"
            shift 2
            ;;
        --start-date)
            START_DATE="$2"
            shift 2
            ;;
        --end-date)
            END_DATE="$2"
            shift 2
            ;;
        --include-domains)
            INCLUDE_DOMAINS="$2"
            shift 2
            ;;
        --exclude-domains)
            EXCLUDE_DOMAINS="$2"
            shift 2
            ;;
        --type)
            SEARCH_TYPE="$2"
            shift 2
            ;;
        # Inline content flags (token-efficient alternatives to --contents)
        --highlights)
            CONTENT_MODE="highlights"
            shift
            ;;
        --max-chars)
            MAX_CHARS="$2"
            shift 2
            ;;
        --summary)
            CONTENT_MODE="summary"
            shift
            ;;
        --summary-query)
            SUMMARY_QUERY="$2"
            shift 2
            ;;
        --text)
            CONTENT_MODE="text"
            shift
            ;;
        --verbosity)
            VERBOSITY="$2"
            shift 2
            ;;
        # Deprecated: kept for compatibility but discouraged
        --contents)
            echo "Warning: --contents returns full text and is token-expensive." >&2
            echo "Consider using --highlights or --summary instead." >&2
            CONTENT_MODE="text"
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$QUERY" ]; then
                QUERY="$1"
            else
                QUERY="$QUERY $1"
            fi
            shift
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    echo "Usage: ./search.sh \"search query\" [options]"
    echo ""
    echo "Basic options:"
    echo "  --num-results N        Number of results (default: 5)"
    echo "  --start-date DATE      Start date (YYYY-MM-DD)"
    echo "  --end-date DATE        End date (YYYY-MM-DD)"
    echo "  --include-domains      Comma-separated domains to include"
    echo "  --exclude-domains      Comma-separated domains to exclude"
    echo "  --type TYPE            Search type (news, blog, etc.)"
    echo ""
    echo "Inline content (token-efficient, fetched in one request):"
    echo "  --highlights           Include key excerpts per result [recommended]"
    echo "  --max-chars N          Max characters per highlight (default: 2000)"
    echo "  --summary              Include AI-generated summary per result"
    echo "  --summary-query STR    Custom query for summary generation"
    echo "  --text                 Include full text, compact verbosity [expensive]"
    echo "  --verbosity LEVEL      compact|standard|full (with --text)"
    exit 1
fi

# Build JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "query": "$QUERY",
    "numResults": $NUM_RESULTS
EOF
)

# Add optional search parameters
if [ -n "$START_DATE" ]; then
    JSON_PAYLOAD+=", \"startPublishedDate\": \"$START_DATE\""
fi

if [ -n "$END_DATE" ]; then
    JSON_PAYLOAD+=", \"endPublishedDate\": \"$END_DATE\""
fi

if [ -n "$INCLUDE_DOMAINS" ]; then
    DOMAINS=$(echo "$INCLUDE_DOMAINS" | tr ',' '\n' | sed 's/^/"/' | sed 's/$/"/' | paste -sd ',' -)
    JSON_PAYLOAD+=", \"includeDomains\": [$DOMAINS]"
fi

if [ -n "$EXCLUDE_DOMAINS" ]; then
    DOMAINS=$(echo "$EXCLUDE_DOMAINS" | tr ',' '\n' | sed 's/^/"/' | sed 's/$/"/' | paste -sd ',' -)
    JSON_PAYLOAD+=", \"excludeDomains\": [$DOMAINS]"
fi

if [ -n "$SEARCH_TYPE" ]; then
    JSON_PAYLOAD+=", \"type\": \"$SEARCH_TYPE\""
fi

# Add inline contents if requested
if [ -n "$CONTENT_MODE" ]; then
    case "$CONTENT_MODE" in
        highlights)
            JSON_PAYLOAD+=", \"contents\": { \"highlights\": { \"maxCharacters\": $MAX_CHARS } }"
            ;;
        summary)
            if [ -n "$SUMMARY_QUERY" ]; then
                JSON_PAYLOAD+=", \"contents\": { \"summary\": { \"query\": \"$SUMMARY_QUERY\" } }"
            else
                JSON_PAYLOAD+=", \"contents\": { \"summary\": true }"
            fi
            ;;
        text)
            JSON_PAYLOAD+=", \"contents\": { \"text\": { \"verbosity\": \"$VERBOSITY\" } }"
            ;;
    esac
fi

JSON_PAYLOAD+="}"

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://api.exa.ai/search" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$JSON_PAYLOAD")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: HTTP $HTTP_CODE"
    echo "$BODY"
    exit 1
fi

echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
