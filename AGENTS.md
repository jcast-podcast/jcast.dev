# Project Context for Agents

This repository contains a custom-built Hugo website.
All HTML templates and CSS are handwritten. No CSS framework is used.

The goal is to improve accessibility (WCAG), layout consistency, and SEO
without changing the visual identity.

---

## Tech Stack

- Static site generator: Hugo
- Templates: Hugo layouts and partials
- Styling: Custom CSS (handwritten, no Tailwind/Bootstrap)
- JavaScript: Minimal, vanilla JS only
- No React, Vue, or build-time JS frameworks

---

## Layout & CSS Conventions

- The site uses a central content container.
- Target content width is **max-width: 800px**.
- Responsive behavior is achieved with fluid width + horizontal padding.
- Avoid nested containers that both set max-width.
- Do NOT change color values unless explicitly instructed.

---

## Accessibility (WCAG) Principles

When modifying templates or CSS:
- Prefer semantic HTML elements (header, nav, main, footer, button, a).
- Avoid nested interactive elements.
- Ensure all interactive elements are keyboard accessible.
- Ensure visible focus using :focus-visible.
- Decorative images must use alt=""; meaningful images require descriptive alt text.
- One H1 per page; headings must follow logical order.
- Add skip-to-content link where appropriate.

---

## SEO & Structured Data

- JSON-LD is used for structured data.
- All JSON-LD scripts should be centralized in a single head partial.
- Page types:
    - Home page: WebSite (and PodcastSeries if applicable)
    - Episode pages: PodcastEpisode

---

## Podcast Author Model

The podcast has **three fixed co-hosts**:
- Oumaima
- Viktor
- Maarten

These hosts should be modeled as `Person` entities and reused across episodes.

Some episodes include **guest speakers**.
Guests vary per episode and are optional.

Rules:
- Do NOT model all hosts as a single string author.
- Use Role-based modeling:
    - roleName: "host" for co-hosts
    - roleName: "guest" for guest speakers
- Hosts should come from a shared data source (Hugo data file or site params).
- Guests should be defined in episode front matter.

---

## Constraints

- Do not change brand colors.
- Avoid large visual or layout rewrites unless explicitly requested.
- Prefer small, incremental patches.
- Always provide file paths and diffs when proposing changes.

---

## Expected Output

For each task:
- Identify the relevant files
- Explain the reasoning briefly
- Provide minimal, concrete changes (diff-style when possible)
- Mention any manual verification steps if relevant
