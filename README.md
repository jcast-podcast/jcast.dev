# JCast – De Podcast over IT, Dev Life & Gezonde Meningsverschillen

Welkom bij de codebase van **[jcast.dev](https://jcast.dev)**: de website van JCast, een Nederlandstalige developer podcast over Java, software engineering, AI, tooling en developer life. De site is een statische [Hugo](https://gohugo.io/)-site, gehost op AWS (S3 + CloudFront), en wordt onderhouden door de JCast crew: Oumaima, Viktor en Maarten.

## Inhoud

- Homepagina met logo, korte beschrijving en de laatste aflevering
- Overzicht van alle afleveringen, gegroepeerd per seizoen, met een aparte sectie voor specials
- Detailpagina per aflevering met embedded audio player, shownotes, gasten en gerelateerde content
- **Blog** met artikelen over development, Java en tech
- **Onderwerpen** (`/topics/`): afleveringen en blogposts gegroepeerd per thema, zoals Java, AI of Architectuur
- "Over ons"-pagina met crew-bios en avatars
- Eigen styling in JCast-kleuren (pure CSS, geen frameworks) en vanilla JS
- Nederlandse datums door de hele site
- Responsive images met automatische WebP-conversie
- Giscus comments op afleveringen
- Cookie consent, met analytics pas na expliciete toestemming
- Structured data (JSON-LD) voor SEO, plus IndexNow na elke deploy

---

## Structuur

```plaintext
.
├── content/
│   ├── _index.md
│   ├── about.md
│   ├── episodes/
│   │   ├── _index.md
│   │   └── s02e07-titel-van-aflevering/     # page bundle per aflevering
│   │       ├── index.md
│   │       ├── shownotes.md                 # optioneel
│   │       ├── thumbnail.webp
│   │       └── social.png
│   ├── blog/
│   │   ├── _index.md
│   │   └── 2026-10-26-titel-van-artikel/    # page bundle per artikel
│   │       ├── index.md
│   │       ├── thumbnail.webp
│   │       └── social.png
│   └── topics/
│       └── _index.md
├── data/
│   ├── podcast.yml                          # podcastmetadata, seizoenen en hosts
│   ├── topics.yaml                          # beschrijving per onderwerp
│   └── people/                              # hosts, gasten en auteurs
├── layouts/
│   ├── _default/                            # baseof, about, image render hook
│   ├── episodes/                            # list + single
│   ├── blog/                                # list + single
│   ├── topics/                              # taxonomy, terms, term
│   ├── partials/
│   │   ├── images/                          # responsive image pipeline
│   │   ├── seo/                             # JSON-LD
│   │   ├── episode-badge.html, episode-thumb.html, blog-thumb.html
│   │   ├── related-content.html, topic-pills.html, person-image.html
│   │   └── nl-date.html, icons/, ui/
│   └── shortcodes/
│       ├── shownotes.html
│       └── image.html
├── assets/
│   ├── css/styles.css
│   └── images/                              # avatars, blog, logo
├── static/                                  # favicons, logo's, js, verificatiebestanden
│   └── js/                                  # cookie-consent, nav-toggle, back-to-top, topic-switcher, ...
├── scripts/                                 # export-legacy-images, verify-image-output, submit-indexnow
├── terraform/                               # S3, CloudFront, certificaat en DNS
├── .github/workflows/                       # deploy, terraform, auto-release-episode
├── archetypes/default.md
├── AGENTS.md                                # context voor AI-agents
├── hugo.toml
└── README.md
```

---

## Development

### Vereisten

- **Hugo extended** (voor image processing zoals WebP-conversie). CI draait op versie **0.170.1**; Renovate houdt die bij.
- Git

### Hugo installeren

```bash
brew install hugo
```

Controleer dat je de extended versie hebt:

```bash
hugo version
# Moet 'extended' bevatten
```

### Lokaal draaien

```bash
hugo server -D
```

De site draait dan op [http://localhost:1313](http://localhost:1313), inclusief drafts.

### Build voor productie

```bash
hugo --minify
```

Dit genereert de site in `public/`. Daarna draait CI nog twee scripts die je lokaal ook kan uitvoeren:

```bash
sh scripts/export-legacy-images.sh   # kopieert images naar hun oude paden
sh scripts/verify-image-output.sh    # controleert dat de image output compleet is
```

---

## Deployment

Alles loopt via GitHub Actions. Handmatig deployen is niet meer nodig.

| Workflow | Wanneer | Wat |
|---|---|---|
| `deploy.yml` | push naar `trunk` of handmatig | `hugo --minify`, image scripts, `aws s3 sync` naar S3, daarna IndexNow voor de gewijzigde content |
| `terraform.yml` | push naar `trunk` die `terraform/**` raakt | `terraform init`, `plan` en `apply` |
| `auto-release-episode.yml` | elke eerste maandag van de maand om 08:00 (Europe/Brussels), of handmatig | merget de branch `feat/sXXeXX` (of `feature/sXXeXX`) in `trunk`, verwijdert die branch en start `deploy.yml` |

**Een aflevering plannen:** werk de aflevering uit op een branch `feat/s02e08` (formaat `sXXeXX`) en laat die openstaan. Op de eerste maandag van de maand gaat ze automatisch live. Bestaan er twee afleveringsbranches tegelijk, dan weigert de workflow te gokken en faalt ze bewust.

Hosting: S3 + CloudFront (met `www`-redirect) via Terraform, regio `eu-west-1`.

---

## Aflevering toevoegen

1. Maak een folder aan voor de aflevering (page bundle) met een `index.md`:

```bash
hugo new content episodes/s02e08-titel-van-aflevering/index.md
```

2. Gebruik deze front matter:

```yaml
---
season: 2
episode: 8
title: "Titel van de aflevering"
date: 2026-12-07
description: "Korte beschrijving voor SEO en social media"
thumbnail: "/images/thumbnails/s02e08-titel-van-aflevering.webp"
social_image: "social.png"
player: "https://share.transistor.fm/e/xxxxxxxx"
transistor_id: "1234567"
section: episodes
guests:            # optioneel
  - id: "guest_slug"
topics:            # optioneel, zie data/topics.yaml
  - "Java"
  - "AI"
---

Beschrijving van de aflevering.

## Show notes

{{< shownotes >}}
```

3. Zet de afbeeldingen (`thumbnail.webp`, `social.png`, eventueel `background.png`) in dezelfde folder.

4. Shownotes zijn optioneel: maak een `shownotes.md` in dezelfde folder aan. De `shownotes`-shortcode leest dat bestand zelf in.

### Special

Een aflevering die niet in een genummerd slot past (bijvoorbeeld een live special) krijgt `special: true`. Je kan `season` laten staan of weglaten, maar zet `episode` nooit op `0`. Het label op de badge is standaard "Special" en aanpasbaar met `special_label`. Specials staan op `/episodes/` onder hun eigen kop.

```yaml
special: true
special_label: "Special"   # optioneel
topics:
  - "Special"
```

---

## Blog artikel toevoegen

1. Maak een folder aan voor het artikel:

```bash
hugo new content blog/2026-12-01-mijn-artikel-titel/index.md
```

2. Gebruik deze front matter:

```yaml
---
title: "Titel van het artikel"
date: 2026-12-01
authors:
  - id: "oumaima_zerouali"
  - id: "maarten_casteels"
image: "thumbnail.webp"
social_image: "social.png"
summary: "Korte samenvatting voor in de lijst en op social media"
topics:
  - "Java"
  - "Community"
draft: false
---

Schrijf hier je artikel in Markdown...
```

3. Zet de afbeeldingen in dezelfde folder als `index.md`. Voor afbeeldingen in de tekst gebruik je de `image`-shortcode, zodat ze responsive en als WebP geserveerd worden.

4. **Leestijd** wordt automatisch berekend (~200 woorden per minuut) en code blocks krijgen syntax highlighting.

5. Zet `draft: false` als je klaar bent om te publiceren.

---

## Onderwerpen (topics)

Afleveringen en blogposts worden gegroepeerd met de taxonomie `topics`. Elke waarde in de `topics:`-lijst van de front matter krijgt een eigen pagina onder `/topics/`.

De beschrijving die op zo'n pagina staat, komt uit `data/topics.yaml`. Voeg je een nieuw onderwerp toe, geef het dan ook een regel in dat bestand.

---

## Gast of auteur toevoegen

Alle mensen (hosts, gasten, blog-auteurs) worden gedefinieerd in `data/people/`.

1. Voeg een `.yml` bestand toe met een slug als bestandsnaam (bijvoorbeeld `jeroen_bastijns.yml`).

2. Voorbeeld:

```yaml
name: "Jeroen Bastijns"
id: "https://jcast.dev/#person-jeroen_bastijns"
url: "https://jeroenbastijns.com"
sameAs:
  - "https://github.com/jeroen"
  - "https://www.linkedin.com/in/jeroenbastijns/"
bio: "Software architect en clean code evangelist"
image: "/images/avatars/jeroen-avatar.png"
socials:
  linkedin: "https://www.linkedin.com/in/jeroenbastijns/"
  github: "https://github.com/jeroen"
```

3. Verwijs ernaar vanuit een aflevering (`guests`) of blogpost (`authors`):

```yaml
guests:
  - id: "jeroen_bastijns"
```

**Note**: De oude `guest: "slug"` syntax (één string) werkt nog, maar is deprecated. Gebruik de `guests` array.

## Over de crew

Bios en sociale links van Oumaima, Viktor en Maarten staan op de **/about** pagina. De drie vaste co-hosts staan in:

- `data/people/oumaima_zerouali.yml`
- `data/people/viktor_van_steenweghen.yml`
- `data/people/maarten_casteels.yml`

Ze worden per seizoen gerefereerd in `data/podcast.yml` onder `seasons[].hosts`. Avatars staan in `assets/images/avatars/`.

---

## Features in gebruik

* **Hugo** (extended) als static site generator
* **Page bundles** voor afleveringen en blogposts, met afbeeldingen naast de content
* **Responsive images**: WebP en meerdere groottes via `partials/images/` en de `image`-shortcode
* **Topics**: taxonomie met overzichts- en detailpagina's, topic-pills en gerelateerde content
* **Specials** naast genummerde afleveringen
* **Shownotes** als apart markdown-bestand via shortcode
* **Giscus comments** (GitHub Discussions) op afleveringen
* **Cookie consent**: eigen vanilla JS, Google Analytics laadt pas na toestemming
* **SEO**: centrale JSON-LD, sitemap, `robots.txt` en IndexNow
* **Nederlandse datums** via `partials/nl-date.html`
* **Auto-release** van afleveringen op de eerste maandag van de maand
* **Renovate** voor dependency-updates (Hugo, Terraform, Node en GitHub Actions)
* Handgemaakte, responsive layout in pure CSS, met multi-author support en centrale people data

## URLs

* Homepage: [https://jcast.dev](https://jcast.dev)
* Afleveringen: [https://jcast.dev/episodes/](https://jcast.dev/episodes/)
* Blog: [https://jcast.dev/blog/](https://jcast.dev/blog/)
* Onderwerpen: [https://jcast.dev/topics/](https://jcast.dev/topics/)
* Over ons: [https://jcast.dev/about/](https://jcast.dev/about/)

## Licentie

MIT — gebruik gerust, met liefde ✨


**JCast – Developers met een mening.**
[https://jcast.dev](https://jcast.dev)
