#!/bin/sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$repo_root"

if [ ! -d public ]; then
  echo "public/ is missing; run hugo --minify first" >&2
  exit 1
fi

copy_legacy_image() {
  page_dir="$1"
  param_key="$2"

  if [ ! -f "$page_dir/index.md" ]; then
    return
  fi

  target_path="$(awk -F'"' -v key="$param_key" '$1 == key ": " { print $2; exit }' "$page_dir/index.md")"
  case "$target_path" in
    /images/*) ;;
    *) return ;;
  esac

  source_path=""
  for candidate in \
    "$page_dir/thumbnail.webp" \
    "$page_dir/thumbnail.png" \
    "$page_dir/thumbnail.jpg" \
    "$page_dir/thumbnail.jpeg" \
    "$page_dir/thumbnails.webp" \
    "$page_dir/thumbnails.png" \
    "$page_dir/thumbnails.jpg" \
    "$page_dir/thumbnails.jpeg"
  do
    if [ -f "$candidate" ]; then
      source_path="$candidate"
      break
    fi
  done

  if [ -z "$source_path" ]; then
    echo "missing local thumbnail asset for $page_dir" >&2
    exit 1
  fi

  destination="public${target_path}"
  mkdir -p "$(dirname "$destination")"
  cp "$source_path" "$destination"
}

for page_dir in content/episodes/*; do
  [ -d "$page_dir" ] || continue
  copy_legacy_image "$page_dir" "thumbnail"
done

for page_dir in content/blog/*; do
  [ -d "$page_dir" ] || continue
  copy_legacy_image "$page_dir" "image"
done
