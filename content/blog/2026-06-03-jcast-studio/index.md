---
title: "JCast Studio: hoe wij onze podcast-pipeline automatiseerden"
date: 2026-06-03
authors:
  - id: "maarten_casteels"
image: "jcast-studio-logo.webp"
summary: "Bij JCast nemen we niet alleen een podcast op. We bouwen ook voortdurend verder aan alles errond. In deze blogpost delen we hoe we onze volledige podcast-pipeline hebben geautomatiseerd met Bash-scripts, van transcripties tot social posts."
draft: false
---

Met JCast nemen we niet alleen een podcast op. We bouwen ook voortdurend verder aan alles errond.

We zijn met drie developers: Oumaima, Viktor en ikzelf. En zoals dat vaak gaat bij developers begon het met: “Dat kunnen we toch automatiseren?”

Want eerlijk? Een aflevering opnemen is het leuke deel. Alles daarna niet altijd.

Transcripties genereren. Show notes schrijven. Uploaden naar Transistor.fm. Social posts voorbereiden. Thumbnails genereren. Avatars maken.

Voor je het weet ben je meer bezig met randzaken dan met de podcast zelf.

Dus besloten we om onze eigen pipeline te bouwen.

## De eerste versie was… Java

Ja, echt.

We hadden ooit een `announce.java` en een `socials.java`. Technisch werkte het prima, maar het voelde gewoon veel te zwaar voor wat we wilden doen. Je wil niet telkens een volledige Java-applicatie starten om een social post te genereren.

Dus hebben we alles weggegooid.

Vandaag draait bijna alles in Bash. Gewoon scripts, `curl`, `jq`, ImageMagick en APIs. Geen frameworks. Geen build tools. Geen overkill.

En eerlijk? Dat werkt verrassend goed.

## Eén opname, volledige pipeline

Wat gestart is als “een scriptje voor transcripties” is ondertussen uitgegroeid tot een volledige publishing pipeline.

Vandaag loopt een aflevering ongeveer zo door ons systeem:

```text
episode.wav
  -> transcribe.sh    ->  transcript + tekst
  -> shownotes.sh     ->  index.md met show notes
  -> transistor.sh    ->  upload + scheduling
  -> avatar.sh        ->  creatie van een avatar
  -> thumbnail.sh     ->  1024×1024 thumbnail + social card (1200×630)
  -> upscale.sh       ->  3000×3000 PNG voor Transistor, 1200×1200 WebP voor website
  -> artwork.sh       ->  coverafbeelding hosten en koppelen
  -> announce.sh      ->  posts voor Bluesky en LinkedIn
```

En eerlijk: ik ben rampzalig in command-line parameters onthouden.

Daarom gebruik ik meestal gewoon:

```bash
make studio
```

Dat opent een interactief menu waarmee ik eigenlijk gewoon de volledige workflow volg van A tot Z. Transcriptie, show notes, thumbnails, uploaden, socials… alles zit daarin verwerkt.

Uiteraard kan alles ook afzonderlijk via scripts, maar meestal wil ik gewoon zo snel mogelijk van ruwe opname naar gepubliceerde aflevering gaan zonder eerst opnieuw syntax te moeten opzoeken.

## Verrassend veel iteraties voor iets “simpels”

De thumbnails leken in het begin het gemakkelijkste onderdeel.

Dat waren ze absoluut niet.

We hebben eigenlijk nooit zelf thumbnails ontworpen. AI genereert ze volledig zelf. Het enige vaste vertrekpunt is ons JCast-logo. Daarbovenop geven we telkens een korte prompt mee om richting te geven aan de stijl of sfeer.

In theorie simpel. In praktijk bleek dat verrassend moeilijk consistent te krijgen.

Soms was een achtergrond veel te leeg. Dan weer veel te druk. Op bepaalde momenten leek het alsof AI plots verliefd was op gigantische oranje vormen die alle aandacht opeisten.

Na veel iteraties zijn we uiteindelijk uitgekomen op iets dat vrij consistent aanvoelt met onze stijl: abstracte achtergronden, subtiele vormen, genoeg detail zonder dat het logo verloren gaat.

En dan begint natuurlijk nog het layoutgedeelte.

Lange titels. Gastnamen. Elementen die plots overlappen wanneer een titel nét iets langer wordt dan verwacht.

Dus ja, uiteindelijk zaten we in Bash dynamisch hoogtes te berekenen via ImageMagick om alles automatisch correct te positioneren.

En als dat allemaal klaar is, genereert hetzelfde script ook automatisch een 1200×630 Open Graph-afbeelding voor sociale media. Zelfde achtergrond, ander formaat, andere layout — zodat de preview er op Bluesky of LinkedIn ook netjes uitziet zonder dat we daar apart iets voor moeten doen.

## Avatar generatie: AI blijft koppig

Voor gasten genereren we ook een mooie avatar op basis van een referentiefoto.

Daar hebben we ondertussen verrassend veel prompt-engineering in gestoken.

Want AI heeft bepaalde gewoontes waar je blijkbaar actief tegen moet vechten.

Bijvoorbeeld tanden.

We hebben letterlijk expliciete instructies toegevoegd zoals:

* mond gesloten
* geen tanden zichtbaar
* absoluut geen brede glimlach

En toch… af en toe beslist het model nog steeds dat iemand eruit moet zien alsof ze in een reclame voor tandpasta spelen.

Sommige dingen blijven blijkbaar moeilijk voor generative AI.

We merkten ook snel dat kledingkleuren vaak veel te dicht bij haarkleuren lagen. Mensen met warme bruine haren kregen standaard een bruine of oranje trui waardoor alles visueel samenklonterde.

Dus zijn we kleurdetectie beginnen te doen via ImageMagick.

We samplen nu automatisch de haarkleur uit de referentiefoto en filteren vervolgens kledingkleuren die daar te dicht bij liggen op het kleurenwiel.

Dat soort dingen begint als “even snel een scriptje schrijven” en eindigt plots in echte logica.

## Op een bepaald moment begonnen we het serieus te nemen

Wat gestart was als wat losse scripts begon meer en meer op echte software te lijken.

Dus hebben we er ook echte testing rond gebouwd:

* Bats-tests
* ShellCheck
* GitHub Actions
* tests op Linux én macOS

Het moeilijkste deel waren de externe APIs.

We gebruiken onder andere Deepgram, OpenAI en Anthropic. Uiteraard wil je die niet effectief aanspreken tijdens je tests.

Daarom hebben we alles injectable gemaakt. Elke `curl` call loopt via een variabele zodat we in tests een fake binary kunnen injecteren die fixtures teruggeeft.

Daardoor kunnen we volledige scripts testen zonder één echte API-call te doen.

## Het leukste deel? Dat het blijft evolueren

JCast Studio is nog altijd geen product. Het is gewoon een interne toolkit die blijft groeien telkens wanneer we ergens tegenaan lopen.

Nieuwe irritatie? Meestal een nieuw script.
Voor je het weet zit je opnieuw ImageMagick-commando’s te debuggen om middernacht.

En eerlijk: soms is het bouwen van de tooling bijna even leuk als de podcast zelf.

---

**Benieuwd naar de content achter deze tech?** Luister naar onze [laatste aflevering](https://jcast.dev/episodes/).

**Feedback of vragen?** Bereik ons via:
- **Instagram:** [@jcast_crew](https://www.instagram.com/jcast_crew/)
- **Email:** hello.jcast@gmail.com
