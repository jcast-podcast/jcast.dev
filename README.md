# JCast – De Podcast over IT, Dev Life & Gezonde Meningsverschillen

Welkom bij de codebase van **JCast.dev** — een statische website gebouwd met [Hugo](https://gohugo.io/), gehost op AWS, en onderhouden door de JCast crew: Oumaima, Viktor en Maarten.

## Inhoud

- Homepagina met logo en korte beschrijving
- Overzicht van alle afleveringen met season/episode structuur
- Detailpagina per aflevering met embedded audio player
- **Blog sectie** met artikelen over development, Java, en tech
- "Over ons"-pagina met crew-bios en avatars
- Custom styling in JCast-kleuren (pure CSS, geen frameworks)
- Nederlandse datums door de hele site
- Responsive images met WebP ondersteuning
- Giscus comments op afleveringen
- Cookie consent implementatie

---

## Structuur

```plaintext
.
├── content/
│   ├── _index.md
│   ├── about.md
│   ├── episodes/
│   │   ├── _index.md
│   │   ├── s01e01-professional-developer-what.md
│   │   └── ...
│   ├── blog/
│   │   ├── _index.md
│   │   ├── 2026-01-11-ontstaan-van-jcast-dev.md
│   │   └── ...
│   └── shownotes/
│       ├── s01e08-ai-with-jan.md
│       └── ...
├── data/
│   ├── podcast.yml
│   └── people/
│       ├── oumaima_zerouali.yml
│       ├── viktor_van_steenweghen.yml
│       ├── maarten_casteels.yml
│       └── ...
├── layouts/
│   ├── _default/
│   │   ├── baseof.html
│   │   └── about.html
│   ├── episodes/
│   │   ├── list.html
│   │   └── single.html
│   ├── blog/
│   │   ├── list.html
│   │   └── single.html
│   ├── partials/
│   │   ├── head.html
│   │   ├── nl-date.html
│   │   ├── episode-thumb.html
│   │   ├── blog-thumb.html
│   │   ├── seo/
│   │   │   ├── jsonld.html
│   │   │   └── person.jsonld.html
│   │   ├── icons/
│   │   └── ui/
│   └── shortcodes/
│       └── shownotes.html
├── static/
│   ├── images/
│   │   ├── avatars/
│   │   └── thumbnails/
│   └── js/
│       └── cookie-consent.js
├── assets/
│   ├── css/
│   │   └── styles.css
│   └── images/
│       ├── blog/
│       └── thumbnails/
├── terraform/
│   ├── main.tf
│   ├── s3.tf
│   ├── cloudfront.tf
│   └── ...
├── archetypes/
│   └── default.md
├── hugo.toml
└── README.md
```

## Development

### Vereisten

- **Hugo extended** (voor asset processing zoals WebP conversie)
- Git

### Install Hugo

```bash
brew install hugo
```

Verifieer dat je de extended versie hebt:

```bash
hugo version
# Moet 'extended' bevatten
```

---

### Start local server

```bash
hugo server -D
```

Open [http://localhost:1313](http://localhost:1313)

De `-D` flag toont ook draft content.


## Deploying

This site is deployed to AWS using:

* **S3** - Static file hosting (private bucket)
* **CloudFront** - CDN for global distribution
* **Terraform** - Infrastructure as Code

### Build voor productie:

```bash
hugo --minify
```

Dit genereert de site in de `public/` folder.

### Deploy manually:

```bash
# Build eerst
hugo --minify

# Sync naar S3
aws s3 sync public/ s3://jcast.dev --delete

# Invalideer CloudFront cache (optioneel)
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

**Note**: In productie gebeurt dit via CI/CD (bijv. GitHub Actions).


## Aflevering toevoegen

1. Maak een nieuwe aflevering aan:

```bash
hugo new episodes/s01e13-titel-van-aflevering.md
```

2. Gebruik deze front matter structuur:

```yaml
---
season: 1
episode: 13
title: "Titel van de aflevering"
date: 2025-05-15
description: "Korte beschrijving voor SEO en social media"
thumbnail: "/images/thumbnails/afl-13.png"
player: "https://share.transistor.fm/e/jcast/latest"
section: episodes
guests:  # Optioneel
  - id: "guest_slug"
---

Beschrijving van de aflevering.

## Show notes

{{< shownotes "s01e13-titel-van-aflevering" >}}
```

3. Als je shownotes wil toevoegen, maak een bestand aan in `content/shownotes/s01e13-titel-van-aflevering.md`

4. Voeg een thumbnail toe in `assets/images/thumbnails/` (voor automatische WebP conversie) of in `static/images/thumbnails/`

---

## Blog artikel toevoegen

1. Maak een nieuw blog artikel aan:

```bash
hugo new blog/2026-04-08-mijn-artikel-titel.md
```

2. Gebruik deze front matter structuur:

```yaml
---
title: "Hoe we jcast.dev bouwden"
date: 2026-01-09
authors:
  - id: "oumaima_zerouali"
  - id: "maarten_casteels"
summary: "Korte samenvatting voor in de lijst en op social media"
image: "/images/blog/mijn-afbeelding.jpg"
draft: false
---

Schrijf hier je artikel in Markdown...

## Hoofdstuk 1

Content met **bold**, *italic*, en [links](https://example.com).

```java
// Code blocks worden ondersteund
public class Example {
    public static void main(String[] args) {
        System.out.println("Hello, JCast!");
    }
}
```
```

3. **Authors** worden gedefinieerd in `data/people/` (net als gasten en hosts):
   - `oumaima_zerouali.yml`
   - `maarten_casteels.yml`
   - `viktor_van_steenweghen.yml`

4. **Leestijd** wordt automatisch berekend op basis van woordenaantal (~200 woorden/minuut)

5. Voeg een hero afbeelding toe in `assets/images/blog/` (voor automatische WebP conversie) of `static/images/blog/`

6. Set `draft: false` wanneer je klaar bent om te publiceren

---

## Gast of auteur toevoegen

Alle mensen (hosts, gasten, blog auteurs) worden gedefinieerd in `data/people/`.

1. Voeg een `.yml` bestand toe in `data/people/` met een slug als bestandsnaam (bijv. `jeroen_bastijns.yml`)

2. Voorbeeld van zo'n YML-bestand:

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

3. Gebruik in episode front matter:

```yaml
guests:
  - id: "jeroen_bastijns"
```

4. Of in blog front matter:

```yaml
authors:
  - id: "jeroen_bastijns"
```

**Note**: De oude `guest: "slug"` syntax (single string) werkt nog maar is deprecated. Gebruik de `guests` array.

## Over de crew

Je vindt bios en sociale links van Oumaima, Viktor en Maarten op de **/about** pagina. 

De drie vaste co-hosts zijn gedefinieerd in:
- `data/people/oumaima_zerouali.yml`
- `data/people/viktor_van_steenweghen.yml`
- `data/people/maarten_casteels.yml`

En gerefereerd in `data/podcast.yml` onder `seasons[].hosts`.

Avatar afbeeldingen staan in `static/images/avatars/`.

## Features in gebruik

* **Hugo** (extended) - Static site generator
* **Blog sectie** met Markdown support en code syntax highlighting
* **Nederlandse datum formatting** door de hele site (`partials/nl-date.html`)
* **Responsive images** - Automatische WebP conversie en meerdere groottes
* **Shownotes** - Aparte markdown bestanden via shortcode
* **Giscus comments** - GitHub Discussions integratie op afleveringen
* **Cookie consent** - Custom vanilla JS implementatie
* **SEO** - Centralized JSON-LD structured data
* **Icons** - Tabler Icons via partial
* Responsive layout (handgemaakt, pure CSS)
* Season/Episode structuur voor afleveringen
* Multi-author support voor blog posts
* Centrale people data voor hosts, gasten en auteurs

## URLs

* Homepage: [https://jcast.dev](https://jcast.dev)
* Afleveringen: [https://jcast.dev/episodes/](https://jcast.dev/episodes/)
* Blog: [https://jcast.dev/blog/](https://jcast.dev/blog/)
* Over ons: [https://jcast.dev/about/](https://jcast.dev/about/)

## Licentie

MIT — gebruik gerust, met liefde ✨

**JCast – Developers met een mening.**
[https://jcast.dev](https://jcast.dev)
