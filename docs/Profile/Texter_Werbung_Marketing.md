# Profil: Texter_Werbung_Marketing

## Überblick

Dieses Profil fokussiert im aktuellen Repo-Stand vor allem Workflow-Automatisierung.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Profil-Tooling:
  - n8n unter `/opt/n8n`
  - Activepieces unter `/opt/activepieces`
  - LangChain unter `/opt/langchain`
  - ChromaDB unter `/opt/chromadb`
  - Playwright unter `/opt/playwright`

## Verantwortlichkeiten

- Content-nahe Workflows
- Marketing-Automatisierung
- Integrationen zwischen Diensten

## Verfügbare Kommandos

```bash
scripts/tools/n8n_install.sh
scripts/tools/activepieces_install.sh
scripts/tools/langchain_install.sh
scripts/tools/chromadb_install.sh
scripts/tools/playwright_install.sh
```

## Beispielprompts

### Core System Prompt

```txt
Du bist ein Senior Copywriter und Performance Marketer.
Deine Spezialisierung:
- Conversion Copywriting
- Branding und Emotional Storytelling
- Social Media Hooks und Viral Content
- Funnel-Optimierung
Antworte nie generisch.
```

### Hook Generator

```txt
Erstelle 20 Hook-Varianten für [Produkt/Zielgruppe].
- maximal 12 Wörter
- sofort Aufmerksamkeit
- nutzt Neugier, Schmerz oder Provokation
```

## OpenClaw / Ollama Fit

- Ollama kann lokal Copy, Hooks, Funnel-Ideen und Varianten erzeugen.
- Playwright, LangChain und ChromaDB helfen beim Scraping, Memory und Retrieval von Kampagnenwissen.

## Vergleich

### ✅ In Sync

- n8n und Activepieces sind sowohl dokumentiert als auch script-seitig umgesetzt.
- LangChain, ChromaDB und Playwright decken zentrale lokale Zusatzbausteine aus der Quelldatei ab.

### ⚠ Missing in Setup

- Keine SEO-Tools
- Kein Social-Media-Management
- Keine dedizierten Textmodelle oder Copywriting-Agenten
- Analytics-APIs, CRM-Integrationen, ElevenLabs und SEO-Suiten bleiben bisher dokumentarisch.

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- n8n nutzt standardmäßig Port `5678`.
- Activepieces nutzt standardmäßig Port `3000` und kollidiert potenziell mit OpenClaw und weiteren Diensten.
