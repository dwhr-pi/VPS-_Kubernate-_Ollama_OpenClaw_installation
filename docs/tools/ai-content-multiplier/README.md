# AI-ContentMultiplier

AI-ContentMultiplier ist ein optionaler Workflow fuer Content-Repurposing im
Ultimate KI Setup.

Projektordner:

```text
C:\Users\danie\Documents\GitHub\content-multiplier
```

## Zweck

Aus einer Quelle werden mehrere Entwuerfe erzeugt:

- LinkedIn Posts
- Blogartikel
- Newsletter
- X Threads
- Facebook Posts
- FAQ
- SEO Keywords

Das Tool bringt eine eigene Workflow-Toolsammlung mit. Die Bausteine sind
dokumentiert unter:

```text
C:\Users\danie\Documents\GitHub\content-multiplier\docs\TOOL_COLLECTION.md
```

## Eingaben

- URL
- Firecrawl-Ergebnis
- PDF
- Webseite
- YouTube-Transkript
- LinkedIn-Text oder Export

## Modelle

Standard:

- Ollama lokal

Optional, nur mit bewusst gesetzten lokalen API-Keys:

- Gemini
- Claude
- OpenAI

## Ausgaben

- Markdown
- HTML
- DOCX
- PDF

## Integrationen

- OpenClaw als Workflow-Agent
- n8n als Automatisierungs- und Webhook-Schicht
- Home Assistant fuer Benachrichtigungen
- Nextcloud/myNextCloud fuer Eingabe- und Ausgabeordner

## Installationsstatus

Status: `optional`, `documentation-first`, `workflow`

Dieses Tool installiert standardmaessig keine schweren Abhaengigkeiten. Der
Setup-Wrapper legt nur lokale Konfigurations- und Ausgabeordner an und verweist
auf die Workflow-Dokumentation.

## Setup

```bash
bash scripts/tools/ai_content_multiplier_install.sh --status
bash scripts/tools/ai_content_multiplier_install.sh --dry-run
bash scripts/tools/ai_content_multiplier_install.sh
```

## Sicherheitsregeln

- Keine API-Keys ins Repository schreiben.
- Cloud-Modelle nur mit bewusster Freigabe aktivieren.
- Keine Inhalte automatisch veroeffentlichen.
- LinkedIn-/YouTube-/Webseiteninhalte nur im erlaubten Rahmen analysieren.
- Ergebnisse als Entwuerfe behandeln und manuell pruefen.
