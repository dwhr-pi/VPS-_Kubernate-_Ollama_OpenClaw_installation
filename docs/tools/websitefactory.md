# WebsiteFactory / WebBuild-Agent

WebsiteFactory ist ein neuer Workflow-Baustein fuer das Ultimate KI Setup. Er erzeugt aus einem
Marketing-Briefing ein GitHub-taugliches Landingpage-Projekt.

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

- [WebsiteFactory Tool](../../tools/websitefactory/README.md)
- [Setup-Wrapper](../../scripts/tools/websitefactory_install.sh)

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
python3 -I -B scripts/tool_commands.py show websitefactory
```

### SSH-Aktionen: `websitefactory`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`WebsiteFactory / WebBuild-Agent` (ID `websitefactory`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
