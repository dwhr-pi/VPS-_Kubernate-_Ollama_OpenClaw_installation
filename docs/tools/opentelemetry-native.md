# OpenTelemetry: nativer GitHub-Core-Collector

Stand: 27.10.2026. Experimenteller Buildpfad, keine Betriebsfreigabe.

Der Tools-Installer baut jetzt `otelcorecol` aus dem offiziellen
[Core-Repository](https://github.com/open-telemetry/opentelemetry-collector/tree/30add0562534958c3b4173fa307b5a3497d0bc9c).
Pin: `30add0562534958c3b4173fa307b5a3497d0bc9c`. Das
[Go-Modul](https://github.com/open-telemetry/opentelemetry-collector/blob/30add0562534958c3b4173fa307b5a3497d0bc9c/cmd/otelcorecol/go.mod)
fordert Go >=1.26.0. Der vorhandene native Installer nutzt `go mod download`, `go mod verify` und
`go build -mod=readonly`; keine Docker-Builds oder Images. Go-Moduldownloads bleiben erforderlich.
Ein Commit-Pin ist kein Sicherheitszertifikat.

```bash
# Nur Plan, keine Downloads:
bash scripts/tools/opentelemetry_install.sh --dry-run
# Bewusster Source-Build; passende Go-Basis erforderlich:
bash scripts/tools/opentelemetry_install.sh
# Freigabe fuer den vorhandenen privaten Go-Bootstrap nur bei Bedarf:
bash scripts/tools/opentelemetry_install.sh --install-build-deps
bash scripts/tools/opentelemetry_check.sh
```

Ziel: `~/.openclaw_ultimate_user_data/tools/opentelemetry/native-github/`. 8 GiB freie Startreserve;
Host-/WSL-Speicherpruefung bleibt aktiv. Der Installer startet keinen Collector, erstellt keinen
Dienst und oeffnet keine Ports. Nur Buildartefakte mit passendem Buildnachweis gelten als nativer
Installationsstatus. Ein vorhandenes `/opt/opentelemetry` oder ein Container ist kein solcher
Nachweis.

## Konfiguration und Migration

Der Core-Collector ist nicht die Contrib-Distribution. Die gepinnten
[Komponenten](https://github.com/open-telemetry/opentelemetry-collector/blob/30add0562534958c3b4173fa307b5a3497d0bc9c/cmd/otelcorecol/components.go)
enthalten OTLP, Batch, Memory Limiter sowie Debug-/OTLP-Exporter. Alte
`logging`-Exporter-Konfigurationen nicht ungeprueft uebernehmen. Kein automatischer Import der alten
Compose-Konfiguration, keine Parallelstarts auf denselben Ports. Eine spaetere native Konfiguration
muss OTLP auf `127.0.0.1:4317`/`127.0.0.1:4318` oder eine bewusst freigegebene private Adresse
binden. Egress, TLS/Auth, Redigierung und Aufbewahrung vor echtem Empfang pruefen. Debug-Exporter
koennen vertrauliche Inhalte loggen und sind kein sicherer Default.

Vor Umstellung alte Konfiguration sichern, Build und Konfigurationsvalidierung getrennt testen, dann
kontrolliertes Wartungsfenster und Rueckweg festlegen. Die native Deinstallation entfernt
ausschliesslich eigene validierte Builddateien; alte Container, Volumes, Logs und `/opt` bleiben
erhalten. Sie werden nicht automatisch abgeschaltet oder migriert. Eine echte
Linux-Build-/OTLP-Abnahme ist in diesem Windows-Arbeitsauftrag nicht erfolgt.

Siehe [Restliste und Grenzen](../DOCKER_REMAINDER_2026-10-27.md).

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
python3 -I -B scripts/tool_commands.py show opentelemetry
```

### SSH-Aktionen: `opentelemetry`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run opentelemetry --action status
python3 -I -B scripts/tool_commands.py run opentelemetry --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run opentelemetry --action install --apply --confirm opentelemetry:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run opentelemetry --action update --apply --confirm opentelemetry:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run opentelemetry --action uninstall --apply --confirm opentelemetry:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

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
