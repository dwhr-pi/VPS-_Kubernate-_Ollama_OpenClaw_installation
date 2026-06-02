# WebsiteFactory / WebBuild-Agent

WebsiteFactory ist ein lokaler Workflow-Prototyp fuer das Ultimate KI Setup.
Aus einem Marketing-Prompt erzeugt das Tool ein GitHub-taugliches
Landingpage-Projekt auf Basis von Astro plus Tailwind CSS.

## Status

Status: `optional`, `prototype`, `workflow-first`

Das Setup installiert hier bewusst keine schweren Node-, Browser- oder
Cloud-Abhaengigkeiten automatisch. Standard ist lokal mit Ollama. Claude,
Gemini und OpenAI bleiben optional und muessen bewusst ausserhalb des Repos
konfiguriert werden.

## Zweck

- Briefing verstehen
- Zielgruppe, Angebot, Farben und Struktur ableiten
- Projektordner erzeugen
- lokales Preview vorbereiten
- Build-Checks und Screenshot-Schritte anstossen
- Ergebnis als GitHub-ready Projekt mit Doku ablegen

## Lokaler Standard

Default-Provider:

- `ollama`

Empfohlene lokale Modelle:

- `qwen2.5-coder`
- `deepseek-coder`
- `llama3.1`
- `llama3.2`

## CLI

```bash
node src/cli.mjs create --brief-file templates/landingpage-brief.example.json
node src/cli.mjs queue-add --brief-file templates/landingpage-brief.example.json
node src/cli.mjs queue-status
node src/queue-worker.mjs
```

## Shell-Wrapper

- `scripts/create-site.sh`
- `scripts/run-preview.sh`
- `scripts/check-build.sh`
- `scripts/screenshot.sh`

## Integrationen

- OpenClaw fuer Briefing, Queue und Review
- n8n fuer Formular -> Queue -> Report
- GitHub fuer Commit/Export

## Sicherheit

- Keine API-Keys im Repo
- `.env.example` nur als Vorlage
- keine automatische Veroeffentlichung
- Queue laeuft standardmaessig seriell
