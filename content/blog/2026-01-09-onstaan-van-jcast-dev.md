---
title: "Hoe we jcast.dev bouwden met Hugo, Terraform en AWS"
date: 2026-01-09
authors:
  - id: "oumaima_zerouali"
  - id: "maarten_casteels"
summary: "Een kijkje achter de schermen: hoe we onze podcast website bouwden met Hugo, pure CSS, en AWS. Van custom layouts tot CloudFront CDN, van cookie consent tot Giscus comments."
image: "/images/blog/jcast-tech-stack.jpg"
draft: false
---

# Hoe we jcast.dev bouwden met Hugo, Terraform en AWS

Een podcast runnen is meer dan alleen opnemen en publiceren. Je wilt dat luisteraars je ook **kunnen vinden**. Spotify en Apple zijn leuk, maar je hebt geen controle over hoe jouw show daar wordt gepresenteerd. Dus besloten we: JCast verdient een eigen digitale thuisbasis → **[jcast.dev](https://jcast.dev/)**.

En omdat we developers zijn, werd dat natuurlijk geen WordPress met vijftien plugins. We wilden iets snels, robuusts en onderhoudbaar. Onze stack:

* **Hugo** – static site generator die razendsnel is
* **Pure HTML/CSS** – geen pre-made themes, volledige controle over design
* **Terraform** – infrastructure-as-code voor reproduceerbare deployments
* **AWS S3 + CloudFront** – hosting & CDN voor wereldwijde snelheid

In deze post nemen we je mee door de technische keuzes en de lessons learned onderweg.

## Waarom Hugo?

De keuze voor Hugo kwam van Maarten, en het was een goede. Hugo wint op drie punten:

1. **Snelheid** – builds in milliseconden, niet seconden
2. **Single binary** – geen Node modules van 500MB
3. **Markdown-first** – simpele contentcreatie zonder complexe CMS

### Zonder theme

Hier komt de twist: **we gebruiken geen Hugo theme**. Geen `hugo-theme-beautiful`, geen `hugo-coder`. Gewoon pure HTML en CSS.

Waarom? Omdat we **volledige controle** wilden over kleuren, branding, HTML-structuur en performance. Geen ongebruikte CSS, geen theme updates die dingen breken. Resultaat: een site die precies doet wat wij willen, zonder ballast.

## Contentstructuur: seizoenen en afleveringen

Elke aflevering is een Markdown file in `content/episodes/`. Het interessante detail: we hebben **seizoenen** toegevoegd.

In de frontmatter van elke aflevering staat bijvoorbeeld:

```yaml
---
title: "Wat is een professionele ontwikkelaar?"
date: 2025-04-30
season: 1
episode: 1
description: "We praten over wat het betekent..."
player: "https://share.transistor.fm/e/jcast/latest"
spotify: "https://open.spotify.com/episode/..."
guest: "uncle_bob"
---
```

De `season` en `episode` velden maken het mogelijk om afleveringen te groeperen en te sorteren. Op onze overzichtspagina zie je "S01E01" in plaats van alleen maar een lijst.

### Gastinformatie zonder herhaling

We willen niet elke keer de bio en avatar van een gast kopiëren. Daarom staat gastinfo in losse YAML-files onder `data/guest/`.

Voor Uncle Bob bijvoorbeeld:

```yaml
name: "Uncle Bob"
description: "Software craftsman, auteur van Clean Code"
thumbnail: "/images/avatars/uncle-bob.png"
```

In onze episode template halen we deze data op en tonen we het automatisch als er een gast is. Geen gast? Dan wordt die sectie overgeslagen.

## Van seizoensoverzicht tot detailpagina

Hugo's templating systeem is krachtig. Onze layouts:

### Baseof: het fundament

`baseof.html` bevat het HTML-skelet met belangrijke features:

- **Skip-to-content link** voor screenreaders
- **Semantic HTML** met `role` attributes voor accessibility
- **Dynamic title**: homepage zegt "JCast", andere pagina's "Titel | JCast"
- **Open Graph tags** voor mooie social media previews

### Episodes list: gegroepeerd per seizoen

De overzichtspagina verzamelt eerst alle unieke seizoenen, en toont dan per seizoen de afleveringen. Elke episode card heeft:

- Thumbnail (met lazy loading voor performance)
- Korte samenvatting
- Platform icons (Spotify, Apple, etc.)
- Hover effect voor interactiviteit

### Episode detailpagina

Hier komt alles samen:

- S01E01 formatting in Netflix-stijl
- Gastinformatie (indien van toepassing)
- Volledige show notes
- Embedded player
- Platform links
- Comments via Giscus

## SEO: structured data met JSON-LD

Onderaan elke episode staat een JSON-LD script voor structured data. Dit helpt Google begrijpen dat het een podcast episode is, waar het deel van uitmaakt, en op welke platforms het beschikbaar is.

Resultaat: potentieel rich snippets in zoekresultaten.

## Styling: custom CSS zonder bloat

We gebruiken geen Bootstrap of Tailwind. Alles staat in onze eigen `jcast.css`.

Waarom? Performance, controle en begrijpelijkheid. Elke class heeft een doel. We definiëren onze eigen kleuren:

```css
:root {
  --jcast-primary: #FF6B35;
  --jcast-dark: #1A1A1A;
  --jcast-light: #F4F4F4;
  --jcast-accent: #4ECDC4;
}
```

En bouwen vervolgens onze componenten met deze variabelen. Responsive design via media queries zorgt dat de site er op alle apparaten goed uitziet.

## Comments met Giscus

We wilden comments, maar geen eigen backend bouwen. Giscus was de perfecte oplossing.

**Hoe werkt het?**
1. User schrijft comment op jcast.dev
2. Comment wordt opgeslagen in GitHub Discussions van onze repo
3. Moderatie gebeurt via GitHub (spam filtering, deletes, etc.)

Voordelen: geen eigen database of auth systeem, gratis (zolang repo public is), en spam filtering via GitHub.

## Cookie consent: GDPR-vriendelijk

We hebben een custom cookie banner gebouwd die pas analytics laadt **na** toestemming. De logica:

1. Check of user al een keuze heeft gemaakt
2. Zo niet, toon banner
3. Bij "accepteren": laad Google Analytics + Bing
4. Bij "weigeren": geen tracking

GDPR compliant: opt-in, niet opt-out, met duidelijke taal en een keuze die wordt onthouden.

## Hosting: AWS S3 + CloudFront

Hugo genereert statische bestanden die we hosten op AWS:

1. **S3 bucket** – bevat alle HTML, CSS, JS en afbeeldingen
2. **CloudFront distribution** – CDN met edge locations wereldwijd

Alles gedefinieerd in Terraform voor reproduceerbare infrastructure.

### De 404-plot twist

Locaal werkte onze `404.html` prima. In productie kregen we "Access Denied".

**Waarom?** CloudFront stuurt standaard een 403 (forbidden) van S3 als een object niet bestaat. Onze bucket is niet publiek leesbaar (security best practice).

**De fix:** Custom error responses in CloudFront. We mappen **zowel 403 als 404** naar `/404.html`. Nu krijgen bezoekers onze mooie 404-pagina in plaats van een lelijke AWS-foutmelding.

## CI/CD: van commit naar productie

We deployen via GitHub Actions. De workflow:

1. **Build** – `hugo --minify` voor geoptimaliseerde output
2. **Sync** – push naar S3
3. **Invalidate** – CloudFront cache clearen

Resultaat: **nieuwe aflevering online in <2 minuten**.

## Lessons learned

**Hugo zonder theme = meer werk, maar meer controle**  
Je moet alles zelf bouwen, maar je snapt precies hoe het werkt. Geen "waarom doet mijn theme dit?" momenten.

**CloudFront error responses zijn verwarrend**  
403 vs 404, Origin Access Control, cache invalidation... AWS CDN is krachtig maar heeft een leercurve.

**Giscus is perfect voor developer-focused sites**  
Als je audience tech-savvy is, werkt GitHub auth goed.

**Cookie consent moet écht opt-in zijn**  
GDPR is serieus. Maak het makkelijk om te weigeren, niet alleen om te accepteren.

**Pure CSS is leuker dan je denkt**  
Zonder framework ben je gedwongen om CSS echt te leren. Flexbox, Grid, custom properties... het is krachtiger dan je dacht.

## De stack in vogelvlucht

| Component | Technologie | Waarom |
|-----------|-------------|--------|
| Static Site Generator | Hugo | Snelheid, simpliciteit |
| Styling | Custom CSS | Volledige controle |
| Hosting | AWS S3 | Goedkoop, schaalbaar |
| CDN | CloudFront | Global edge locations |
| Infrastructure | Terraform | Reproduceerbaar |
| Comments | Giscus | Geen eigen backend |
| Analytics | Google + Bing | Traffic inzicht |
| CI/CD | GitHub Actions | Automatisch deployen |

## Wil je het zelf bekijken?

De volledige codebase staat op GitHub: **[github.com/jcast-podcast/jcast.dev](https://github.com/jcast-podcast/jcast.dev)**

## Tot slot

Ja, we hadden een simpele WordPress site kunnen maken. Of gewoon verwijzen naar Spotify.

Maar door onze eigen site te bouwen hebben we:

1. **Volledige controle** over hoe JCast wordt gepresenteerd
2. **Een leerervaring** met Hugo, Terraform en AWS
3. **Performance** die niet mogelijk is met dynamische CMSen
4. **Een codebase** die we kunnen delen met de community

En het belangrijkste: **we weten precies hoe alles werkt**. Geen black box, geen vendor lock-in.

Als developers bouwen we graag dingen zelf. Deze site is daarvan het bewijs.

---

**Benieuwd naar de content achter deze tech?** Luister naar onze [laatste aflevering](https://jcast.dev/episodes/).

**Feedback of vragen?** Bereik ons via:
- **Instagram:** [@jcast_crew](https://www.instagram.com/jcast_crew/)
- **Email:** hello.jcast@gmail.com
