# Shownotes Systeem - Handleiding

## Overzicht

Het shownotes systeem is nu volledig geïmplementeerd in je JCast website. Je kunt nu voor elke aflevering gedetailleerde shownotes maken die de luisteraars extra informatie, links, tijdstempels en meer bieden.

## Hoe werkt het?

### 1. Shownotes pagina aanmaken

Maak een nieuw bestand aan in de map `content/shownotes/` met de naam:
```
s[seizoen]e[aflevering]-[slug].md
```

Bijvoorbeeld: `s01e01-professional-developer-what.md`

### 2. Frontmatter structuur

Gebruik de volgende frontmatter (metadata) bovenaan het bestand:

```yaml
---
season: 1                                                     # Seizoennummer
episode: 1                                                    # Afleveringsnummer
title: "Shownotes - Titel van de aflevering"                 # Titel van de shownotes
date: 2025-04-30                                             # Publicatiedatum
thumbnail: "/images/thumbnails/afl-1.png"                    # Optioneel: afbeelding
section: shownotes                                            # Blijft altijd 'shownotes'
episode_link: "/episodes/s01e01-professional-developer-what/" # Link naar de aflevering
---
```

### 3. Content schrijven

Na de frontmatter kun je de volledige inhoud van je shownotes schrijven in Markdown formaat:

```markdown
## Over deze aflevering

Korte beschrijving van de aflevering...

## Belangrijkste Topics

### Onderwerp 1
- Bullet point 1
- Bullet point 2

### Onderwerp 2
Uitleg over dit onderwerp...

## Resources

### Boeken
- **Boeknaam** - Auteur

### Online Resources
- [Link tekst](https://example.com)

## Tijdstempels

- **00:00** - Intro
- **05:30** - Topic 1
- **15:00** - Topic 2
```

### 4. Link vanuit aflevering naar shownotes

In het bestand van je aflevering (`content/episodes/s01e01-...md`), voeg deze parameter toe aan de frontmatter:

```yaml
shownotes_link: "/shownotes/s01e01-professional-developer-what/"
```

Dit zorgt voor een mooie button op de afleveringspagina die naar de shownotes linkt.

## Voorbeeld structuur

Zie het voorbeeldbestand: `content/shownotes/s01e01-professional-developer-what.md`

## Pagina's die beschikbaar zijn

1. **Overzichtspagina**: `/shownotes/` - Toont alle shownotes per seizoen
2. **Individuele shownotes**: `/shownotes/s01e01-...` - Gedetailleerde informatie per aflevering
3. **Link op afleveringspagina**: Elke aflevering kan nu linken naar zijn shownotes

## Styling

De shownotes pagina's hebben dezelfde visuele stijl als je afleveringen, maar met enkele aanpassingen:

- Oranje accent kleur voor buttons en links
- Responsive design voor mobiel en desktop
- Duidelijke sectie-indeling met koppen
- Ruimte voor lange teksten en lijsten

## Tips voor goede shownotes

✅ **Wél doen:**
- Voeg tijdstempels toe zodat luisteraars gemakkelijk kunnen navigeren
- Link naar alle resources die je noemt (boeken, websites, artikelen)
- Geef context bij complexe onderwerpen
- Voeg quotes toe van interessante uitspraken
- Maak gebruik van koppen en subkoppen voor structuur

❌ **Niet doen:**
- De hele aflevering transcript maken (tenzij dat je doel is)
- Teveel tekst zonder structuur
- Links vergeten of dode links plaatsen

## Vragen?

Als je vragen hebt over het shownotes systeem, check dan de voorbeeldbestanden of vraag hulp!

---
**Laatste update:** 25 november 2025

