#!/bin/bash

# Exa Find Similar Pages Script
# Usage: ./similar.sh "https://example.com" [options]

set -e

API_KEY="${EXA_API_KEY:-}"
if [ -z "$API_KEY" ]; then
    echo "Error: EXA_API_KEY environment variable not set"
    echo "Get your API key from: https://dashboard.exa.ai/"
    exit 1
fi

URL="$1"
NUM_RESULTS="${2:-5}"

if [ -z "$URL" ]; then
    echo "Usage: ./similar.sh \"https://example.com\" [num_results]"
    exit 1
fi

# Build JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "url": "$URL",
    "numResults": $NUM_RESULTS
}
EOF
)

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://api.exa.ai/findSimilar" \
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
