#!/bin/bash

# Exa Get Contents Script
# Usage: ./contents.sh [options] "https://url1.com" "https://url2.com" ...
#
# NOTE: The /contents endpoint only supports text retrieval.
# highlights and summary are only available via the /search endpoint (see exa-search skill).
#
# To save tokens with known URLs, use --verbosity compact (default) and --exclude-sections.

set -e

API_KEY="${EXA_API_KEY:-}"
if [ -z "$API_KEY" ]; then
    echo "Error: EXA_API_KEY environment variable not set"
    echo "Get your API key from: https://dashboard.exa.ai/"
    exit 1
fi

# Defaults
VERBOSITY="compact"     # compact | standard | full
EXCLUDE_SECTIONS=""
LIVECRAWL=false
URLS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbosity)
            VERBOSITY="$2"
            shift 2
            ;;
        --compact)
            VERBOSITY="compact"
            shift
            ;;
        --standard)
            VERBOSITY="standard"
            shift
            ;;
        --full)
            VERBOSITY="full"
            shift
            ;;
        --exclude-sections)
            EXCLUDE_SECTIONS="$2"
            LIVECRAWL=true
            shift 2
            ;;
        --livecrawl)
            LIVECRAWL=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Usage: ./contents.sh [options] <url> [url...]"
            exit 1
            ;;
        *)
            URLS+=("$1")
            shift
            ;;
    esac
done

if [ ${#URLS[@]} -eq 0 ]; then
    echo "Usage: ./contents.sh [options] \"https://url1.com\" [\"https://url2.com\" ...]"
    echo ""
    echo "NOTE: /contents only supports full text. For highlights/summary, use exa-search skill."
    echo ""
    echo "Options:"
    echo "  --compact              Compact verbosity, main content only (default)"
    echo "  --standard             Standard verbosity, more detail"
    echo "  --full                 Full verbosity, complete content"
    echo "  --verbosity LEVEL      compact|standard|full"
    echo "  --exclude-sections S   Comma-separated sections to exclude (enables livecrawl)"
    echo "                         Options: navigation,footer,sidebar,banner,header,metadata"
    echo "  --livecrawl            Force live crawl instead of cache"
    exit 1
fi

# Build URLs array
URLS_JSON=""
for url in "${URLS[@]}"; do
    if [ -n "$URLS_JSON" ]; then
        URLS_JSON+=", "
    fi
    URLS_JSON+="\"$url\""
done

# Build text options
TEXT_OPTS="\"verbosity\": \"$VERBOSITY\""
if [ -n "$EXCLUDE_SECTIONS" ]; then
    SECTIONS=$(echo "$EXCLUDE_SECTIONS" | tr ',' '\n' | sed 's/^/"/' | sed 's/$/"/' | paste -sd ',' -)
    TEXT_OPTS+=", \"excludeSections\": [$SECTIONS]"
fi

# Build contents object
CONTENTS_JSON="\"text\": { $TEXT_OPTS }"
if [ "$LIVECRAWL" = true ]; then
    CONTENTS_JSON+=", \"livecrawl\": \"always\""
fi

# Build final JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "urls": [$URLS_JSON],
    "contents": { $CONTENTS_JSON }
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

echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
