# JCast – De Podcast over IT, Dev Life & Gezonde Meningsverschillen

Welkom bij de codebase van **JCast.dev** — een statische website gebouwd met [Hugo](https://gohugo.io/), gehost op AWS, en onderhouden door de JCast crew: Oumaima, Viktor en Maarten.

## Inhoud

- Homepagina met logo en korte beschrijving
- Overzicht van alle afleveringen
- Detailpagina per aflevering met Spotify-link
- "Over ons"-pagina met crew-bios en avatars
- Custom styling in JCast-kleuren

---

## Structuur

```plaintext
.
├── content/
│   ├── \_index.md
│   ├── about.md
│   └── episodes/
│       ├── afl-1.md
│       └── ...
├── data/
│   ├── guest
│   │   ├── name_lastname.yml
├── layouts/
│   ├── \_default/
│   │   ├── baseof.html
│   │   └── single.html
│   ├── episodes/
│   │   ├── list.html
│   │   └── single.html
│   └── partials/
│       └── head.html
├── static/
│   └── images/
│       └── avatars/
├── assets/
│   └── css/
│       └── jcast.css
├── themes/
│   └── \[optional custom theme]
├── hugo.toml
└── README.md
````

## Development
### Install Hugo

```bash
brew install hugo
````

> Make sure you’re using **Hugo extended** (for SCSS and theming support)

---

### Start local server

```bash
hugo server -D
```

Open [http://localhost:1313](http://localhost:1313)


## Deploying

This site is deployed to AWS using:

* **S3** for static hosting
* **CloudFront** for CDN
* **Terraform** for infrastructure

### Deploy manually:

```bash
hugo
aws s3 sync public/ s3://your-jcast-bucket-name --delete
```


## Aflevering toevoegen

1. Voeg een nieuw `.md` bestand toe in `content/episodes/`
2. Gebruik deze structuur:

```yaml
---
title: "Afl 1: Wat is een professionele ontwikkelaar? – Over Uncle Bob, zelfreflectie en groei als developer"
date: 2025-04-30
thumbnail: "/images/thumbnails/afl-1.png"
player: "https://share.transistor.fm/e/jcast/latest"
section: episodes
spotify: "https://open.spotify.com/episode/2m7BvwooZHogWkn3sX3UaT"
apple: "https://podcasts.apple.com/podcast/jcast/id1814550001"
amazon: "https://music.amazon.com/podcasts/bcbbf086-31fc-4cc5-b497-cbd9600ae48f"
itunes: "https://pca.st/itunes/1814550001"
podcastaddict: "https://podcastaddict.com/podcast/jcast/5881797"
deezer: "https://www.deezer.com/show/1001888441"
playerfm: "https://player.fm/series/series-3665934"
guest: "spongebob_squarepants"
---
Volledige show notes of beschrijving.
```

3. Voeg een bijhorende thumbnail toe in `static/images/thumbnails/`

## Gast toevoegen

Wanneer een aflevering een gast bevat:

1. Voeg een `.yml` bestand toe in `data/guest/` met als bestandsnaam de slug die je in het `guests`-veld gebruikt (bijv. `spongebob_squarepants.yml`)

2. Voorbeeld van zo'n YML-bestand:

```yaml
name: "Spongebob Squarepants"
bio: "Krusty Krab chef en enthousiast over eten. Houdt van schaalbaarheid en teamflow."
avatar: "/images/avatars/spongebob-avatar.png"
```

3. Gebruik in episode front matter bij voorkeur `guests` met een of meerdere ids:

```yaml
guests:
  - id: "spongebob_squarepants"
```

4. Legacy `guest: "<id>"` blijft werken, maar is verouderd.

## Over de crew

Je vindt bios en sociale links van Oumaima, Viktor en Maarten op de **/about** pagina. Avatar afbeeldingen staan in:

```
static/images/avatars/
```

## Features in gebruik

* Hugo (static site generator)
* Font Awesome (social icons)
* Responsive layout (handgemaakt)
* Collapsible episode cards (initial design)
* Markdown for content management
* Clean CSS in `/assets/css/styles.css`


## 📄 Licentie

MIT — gebruik gerust, met liefde ✨


**🎧 JCast – Developers met een mening.**
[https://jcast.dev](https://jcast.dev)
