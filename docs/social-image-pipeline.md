# Social Image Pipeline

We should generate dedicated social cards outside Hugo and publish them as stable files from the `jcast-studio` flow.

## Why

- Hugo should not be responsible for card composition.
- Social cards need a different contract than inline page images.
- The studio pipeline already knows the episode title, guest, publish date, and thumbnail context.

## Recommended output

- Episode card: `/images/social/episodes/sXXeYY.png`
- Blog card: `/images/social/blog/<slug>.png`
- Optional current aliases:
  - `/images/social/latest-episode.png`
  - `/images/social/latest-blog.png`

## Expected spec

- Size: `1200x630`
- Format: PNG for maximum crawler compatibility
- Safe text margins for title and guest names
- Reuse the existing visual language from thumbnails, but with layout tuned for link previews

## Hugo integration

- Keep Hugo simple:
  - front matter can gain `social_image`
  - metadata partials should prefer `social_image`
  - fallback remains the current stable hero/thumbnail path

## Studio flow idea

1. Generate the episode/blog hero image.
2. Generate the social card from the same source inputs.
3. Write both files into the website repo before publish.
4. Commit them together with the content change.

This keeps the site deterministic and avoids template-time rendering logic for social cards.
