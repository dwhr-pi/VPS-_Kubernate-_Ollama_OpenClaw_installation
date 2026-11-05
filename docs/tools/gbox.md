# GBOX

`babelcloud/gbox` ist eine CLI- und MCP-nahe Umgebung, mit der AI-Agenten Android-, Browser- und
Desktop-Umgebungen bedienen koennen.

## Einordnung im Setup

Primäres Profil fuer dein `myBox`-Projekt:

- `Android_App_Builder`

Zusaetzlich sinnvoll:

- `MCP_Agent_Tools`
- `Browser_Automation_Agent`
- `Local_AI_App_Builder`

## Quelle

- GitHub: `https://github.com/babelcloud/gbox`
- Lizenz laut Upstream: Apache-2.0

## Installation

Dieses Setup nutzt bewusst die GitHub-Quelle statt fertiger npm-/Homebrew-Pakete:

```bash
bash scripts/tools/gbox_install.sh
```

Optionaler Source-Build:

```bash
GBOX_BUILD_FROM_SOURCE=1 bash scripts/tools/gbox_install.sh
```

Der Source-Build erwartet laut Upstream Go, make, Node.js und pnpm via Corepack. Falls diese
Abhaengigkeiten fehlen, bricht der Installer ab und installiert keine fertigen Pakete im
Hintergrund.

## myBox-Nutzung

GBOX eignet sich fuer:

- Android-App-Tests und UI-Flows
- mobile Automation mit Testgeraeten
- MCP-Anbindung fuer Agenten
- Browser-/Desktop-Automation in kontrollierten Umgebungen
- Codex-/OpenClaw-gestuetzte myBox-Entwicklung

## Sicherheit

- Zuerst nur Testgeraete und Testkonten nutzen.
- Kein produktives Google-/Bank-/Shop-Konto in automatisierte Agenten geben.
- Externe GBOX-/Cloud-Umgebungen nur bewusst nach Login und Kostenpruefung nutzen.
- MCP-Server niemals offen ins Internet stellen.
- Android-Debugging nur auf Geraeten aktivieren, denen du vertraust.

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
python3 -I -B scripts/tool_commands.py show gbox
```

### SSH-Aktionen: `gbox`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`GBOX` (ID `gbox`) waehlen und die Einzelfreigaben lesen.
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
