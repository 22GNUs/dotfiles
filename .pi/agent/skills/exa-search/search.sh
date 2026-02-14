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
CONTENTS=false
START_DATE=""
END_DATE=""
INCLUDE_DOMAINS=""
EXCLUDE_DOMAINS=""
SEARCH_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --num-results)
            NUM_RESULTS="$2"
            shift 2
            ;;
        --contents)
            CONTENTS=true
            shift
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
    echo "Options:"
    echo "  --num-results N        Number of results (default: 5)"
    echo "  --contents             Include full content"
    echo "  --start-date DATE      Start date (YYYY-MM-DD)"
    echo "  --end-date DATE        End date (YYYY-MM-DD)"
    echo "  --include-domains      Comma-separated list of domains to include"
    echo "  --exclude-domains      Comma-separated list of domains to exclude"
    echo "  --type TYPE            Search type (news, blog, etc.)"
    exit 1
fi

# Build JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "query": "$QUERY",
    "numResults": $NUM_RESULTS
EOF
)

# Add optional parameters
if [ "$CONTENTS" = true ]; then
    JSON_PAYLOAD+=', "contents": { "text": true }'
fi

if [ -n "$START_DATE" ]; then
    JSON_PAYLOAD+=", \"startPublishedDate\": \"$START_DATE\""
fi

if [ -n "$END_DATE" ]; then
    JSON_PAYLOAD+=", \"endPublishedDate\": \"$END_DATE\""
fi

if [ -n "$INCLUDE_DOMAINS" ]; then
    # Convert comma-separated to JSON array
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

# Pretty print results
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
