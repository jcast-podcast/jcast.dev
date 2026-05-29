---
title: "Hoe we jcast.dev bouwden met Hugo, Terraform en AWS"
date: 2026-01-11
authors:
  - id: "oumaima_zerouali"
  - id: "maarten_casteels"
summary: "Een kijkje achter de schermen: hoe we onze podcast website bouwden met Hugo, pure CSS, en AWS. Van custom layouts tot CloudFront CDN, van cookie consent tot Giscus comments."
image: "20260109-jcast-tech-stack.webp"
draft: false
---

Een podcast maken stopt niet bij opnemen en publiceren. Als je het goed wil doen, wil je ook een plek waar alles samenkomt. Afleveringen, shownotes en binnenkort ook blogposts. Spotify en Apple Podcasts zijn prima distributiekanalen, maar ze bepalen ook hoe jouw podcast wordt gepresenteerd. En daar wilden we bij JCast zelf meer controle over.

Zo ontstond **[jcast.dev](https://jcast.dev/)**. Onze eigen digitale thuisbasis.

Omdat we developers zijn, werd dat geen klassiek CMS met een hoop plugins. We wilden iets snels, onderhoudbaars en technisch transparant. Een setup die we begrijpen, kunnen uitleggen en zonder schrik kunnen aanpassen. De stack die daaruit groeide ziet er zo uit:

* **Hugo** als static site generator
* **Pure HTML en CSS**, zonder themes of frameworks
* **Terraform** voor infrastructuur als code
* **AWS S3 en CloudFront** voor hosting en wereldwijde distributie

In deze post nemen we je mee achter de schermen en tonen we hoe die keuzes samenkomen.

## Waarom Hugo?

De keuze voor Hugo kwam oorspronkelijk van Maarten en bleek al snel de juiste. Hugo is extreem snel. Een volledige build van de site duurt milliseconden, wat het werken aan content en layout bijzonder aangenaam maakt.

Daarnaast is Hugo gewoon één binary. Geen Node ecosystem, geen dependency hell, geen verrassingen na een update. Downloaden, draaien en klaar.

En misschien nog belangrijker: Hugo is Markdown-first. Content leeft in git, niet in een database of CMS. Dat voelt licht, voorspelbaar en heel natuurlijk voor developers.

### Geen theme, bewust

We gebruiken geen bestaand Hugo theme. Alles is van nul opgebouwd met eigen HTML en CSS.

Dat vraagt meer werk in het begin, maar geeft volledige controle. We weten exact welke HTML wordt gegenereerd, welke CSS geladen wordt en waarom. Geen ongebruikte styles, geen verborgen JavaScript en geen theme-updates die plots dingen breken.

## Contentstructuur met seizoenen en afleveringen

Elke aflevering is een Markdown bestand in `content/episodes/`. Naast de standaardvelden hebben we expliciet **seizoenen en afleveringen** toegevoegd in de frontmatter:

```yaml
---
title: "Wat is een professionele ontwikkelaar?"
date: 2025-04-30
season: 1
episode: 1
description: "We praten over wat het betekent om professioneel met software om te gaan."
player: "https://share.transistor.fm/e/jcast/latest"
spotify: "https://open.spotify.com/episode/..."
guest: "uncle_bob"
---
```

Die `season` en `episode` velden gebruiken we om afleveringen te groeperen en te sorteren. Op de site zie je dus netjes “S01E01” in plaats van een lange ongestructureerde lijst. Dat maakt navigeren eenvoudiger en voelt meteen herkenbaar.

### Gastinformatie zonder duplicatie

We wilden vermijden dat we bij elke aflevering opnieuw dezelfde gastinformatie moesten schrijven. Daarom houden we gasten bij in aparte YAML-bestanden onder `data/guest/`.

Voor Uncle Bob ziet dat er bijvoorbeeld zo uit:

```yaml
name: "Uncle Bob"
description: "Software craftsman en auteur van Clean Code"
thumbnail: "/images/avatars/uncle-bob.png"
```

In onze templates halen we deze data automatisch op. Heeft een aflevering een gast, dan tonen we die sectie. Is er geen gast, dan wordt ze gewoon niet gerenderd. Zo blijft de content proper en herbruikbaar.

## Van overzicht tot detailpagina

Hugo’s templating systeem gaf ons veel vrijheid om de site logisch op te bouwen.

De basis zit in `baseof.html`. Daarin staat het volledige HTML-skelet met semantische markup, accessibility aandachtspunten zoals een skip-to-content link, dynamische paginatitels en Open Graph tags voor social previews.

De afleveringenpagina groepeert episodes per seizoen. Elke aflevering wordt weergegeven als een card met thumbnail, korte beschrijving en links naar de verschillende platformen. Afbeeldingen worden lazy geladen om performance te optimaliseren.

Op de detailpagina komt alles samen. Je ziet meteen welk seizoen en welke aflevering het is, krijgt extra context over de gast, kan de volledige shownotes lezen en meteen luisteren via de embedded player. Onderaan voorzien we links naar Spotify en andere platformen, en is er ruimte voor reacties.

## Styling met pure CSS

We gebruiken geen Bootstrap, Tailwind of ander CSS framework. Alles zit in onze eigen stylesheet.

We werken met CSS custom properties als basis voor kleuren en styling:

```css
:root {
  --jcast-primary: #FF6B35;
  --jcast-dark: #1A1A1A;
  --jcast-light: #F4F4F4;
  --jcast-accent: #4ECDC4;
  --jcast-radius: 6px;
}
```

Alle componenten bouwen hierop verder. Flexbox en Grid doen het layoutwerk, media queries zorgen voor een goede ervaring op mobiel en desktop. Het resultaat is overzichtelijke CSS zonder bloat, waarin elke class een duidelijk doel heeft.

## SEO met structured data

In plaats van per aflevering losse structured data te injecteren, hebben we gekozen voor één centrale JSON-LD graph die tijdens de build wordt samengesteld en bovenaan in de `<head>` van de pagina terechtkomt.

Tijdens het bouwen verzamelt Hugo alle relevante context en combineert die in één `@graph`. Daarin zitten onder andere:
- de podcast als organisatie en website
- het seizoen waartoe een aflevering behoort
- de aflevering zelf
- de hosts, met hun profielen en rollen

Zo ontstaat één coherent geheel dat zoekmachines in één keer kunnen verwerken, zonder versnipperde of overlappende metadata. Het resultaat is een duidelijke semantische beschrijving van wat JCast is, hoe seizoenen en afleveringen samenhangen en wie er achter de podcast zit.

Deze aanpak houdt de HTML proper, vermijdt duplicatie en sluit mooi aan bij het idee van een statische site die tijdens build time volledig wordt verrijkt.

Wie hier dieper op wil ingaan en wil begrijpen waarom JSON-LD geen magische SEO-truc is maar vooral een manier om structuur en context te geven, kan terecht bij dit artikel:  
[JSON-LD is geen SEO-truc](https://casteels.dev/posts/202601-jsonld-is-geen-seo-truc/ "JSON-LD is geen SEO-truc").

## Reacties via Giscus

We wilden reacties, maar geen eigen backend bouwen. Giscus bleek hier ideaal.

Reacties worden opgeslagen als GitHub Discussions in onze repository. Authenticatie verloopt via GitHub en moderatie doen we gewoon daar. Geen extra database, geen eigen auth systeem en toch volledige controle.

Voor een developer publiek voelt dit heel natuurlijk aan.

## Cookie consent zonder dark patterns

Tracking laden we pas na expliciete toestemming. Tot die tijd gebeurt er niets.

Onze cookie banner checkt of een bezoeker al een keuze heeft gemaakt. Zo niet, tonen we de banner. Bij accepteren laden we analytics, bij weigeren blijft alles uit. De keuze wordt onthouden, zonder trucjes of vooringevulde opties.

## Hosting op AWS met Terraform

Hugo genereert statische bestanden die we hosten in een private S3 bucket. CloudFront fungeert als CDN en zorgt voor snelle laadtijden wereldwijd.

Alles staat beschreven in Terraform, zodat de infrastructuur reproduceerbaar blijft.

### De beruchte 404

Lokaal werkte onze `404.html` perfect. In productie kregen bezoekers een “Access Denied” fout.

De oorzaak bleek CloudFront. Als een object niet bestaat, stuurt S3 standaard een 403 terug. CloudFront toont die fout letterlijk.

De oplossing was het mappen van zowel 403 als 404 errors naar onze eigen foutpagina:

```hcl
custom_error_response {
  error_code         = 403
  response_code      = 404
  response_page_path = "/404.html"
}
```

Sindsdien krijgen bezoekers netjes onze eigen 404 te zien.

## Automatisch deployen

Deployen gebeurt via GitHub Actions. Bij elke commit:

1. Bouwen we de site met Hugo
2. Synchroniseren we de output naar S3
3. Invalideren we de CloudFront cache

Een vereenvoudigd fragment uit de workflow:

```yaml
- name: Build site
  run: hugo --minify

- name: Sync to S3
  run: aws s3 sync public/ s3://jcast.dev --delete
```

Nieuwe afleveringen of blogposts staan meestal binnen twee minuten live.

## Wat we geleerd hebben

Alles zelf bouwen kost meer tijd, maar levert enorm veel inzicht op. Je weet exact hoe je site werkt en waarom bepaalde keuzes gemaakt zijn.

CloudFront is krachtig, maar heeft een leercurve. Dingen zoals error responses en caching leer je pas echt door ze fout te doen.

Giscus werkt bijzonder goed voor een technisch publiek.

En misschien wel het belangrijkste: pure CSS is leuker en krachtiger dan je denkt, zolang je de basis echt beheerst.

## De stack in één oogopslag

Voor wie liever snel een overzicht heeft, hier de technische stack samengevat:

| Onderdeel             | Technologie    | Waarom                          |
| --------------------- | -------------- | ------------------------------- |
| Static site generator | Hugo           | Supersnel en Markdown-first     |
| Styling               | Custom CSS     | Volledige controle zonder bloat |
| Hosting               | AWS S3         | Goedkoop en schaalbaar          |
| CDN                   | CloudFront     | Snelle wereldwijde distributie  |
| Infrastructure        | Terraform      | Reproduceerbare setup           |
| Comments              | Giscus         | Geen eigen backend nodig        |
| CI/CD                 | GitHub Actions | Automatische deploys            |

## Tot slot

Ja, we hadden het eenvoudiger kunnen maken. Een CMS kiezen en klaar.

Maar door jcast.dev zelf te bouwen hebben we volledige controle, een snelle site, een leerervaring en een codebase die we met plezier delen met de community.

Geen black box, geen vendor lock-in. Gewoon iets bouwen en begrijpen.

Dat past perfect bij hoe wij naar software development kijken.

---

**Benieuwd naar de content achter deze tech?** Luister naar onze [laatste aflevering](https://jcast.dev/episodes/).

**Feedback of vragen?** Bereik ons via:
- **Instagram:** [@jcast_crew](https://www.instagram.com/jcast_crew/)
- **Email:** hello.jcast@gmail.com
