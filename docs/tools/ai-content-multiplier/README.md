# AI-ContentMultiplier

AI-ContentMultiplier ist ein optionaler Workflow fuer Content-Repurposing im Ultimate KI Setup.

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

Das Tool bringt eine eigene Workflow-Toolsammlung mit. Die Bausteine sind dokumentiert unter:

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

Dieses Tool installiert standardmaessig keine schweren Abhaengigkeiten. Der Setup-Wrapper legt nur
lokale Konfigurations- und Ausgabeordner an und verweist auf die Workflow-Dokumentation.

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

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
