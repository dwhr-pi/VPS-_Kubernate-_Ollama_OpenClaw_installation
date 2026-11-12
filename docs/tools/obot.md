# Obot: optionale MCP-Gateway-Quellen

## Zweck und Umfang

Tool **Obot**, Status `experimental` / `planned`: zentrale Verwaltung und
Absicherung von MCP-Verbindungen. Primaerquelle:
[obot-platform/obot](https://github.com/obot-platform/obot), MIT.
Pin: `251f96eb1ddae99d61e78a15b7a96115fc45630b`.
README und LICENSE werden zusaetzlich gegen feste SHA256 geprueft.

Der registrierte Installer verwaltet **nur GitHub-Quellen**, keine gebaute
Anwendung. Kein Docker-Fallback, kein Server-/Kubernetesstart und kein
Ausfuehren von Upstream-Entwicklungsskripten. Ein vollstaendiger nativer Build
mit UI und Betriebsabhaengigkeiten ist noch nicht abgenommen.

[Betriebsreview](../HYBRID_CLOUD_MCP.md): Authentifizierung, TLS, Datenbank,
Verschluesselung, Backup und Community-/Offline-Grenzen gesondert planen.
MCP-Gateway ist nicht gleich Modellanbieter oder MiniMax-/Together-API.
Keine Zugangsdaten oder freigegebenen MCP-Ziele durch Installation erzeugen.

## Lifecycle und Grenzen

Python 3 und Git, 2048 MiB Diskreserve **nur fuer die Quellen**.

```bash
bash scripts/tools/obot_install.sh --dry-run
# Explicit source preparation only.
bash scripts/tools/obot_install.sh
bash scripts/tools/obot_status.sh
bash scripts/tools/obot_doctor.sh
bash scripts/tools/obot_update.sh --dry-run
bash scripts/tools/obot_uninstall.sh --dry-run
```

`source_prepared` bezeichnet nur den Quellbestand. `installed: false` und
`runtime_tested: false` bleiben ausdruecklich erhalten. Doctor prueft Origin,
Commit, Vertragsdateien und Inventar, keine OAuth-/MCP-Funktion.
Update bleibt beim geprueften Pin. Uninstall ohne `--dry-run` entfernt nur
unveraenderte Dateien mit Besitznachweis unter
`~/.openclaw_ultimate_user_data/tools/obot/`; bei Aenderungen Abbruch.
Logs und andere Nutzerdaten bleiben erhalten. Uninstall ist idempotent.
Keine Unit fuer die reine Quellenverwaltung; Dienst-Unit, Build-Lock/SBOM,
Ressourcenmessung, Smoke-Test und Runtime-Abnahme bleiben bis zum nativen
Runtime-Rezept offen. Die Aufnahme ins Menue ist keine Produktionsfreigabe.

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
python3 -I -B scripts/tool_commands.py show obot
```

### SSH-Aktionen: `obot`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Obot` (ID `obot`) waehlen und die Einzelfreigaben lesen.
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
