#!/bin/bash
# Submits only the URLs affected by real content changes to IndexNow, instead
# of re-submitting the entire sitemap on every push. Follows IndexNow's own
# automation guidance: detect meaningful changes (not cosmetic/layout-only
# ones), debounce repeat submissions of the same URL, and log every attempt
# with its HTTP response code.
#
# How it works:
#   1. Diffs `content/` between BEFORE_SHA and AFTER_SHA (the previous and
#      current commit on trunk) to find which content files actually changed.
#      Changes to layouts/, assets/css/, etc. are intentionally ignored - a
#      CSS tweak shouldn't trigger a reindex of every page on the site.
#   2. Maps each changed content file to its real rendered URL by checking
#      the `public/` directory Hugo already built in this workflow run
#      (rather than guessing slug conventions by hand). A content file that
#      didn't produce output (draft, future-dated, etc.) is skipped.
#   3. Filters out URLs already submitted in the last DEBOUNCE_SECONDS,
#      tracked in a small state file (.indexnow-state.json) that the CI
#      workflow caches between runs.
#   4. Submits the remaining URLs in a single batch request and logs the
#      response.
#
# Env vars:
#   BEFORE_SHA          Previous commit SHA to diff from (CI sets this from
#                        github.event.before). Required unless INDEXNOW_FULL=true.
#   AFTER_SHA            Commit SHA to diff to. Defaults to HEAD.
#   INDEXNOW_FULL         Optional. Set to "true" to fall back to the old
#                        behavior (submit every URL in sitemap.xml) - useful
#                        for a one-off bootstrap/recovery submission, run
#                        manually, not from CI.
#   DEBOUNCE_SECONDS     Optional. Minimum time between two submissions of the
#                        same URL. Defaults to 300 (5 minutes).
#   STATE_FILE           Optional. Defaults to .indexnow-state.json.

set -euo pipefail

KEY="e84f00293ef64def8fe98ebc539f3ae7"
HOST="jcast.dev"
BASE_URL="https://${HOST}"
SITEMAP_URL="${BASE_URL}/sitemap.xml"

AFTER_SHA="${AFTER_SHA:-HEAD}"
INDEXNOW_FULL="${INDEXNOW_FULL:-false}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-300}"
STATE_FILE="${STATE_FILE:-.indexnow-state.json}"

JQ_BIN="${JQ_BIN:-jq}"
CURL_BIN="${CURL_BIN:-curl}"

log() { printf '%s\n' "$*"; }

submit_urls() {
  # $1 = newline-separated URL list
  local urls="$1"
  local count
  count=$(printf '%s\n' "$urls" | sed '/^$/d' | wc -l | tr -d ' ')

  if [ "$count" -eq 0 ]; then
    log "Nothing to submit."
    return 0
  fi

  local url_list_json
  url_list_json=$(printf '%s\n' "$urls" | sed '/^$/d' | python3 -c "
import sys, json
urls = [line.strip() for line in sys.stdin if line.strip()]
print(json.dumps(urls))
")

  log "Submitting ${count} URL(s) to IndexNow:"
  printf '%s\n' "$urls" | sed '/^$/d' | sed 's/^/  - /'

  local response
  response=$("$CURL_BIN" -s -o /tmp/indexnow_response.txt -w "%{http_code}" -X POST "https://api.indexnow.org/indexnow" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{
      \"host\": \"${HOST}\",
      \"key\": \"${KEY}\",
      \"keyLocation\": \"https://${HOST}/${KEY}.txt\",
      \"urlList\": ${url_list_json}
    }")

  log "IndexNow response code: ${response}"
  cat /tmp/indexnow_response.txt 2>/dev/null || true
  echo

  # 200 = OK, 202 = Accepted
  if [ "$response" = "200" ] || [ "$response" = "202" ]; then
    log "✅ Submitted successfully."
    return 0
  fi

  log "⚠️  Unexpected response code. Check key file is reachable at https://${HOST}/${KEY}.txt"
  return 1
}

# --- Full-sitemap fallback (manual/bootstrap use only) ---------------------
if [ "$INDEXNOW_FULL" = "true" ]; then
  log "INDEXNOW_FULL=true - submitting every URL from ${SITEMAP_URL} (bypasses change detection and debounce)."
  URLS=$("$CURL_BIN" -fsSL "$SITEMAP_URL" | grep -oP '(?<=<loc>)[^<]+' || true)
  if [ -z "$URLS" ]; then
    log "No URLs found in sitemap, aborting."
    exit 1
  fi
  submit_urls "$URLS"
  exit $?
fi

# --- Change-detection path (default, used by CI) ----------------------------
if [ -z "${BEFORE_SHA:-}" ] || [ "$BEFORE_SHA" = "0000000000000000000000000000000000000000" ]; then
  log "No previous commit to diff against (first push on this branch, or history unavailable)."
  log "Skipping IndexNow submission. Run with INDEXNOW_FULL=true to submit the full sitemap once instead."
  exit 0
fi

if ! git cat-file -e "${BEFORE_SHA}^{commit}" 2>/dev/null; then
  log "BEFORE_SHA (${BEFORE_SHA}) is not available locally - checkout probably used a shallow clone."
  log "Skipping IndexNow submission rather than guessing what changed."
  exit 0
fi

CHANGED_FILES=$(git diff --name-only "$BEFORE_SHA" "$AFTER_SHA" -- content/ || true)

if [ -z "$CHANGED_FILES" ]; then
  log "No changes under content/ in this push - nothing meaningful to submit to IndexNow."
  log "(Layout, CSS, and other non-content changes are intentionally ignored.)"
  exit 0
fi

log "Changed content files (${BEFORE_SHA:0:7}..${AFTER_SHA:0:7}):"
printf '%s\n' "$CHANGED_FILES" | sed 's/^/  - /'

# Map each changed content file to its rendered URL by checking what Hugo
# actually produced in public/ during this run - avoids hand-rolling Hugo's
# slug/permalink logic and naturally skips files that didn't render (drafts,
# future-dated posts, deleted content, etc.).
CANDIDATE_URLS=""
while IFS= read -r file; do
  [ -n "$file" ] || continue

  dir="$(dirname "$file")"
  base="$(basename "$file")"

  case "$base" in
    _index.md|index.md)
      url_path="$dir"
      [ "$url_path" = "content" ] && url_path=""
      url_path="${url_path#content/}"
      ;;
    *.md)
      slug="${base%.md}"
      url_path="${dir#content/}"
      [ "$url_path" = "content" ] && url_path=""
      if [ -n "$url_path" ]; then
        url_path="${url_path}/${slug}"
      else
        url_path="$slug"
      fi
      ;;
    *)
      # Non-markdown file inside a page bundle (image, etc.) - the bundle's
      # own index.md change (if any) already covers it; nothing to derive here.
      continue
      ;;
  esac

  public_index="public/${url_path}/index.html"
  [ -z "$url_path" ] && public_index="public/index.html"

  if [ -f "$public_index" ]; then
    CANDIDATE_URLS="${CANDIDATE_URLS}${BASE_URL}/${url_path:+${url_path}/}
"
  else
    log "  (skipping ${file}: no rendered output at ${public_index} - draft, future-dated, or deleted)"
  fi
done <<< "$CHANGED_FILES"

# Dedupe (a page bundle can have multiple changed files, e.g. index.md + image)
CANDIDATE_URLS=$(printf '%s\n' "$CANDIDATE_URLS" | sed '/^$/d' | sort -u)

if [ -z "$CANDIDATE_URLS" ]; then
  log "Changed content files didn't map to any rendered URL - nothing to submit."
  exit 0
fi

# --- Debounce: skip URLs submitted within DEBOUNCE_SECONDS ------------------
[ -f "$STATE_FILE" ] || echo '{}' > "$STATE_FILE"

NOW_EPOCH=$(date +%s)
FINAL_URLS=""
while IFS= read -r url; do
  [ -n "$url" ] || continue
  last_submitted=$("$JQ_BIN" -r --arg u "$url" '.[$u] // empty' "$STATE_FILE")
  if [ -n "$last_submitted" ]; then
    elapsed=$(( NOW_EPOCH - last_submitted ))
    if [ "$elapsed" -lt "$DEBOUNCE_SECONDS" ]; then
      log "  (debounced: ${url} was submitted ${elapsed}s ago, < ${DEBOUNCE_SECONDS}s)"
      continue
    fi
  fi
  FINAL_URLS="${FINAL_URLS}${url}
"
done <<< "$CANDIDATE_URLS"

FINAL_URLS=$(printf '%s\n' "$FINAL_URLS" | sed '/^$/d')

if [ -z "$FINAL_URLS" ]; then
  log "All changed URLs were debounced (submitted too recently) - nothing to submit."
  exit 0
fi

if submit_urls "$FINAL_URLS"; then
  # Record successful submissions so we can debounce future runs.
  UPDATED_STATE="$("$JQ_BIN" -n --slurpfile state "$STATE_FILE" --arg now "$NOW_EPOCH" --rawfile urls <(printf '%s\n' "$FINAL_URLS") '
    ($urls | split("\n") | map(select(length > 0))) as $submitted
    | $state[0] + (reduce $submitted[] as $u ({}; . + {($u): ($now | tonumber)}))
  ')"
  printf '%s\n' "$UPDATED_STATE" > "$STATE_FILE"
  exit 0
else
  exit 1
fi
