# WebsiteFactory / WebBuild-Agent

WebsiteFactory ist ein neuer Workflow-Baustein fuer das Ultimate KI Setup.
Er erzeugt aus einem Marketing-Briefing ein GitHub-taugliches
Landingpage-Projekt.

## Eingaben

- Business-Name
- Branche
- Zielgruppe
- Stil
- Seitenanzahl
- CTA
- Farben
- Sprache

## Ausgabe

- Astro/Tailwind Landingpage
- Impressum-/Datenschutz-Platzhalter
- Kontaktformular-UI
- README
- CHANGELOG
- `docs/build-report.md`

## Lokaler Standard

- Ollama

Empfohlene lokale Modelle:

- `qwen2.5-coder`
- `deepseek-coder`
- `llama3.1`
- `llama3.2`

Optional:

- Claude API
- Gemini API
- OpenAI API

## Queue

- Datei: `tools/websitefactory/jobs/queue.json`
- Status: `pending`, `running`, `failed`, `done`
- nur ein Job gleichzeitig
- CPU/RAM-Schutz im Worker

## OpenClaw / n8n

OpenClaw:

- Briefing analysieren
- Queue-Job anlegen
- Build-Report bewerten

n8n:

- Formular/Webhook -> Queue-Job -> Build -> Report -> ZIP/GitHub

## Setup

```bash
bash scripts/tools/websitefactory_install.sh --status
bash scripts/tools/websitefactory_install.sh --dry-run
bash scripts/tools/websitefactory_install.sh
```

## Quellcode

- [WebsiteFactory Tool](C:/Users/danie/Documents/GitHub/VPS-_Kubernate-_Ollama_OpenClaw_installation/tools/websitefactory)
- [Setup-Wrapper](C:/Users/danie/Documents/GitHub/VPS-_Kubernate-_Ollama_OpenClaw_installation/scripts/tools/websitefactory_install.sh)
