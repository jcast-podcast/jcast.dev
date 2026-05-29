#!/bin/sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$repo_root"

if [ ! -f public/index.html ]; then
  echo "public/ is missing; run hugo --minify first" >&2
  exit 1
fi

sh scripts/export-legacy-images.sh

require_file() {
  if [ ! -f "$1" ]; then
    echo "missing expected file: $1" >&2
    exit 1
  fi
}

require_grep() {
  pattern="$1"
  file="$2"
  if ! grep -Eq "$pattern" "$file"; then
    echo "missing expected pattern in $file: $pattern" >&2
    exit 1
  fi
}

reject_grep() {
  pattern="$1"
  file="$2"
  if grep -Eq "$pattern" "$file"; then
    echo "unexpected pattern in $file: $pattern" >&2
    exit 1
  fi
}

require_file "public/images/thumbnails/s01e01.webp"
require_file "public/images/blog/logo.png"
require_file "public/images/avatars/maarten-avatar.webp"
require_file "public/images/jcast-logo-without-bg.svg"

require_grep 's01e01[^"]+\.webp 320w' "public/episodes/s01e01-professional-developer-what/index.html"
require_grep 'thumbnail[^"]+\.webp 320w' "public/blog/2026-05-08-genereren-van-afbeeldingen/index.html"
require_grep 'maarten-avatar[^"]+\.webp 96w' "public/blog/2026-05-08-genereren-van-afbeeldingen/index.html"
require_grep 'src="/images/jcast-logo-without-bg\.svg"' "public/index.html"
require_grep 'width="[0-9]+"' "public/about/index.html"
require_grep 'height="[0-9]+"' "public/about/index.html"
require_grep 'og:image" content="https://jcast.dev/episodes/s01e01-professional-developer-what/social.png"' "public/episodes/s01e01-professional-developer-what/index.html"
require_grep 'og:image" content="https://jcast.dev/images/blog/logo.png"' "public/blog/2026-05-08-genereren-van-afbeeldingen/index.html"
reject_grep 'og:image" content="https://jcast.dev/images/thumbnails/social.png"' "public/episodes/s01e01-professional-developer-what/index.html"
require_grep '"image":"https://jcast.dev/images/thumbnails/s01e01.webp"' "public/episodes/s01e01-professional-developer-what/index.html"

reject_grep 'og:image" content=""' "public/blog/index.html"
reject_grep 'twitter:image content=""' "public/blog/index.html"

echo "image output verification passed"
