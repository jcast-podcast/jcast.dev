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
title: "Afl X: Titel van de aflevering"
date: YYYY-MM-DD
thumbnail: "/images/thumbnails/afl-x.png"
spotify: "https://open.spotify.com/episode/...."
summary: "Korte beschrijving voor de afleveringenlijst"
---
Volledige show notes of beschrijving.
```

3. Voeg een bijhorende thumbnail toe in `static/images/thumbnails/`


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
* Clean CSS in `/assets/css/jcast.css`


## 📄 Licentie

MIT — gebruik gerust, met liefde ✨


**🎧 JCast – Developers met een mening.**
[https://jcast.dev](https://jcast.dev)
