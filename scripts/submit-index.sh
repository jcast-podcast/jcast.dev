#!/bin/bash
set -euo pipefail

KEY="e84f00293ef64def8fe98ebc539f3ae7"
HOST="jcast.dev"
SITEMAP_URL="https://${HOST}/sitemap.xml"

echo "Fetching sitemap: ${SITEMAP_URL}"
URLS=$(curl -fsSL "${SITEMAP_URL}" | grep -oP '(?<=<loc>)[^<]+' || true)

if [ -z "$URLS" ]; then
  echo "No URLs found in sitemap, aborting."
  exit 1
fi

# Build a JSON array of URLs
URL_LIST_JSON=$(printf '%s\n' "$URLS" | python3 -c "
import sys, json
urls = [line.strip() for line in sys.stdin if line.strip()]
print(json.dumps(urls))
")

echo "Submitting $(printf '%s\n' "$URLS" | wc -l) URLs to IndexNow..."

RESPONSE=$(curl -s -o /tmp/indexnow_response.txt -w "%{http_code}" -X POST "https://api.indexnow.org/indexnow" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "{
    \"host\": \"${HOST}\",
    \"key\": \"${KEY}\",
    \"keyLocation\": \"https://${HOST}/${KEY}.txt\",
    \"urlList\": ${URL_LIST_JSON}
  }")

echo "IndexNow response code: ${RESPONSE}"
cat /tmp/indexnow_response.txt 2>/dev/null || true

# 200 = OK, 202 = Accepted
if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "202" ]; then
  echo "✅ Submitted successfully."
else
  echo "⚠️  Unexpected response code. Check key file is reachable at https://${HOST}/${KEY}.txt"
  exit 1
fi