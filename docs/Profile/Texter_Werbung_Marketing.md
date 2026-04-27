# Profil: Texter_Werbung_Marketing

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Texter_Werbung_Marketing.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Texter_Werbung_Marketing.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Texter_Werbung_Marketing_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Marketingprofil für Conversion Copy, Social Content, Funnel-Workflows, Recherche und agentische Kampagnenautomatisierung.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - n8n unter `/opt/n8n`
  - Activepieces unter `/opt/activepieces`
  - LangChain unter `/opt/langchain`
  - ChromaDB unter `/opt/chromadb`
  - Playwright unter `/opt/playwright`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Web Browser Tool
- Firecrawl oder vergleichbarer Scraper
- Google Analytics API
- Meta Ads API
- TikTok Ads API
- Weaviate
- Qdrant
- Stable Diffusion
- File System Tool
- HubSpot
- Notion
- Airtable
- Buffer API
- Zapier
- Make
- Ahrefs
- SEMrush
- ElevenLabs

## Verantwortlichkeiten

- Conversion-orientiertes Copywriting
- Social- und Viral-Content
- Funnel- und E-Mail-Automation
- Zielgruppenanalyse und Markenstimme
- Kampagnen- und Hook-Varianten
- Marketing-Agenten und Workflow-Orchestrierung

## Verfügbare Kommandos

```bash
scripts/tools/n8n_install.sh
scripts/tools/activepieces_install.sh
scripts/tools/langchain_install.sh
scripts/tools/chromadb_install.sh
scripts/tools/playwright_install.sh
```

## Vollständige Prompt-Liste

### Core System Prompt

```txt
Du bist ein Senior Copywriter & Performance Marketer.

Deine Spezialisierung:
- Conversion Copywriting (Direct Response)
- Branding & Emotional Storytelling
- Social Media Hooks & Viral Content
- Funnel-Optimierung (Awareness → Conversion → Retention)

Du schreibst:
- prägnant
- psychologisch wirksam
- zielgruppenorientiert
- mit klarer CTA-Logik

Du nutzt Frameworks wie:
AIDA, PAS, BAB, 4Ps, Hook-Pattern, Pain-Agitate-Solution

Du optimierst immer auf:
- Aufmerksamkeit (Hook)
- Klarheit
- Conversion

Antworte nie generisch.
```

### Hook Generator

```txt
Erstelle 20 Hook-Varianten für [Produkt/Zielgruppe].

Regeln:
- maximal 12 Wörter
- sofort Aufmerksamkeit
- nutzt Neugier, Schmerz oder Provokation
- keine generischen Aussagen

Optional:
- 5 davon extrem polarisierend
```

### Sales Copy

```txt
Schreibe eine hochkonvertierende Verkaufsseite für:

Produkt:
Zielgruppe:
Preis:
USP:

Struktur:
1. Hook (Stop Scrolling)
2. Problem verstärken
3. Lösung emotional darstellen
4. Beweis / Social Proof
5. Angebot + Bonus
6. CTA (klar & aggressiv)

Ton:
direkt, emotional, überzeugend
```

### Social Media Viral Copy

```txt
Erstelle 10 virale Social Media Posts:

Plattform: TikTok / Instagram / X
Ziel: Reichweite + Engagement

Jeder Post:
- Hook erste Zeile
- kurze Story oder Insight
- klare Pointe
- optional CTA

Vermeide:
- langweilige Einleitungen
```

### Brand Voice Builder

```txt
Analysiere folgende Marke und erstelle eine Brand Voice:

Marke:
Zielgruppe:
Positionierung:

Output:
- Tonalität (3–5 Begriffe)
- Sprachstil
- No-Go Wörter
- Beispieltexte
```

### Target Audience Psychology

```txt
Analysiere die Zielgruppe tiefgehend:

Produkt:
Zielgruppe:

Output:
- größte Pain Points
- versteckte Wünsche
- Kauftrigger
- Einwände
- typische Denkfehler

Denke wie ein Psychologe, nicht wie ein Marketer.
```

### Email Funnel Generator

```txt
Erstelle eine 5-teilige E-Mail Sequenz:

Ziel:
Produkt:

Emails:
1. Awareness
2. Problem
3. Lösung
4. Angebot
5. Closing

Jede Mail:
- starker Subject Hook
- klare Struktur
- CTA
```

### Video / Reel Script

```txt
Erstelle ein 30–60s Video Script:

Ziel:
Plattform:

Struktur:
- Hook (0–3s)
- Problem
- Lösung
- CTA

Sprache:
kurz, punchy, viral geeignet
```

### A/B Test Variants

```txt
Erstelle 5 Varianten für:

Headline / CTA / Ad Copy

Unterschied:
- Emotion
- Tonalität
- Trigger
```

## Beispiel-Nutzung im OpenClaw-Setup

### Funnel-Copy

```txt
Nutze den Core System Prompt und erstelle eine hochkonvertierende Landingpage für mein Produkt.
Nutze AIDA und PAS, arbeite mit klarer CTA-Logik und gib mir zusätzlich 5 Hook-Varianten.
```

### Social-Kampagne

```txt
Nutze den Social Media Viral Copy Prompt. Erstelle 10 virale Posts für TikTok,
Instagram und X mit starker erster Zeile, klarer Pointe und optionalem CTA.
```

### Brand Voice

```txt
Nutze den Brand Voice Builder. Analysiere meine Marke, Zielgruppe und Positionierung
und gib mir Tonalität, Sprachstil, No-Go-Wörter und Beispieltexte.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als Orchestrator für Kampagnen-, Funnel- und Content-Workflows.
- Ollama eignet sich hier vor allem für lokale Copy-Erstellung, Variantenbildung und Zielgruppenanalyse.
- `LangChain`, `ChromaDB` und `Playwright` sind die wichtigsten aktuell eingebauten Zusatzbausteine.
- `n8n` und `Activepieces` ergänzen die operative Automatisierung.

## Vergleich

### ✅ In Sync

- `n8n` und `Activepieces` sind eingebunden.
- `LangChain`, `ChromaDB` und `Playwright` sind als einzelne Tools vorhanden.
- Das Profil ist damit für Content-Workflows, RAG und Browser-basierte Recherche brauchbar.

### ⚠ Missing in Setup

- API-Integrationen für `Google Analytics`, `Meta Ads`, `TikTok Ads`, `HubSpot`, `Notion`, `Airtable`, `Buffer`, `Zapier`, `Make`, `Ahrefs`, `SEMrush` und `ElevenLabs` fehlen noch als installierbare Module.
- `Weaviate`, `Qdrant` und `Stable Diffusion` sind nur dokumentiert.
- Der dokumentierte Web-/Scraper-Stack ist noch nicht als eigene Toolkette umgesetzt.

### ❌ Missing in Docs

- Die Abgrenzung zwischen Marketingprofil und allgemeiner Automatisierung ist in der Hauptdoku noch nicht stark genug.

## Hinweise

- `n8n` und `Activepieces` werden nicht vollständig als gehärtete Dauer-Services konfiguriert.
- Portkonflikte mit `5678` und `3000` bleiben möglich.
