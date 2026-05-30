# AI Choir System

## Ziel
Das AI Choir System beschreibt, wie das Ultimate KI Setup kuenstliche Chor-Stimmen plant, erzeugt, rendert und sicher dokumentiert. Es ist ein Workflow-Konzept, kein automatischer Installer.

## Stimmgruppen
- Sopran: hohe Frauen- oder Kinderlage, nur mit rechtlich sauberem Material.
- Alt: tiefere Frauenlage.
- Tenor: hohe Maennerlage.
- Bass: tiefe Maennerlage.

## Chor-Groessen
- Frauenchor: 8 Stimmen.
- Maennerchor: 8 Stimmen.
- Gemischter Chor: 16 Stimmen.
- Kathedralchor: 32 Stimmen.
- Epic Choir: 64 Stimmen.

## Workflow
```mermaid
flowchart LR
  A["Text / Lyrics"] --> B["Melodie / MIDI / Noten"]
  B --> C["Stimmgruppen planen"]
  C --> D["OpenUtau / DiffSinger Demo"]
  D --> E["RVC / Seed-VC Timbre Varianten"]
  E --> F["FFmpeg Layer Mix"]
  F --> G["WAV / MP3 / Projektprotokoll"]
```

## Beispiel: Gemischter Chor mit 16 Stimmen
1. Vier Sopran-Layer anlegen.
2. Vier Alt-Layer anlegen.
3. Vier Tenor-Layer anlegen.
4. Vier Bass-Layer anlegen.
5. Kleine Pitch-/Timing-Variationen nutzen, damit der Chor nicht wie eine kopierte Einzelstimme klingt.
6. Mit FFmpeg oder einer DAW mischen.

## Ressourcenbedarf
- 8 Stimmen: 8-16 GB RAM, CPU moeglich, GPU angenehmer.
- 16 Stimmen: 16 GB RAM und Queue empfohlen.
- 32 Stimmen: GPU-Workstation empfohlen.
- 64 Stimmen: High-End Studio Setup, Job Queue und viel Zwischenspeicher.

## Sicherheits- und Rechtsregeln
- Nur eigene Stimmen oder Stimmen mit dokumentierter Einwilligung trainieren.
- KI-Chor bei Veroeffentlichung kennzeichnen.
- Keine realen Chorsaenger oder Kuenstler imitieren, wenn keine Freigabe vorliegt.
- Rohdaten, Stimmproben und Checkpoints nicht ins Repository schreiben.

## Empfohlene Tools
- OpenUtau fuer Arrangement.
- DiffSinger fuer KI-Gesang.
- RVC oder Seed-VC fuer Timbre-Varianten.
- UVR5 fuer Stimm-/Instrumententrennung.
- FFmpeg fuer Mixdown, Normalisierung und Export.

