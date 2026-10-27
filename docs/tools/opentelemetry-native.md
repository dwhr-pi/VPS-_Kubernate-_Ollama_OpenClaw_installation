# OpenTelemetry: nativer GitHub-Core-Collector

Stand: 27.10.2026. Experimenteller Buildpfad, keine Betriebsfreigabe.

Der Tools-Installer baut jetzt `otelcorecol` aus dem offiziellen
[Core-Repository](https://github.com/open-telemetry/opentelemetry-collector/tree/30add0562534958c3b4173fa307b5a3497d0bc9c).
Pin: `30add0562534958c3b4173fa307b5a3497d0bc9c`. Das
[Go-Modul](https://github.com/open-telemetry/opentelemetry-collector/blob/30add0562534958c3b4173fa307b5a3497d0bc9c/cmd/otelcorecol/go.mod)
fordert Go >=1.26.0. Der vorhandene native Installer nutzt `go mod download`,
`go mod verify` und `go build -mod=readonly`; keine Docker-Builds oder Images.
Go-Moduldownloads bleiben erforderlich. Ein Commit-Pin ist kein Sicherheitszertifikat.

```bash
# Nur Plan, keine Downloads:
bash scripts/tools/opentelemetry_install.sh --dry-run
# Bewusster Source-Build; passende Go-Basis erforderlich:
bash scripts/tools/opentelemetry_install.sh
# Freigabe fuer den vorhandenen privaten Go-Bootstrap nur bei Bedarf:
bash scripts/tools/opentelemetry_install.sh --install-build-deps
bash scripts/tools/opentelemetry_check.sh
```

Ziel: `~/.openclaw_ultimate_user_data/tools/opentelemetry/native-github/`.
8 GiB freie Startreserve; Host-/WSL-Speicherpruefung bleibt aktiv.
Der Installer startet keinen Collector, erstellt keinen Dienst und oeffnet keine Ports.
Nur Buildartefakte mit passendem Buildnachweis gelten als nativer Installationsstatus.
Ein vorhandenes `/opt/opentelemetry` oder ein Container ist kein solcher Nachweis.

## Konfiguration und Migration

Der Core-Collector ist nicht die Contrib-Distribution. Die gepinnten
[Komponenten](https://github.com/open-telemetry/opentelemetry-collector/blob/30add0562534958c3b4173fa307b5a3497d0bc9c/cmd/otelcorecol/components.go)
enthalten OTLP, Batch, Memory Limiter sowie Debug-/OTLP-Exporter.
Alte `logging`-Exporter-Konfigurationen nicht ungeprueft uebernehmen.
Kein automatischer Import der alten Compose-Konfiguration, keine Parallelstarts
auf denselben Ports. Eine spaetere native Konfiguration muss OTLP auf
`127.0.0.1:4317`/`127.0.0.1:4318` oder eine bewusst freigegebene private Adresse
binden. Egress, TLS/Auth, Redigierung und Aufbewahrung vor echtem Empfang pruefen.
Debug-Exporter koennen vertrauliche Inhalte loggen und sind kein sicherer Default.

Vor Umstellung alte Konfiguration sichern, Build und Konfigurationsvalidierung
getrennt testen, dann kontrolliertes Wartungsfenster und Rueckweg festlegen.
Die native Deinstallation entfernt ausschliesslich eigene validierte Builddateien;
alte Container, Volumes, Logs und `/opt` bleiben erhalten. Sie werden nicht
automatisch abgeschaltet oder migriert. Eine echte Linux-Build-/OTLP-Abnahme
ist in diesem Windows-Arbeitsauftrag nicht erfolgt.

Siehe [Restliste und Grenzen](../DOCKER_REMAINDER_2026-10-27.md).
