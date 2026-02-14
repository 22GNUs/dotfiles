#!/bin/bash

# Exa Get Contents Script
# Usage: ./contents.sh "https://url1.com" "https://url2.com" ...

set -e

API_KEY="${EXA_API_KEY:-}"
if [ -z "$API_KEY" ]; then
    echo "Error: EXA_API_KEY environment variable not set"
    echo "Get your API key from: https://dashboard.exa.ai/"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: ./contents.sh \"https://url1.com\" [\"https://url2.com\" ...]"
    exit 1
fi

# Build URLs array
URLS=""
for url in "$@"; do
    if [ -n "$URLS" ]; then
        URLS+=", "
    fi
    URLS+="\"$url\""
done

# Build JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "urls": [$URLS],
    "text": true
}
EOF
)

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://api.exa.ai/contents" \
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
