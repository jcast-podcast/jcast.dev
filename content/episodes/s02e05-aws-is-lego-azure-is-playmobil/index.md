---
season: 2
episode: 5
title: "AWS is Lego, Azure is Playmobil"
date: 2026-09-07
description: "In deze aflevering schuiven we aan met Pieter Vincken, public cloud solution architect bij Cegeka, voor een eerlijk en onverbloemd gesprek over alles wat de cloud écht inhoudt. We hebben het over infrastructuur als code, stille kostenvallen zoals logs en datatransfer, de grote drie cloudproviders vergeleken, en de vraag of cloud nu eigenlijk veilig is. Een aflevering die zowel de beginnende developer als de doorgewinterde architect aan het denken zet."
thumbnail: "/images/thumbnails/s02e05-aws-is-lego-azure-is-playmobil.webp"
social_image: "social.png"
player: "https://share.transistor.fm/e/2a5d4bcf"
transistor_id: "3513922"
section: episodes
guests:
  - id: "pieter_vincken"
topics:
  - "Architectuur"
  - "Tooling"
  - "Software Engineering"
---

In deze aflevering verwelkomen we **Pieter Vincken**, public cloud solution architect bij Cegeka. Pieter rolde de cloud in via een startup in Geel waar hij als enige technische medewerker al snel merkte dat een server op zolder bij de baas, liefkozend *Iejoor* gedoopt, nu eenmaal geen solide basis vormt voor klanten. Sindsdien heeft hij alle grote cloudproviders van binnenuit leren kennen en droomt hij nog van de dag dat iemand hem vraagt een Alibaba Cloud project te begeleiden.

Het gesprek begint bij de fundamenten: *wat is cloud eigenlijk?* Pieter omschrijft het als een combinatie van ijzer en automatisatie. De hardware ligt er altijd aan ten grondslag, maar wat cloud onderscheidt van een gewone server is de laag van diensten en automatisatie die ervoor zorgt dat jij als developer nooit hoeft na te denken over wat er gebeurt als een stuk hardware ermee stopt. **Google** was daar een van de eersten in: hun infrastructuur moest zo gebouwd zijn dat het uitvallen van een volledig rek geen impact had op Gmail of YouTube. Dat principe kleurt vandaag nog altijd de hele cloudindustrie.

Een groot deel van het gesprek gaat over **infrastructuur als code**. Vroeger volstond het om een handvol servers manueel te configureren via runbooks of PowerShell-scripts. Met de explosie aan managed services groeide de nood aan herhaalbare, betrouwbare automatisatie. **Terraform** en **OpenTofu** laten je infrastructuur beschrijven als code, zodat wat in je testomgeving werkt met dezelfde garanties in productie terechtkomt. De droom van volledig cloudprovider-agnostische code is mooi, maar in de praktijk bijna altijd een brug te ver: de abstracties worden zo generiek dat ze meer problemen creëren dan oplossen.

**Kosten** zijn een thema dat in elke cloudmigratie terugkomt. Pieter maakt duidelijk dat de veronderstelling dat cloud altijd goedkoper is, lang niet altijd klopt. Stabiele workloads die 24 op 7 draaien zijn vaak voordeliger on-premise. Maar workloads die je 's nachts en in het weekend kunt afzetten, kunnen tot *60 procent* goedkoper uitvallen in de public cloud. Wat veel developers onderschatten zijn de verborgen kosten van datatransfer en logging. Op een eigen datacenter is logging vrijwel gratis, in de public cloud betaal je per gigabyte. Pieter schat dat Azure Log Analytics rond de *twee en een halve euro per gigabyte* kost voor verwerking. Debug-logs in productie aanlaten is dus niet alleen een securityrisico, het is ook gewoon erg duur.

Over **security** bestaat er lang een hardnekkig misverstand: publieke cloud is ofwel totaal onveilig ofwel per definitie veiliger dan on-premise. Pieter nuanceert beide standpunten. De grote cloudproviders bieden krachtige beveiligingsfunctionaliteiten aan, van DDoS-bescherming tot web application firewalls, maar je moet ze wel bewust aanzetten en correct configureren. In een traditioneel datacenter zijn netwerk, firewall en VM-beheer drie aparte teams. In de cloud wordt van developers verwacht dat ze dat allemaal zelf doen. Dat is een cultuurverschil dat niet genoeg wordt erkend, en het is precies waar dingen misgaan.

In de **quick fire ronde** kiest Pieter voor OpenTofu boven Terraform, zegt hij ja op multicloud en kiest hij uiteindelijk voor AWS. Zijn vergelijking is meteen een klassieker: **AWS is Lego**, je kunt alles aan elkaar knutselen en zelf bouwstenen combineren die niet voor elkaar gemaakt zijn. **Azure is Playmobil**, je kunt er mooie dingen mee bouwen maar het dak van het ene huis past niet op een ander huis. Google Cloud heeft hij nog geen goede metafoor voor gevonden, al is het wel de provider die het snelst diensten lanceert én deprecateert, soms met een aankondigingstermijn van amper *zes maanden*.

Pieter sluit af met een eerlijk oorlogsverhaal over een script dat per ongeluk alle interne Nexus-repositories wegveegde, en hoe een goed team tot halftwee 's nachts aan de slag ging om alles te reconstrueren op basis van een backup die *drie maanden* oud bleek te zijn. De les? Een goede **postmortem zonder schuldigen**, actieve backups die ook getest worden, en altijd goed nadenken over wat er gebeurt als een centraal systeem uitvalt. Want als je Nexus wegvalt en Kubernetes een container opnieuw wil inladen, moet die container ergens vandaan komen. Luister naar deze aflevering voor een gesprek dat je kijk op de cloud gegarandeerd wat scherper maakt.
