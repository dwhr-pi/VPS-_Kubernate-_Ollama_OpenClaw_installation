# OpenTelemetry: Docker-Rechte und Speicher

## Fehlerursache

`permission denied` am Docker-Socket entsteht hier vor dem Image-Pull.
Der Installer hat den vorhandenen `run_docker_compose_tool`-Helfer umgangen.
Er verwendet ihn jetzt fuer Daemon-Pruefung, Compose-Validierung und Start.
Ohne direkten Daemon-Zugriff verwendet der Helfer bewusst `sudo docker compose`.
Wenn auch sudo den Daemon nicht erreicht, bricht er ab; niemals `chmod 666`
am Docker-Socket verwenden. Docker-Gruppenmitgliedschaft entspricht weitreichenden
Root-Rechten. Das Skript aendert keine Gruppen und installiert Docker nicht automatisch.

## Vorbereitung

```bash
bash scripts/tools/opentelemetry_install.sh --check
bash scripts/tools/opentelemetry_install.sh --dry-run
bash scripts/tools/opentelemetry_install.sh
```

Die ersten beiden Befehle pruefen Speicher und Compose-Version, ohne sudo,
Image-Pull oder Dienststart. Der echte Lauf prueft zusaetzlich Daemon-Rechte.
Das Protokoll meldet nur 6,7 GB auf Windows-C:. Die neue konservative
Setup-Reserve ist 10 GiB auf C: bei erkannter WSL und 2 GiB auf `/opt`.
Das sind Schutzwerte, keine offiziellen Collector-Mindestanforderungen.
Docker-Daten koennen auf einem anderen Laufwerk liegen; dessen freien Speicher
zusaetzlich pruefen. Nicht erkannte Windows-Mounts werden nicht mitgeprueft.
Die Reserve garantiert keinen ausreichenden Platz fuer weitere Tools.

## Ports und bestehende Dateien

Neue Compose-Dateien binden OTLP gRPC 4317 und HTTP 4318 nur an `127.0.0.1`.
Die Receiver hoeren innerhalb des Containers auf dessen Netzwerkinterface,
damit die Host-Portweiterleitung funktioniert. Keine Admin-API wird freigegeben.
Siehe [Collector-Konfiguration](https://opentelemetry.io/docs/collector/configuration/).

Vorhandene `config.yaml` und `docker-compose.yml` werden nicht ueberschrieben.
Alte Bindungen `4317:4317`/`4318:4318` deshalb bewusst nach Sicherung auf
`127.0.0.1:4317:4317`/`127.0.0.1:4318:4318` umstellen. Diese Aenderung nimmt
der Installer nicht automatisch an einer bestehenden Installation vor.

## Pruefung nach Start

```bash
sudo docker compose -f /opt/opentelemetry/docker-compose.yml ps
sudo docker compose -f /opt/opentelemetry/docker-compose.yml logs --tail 50
```

Logs koennen Telemetrie-Inhalte enthalten; nicht ungeprueft weitergeben.
Ein erfolgreiches `up -d` ist kein Ende-zu-Ende-Test des OTLP-Empfangs.
Das vorhandene Image `0.100.0` bleibt fuer diese Rechtekorrektur unveraendert.
Ein Versionsupgrade mit Exporter-/Konfigurationsmigration und Image-Scan ist TODO.
Registry-Eintrag bleibt `planned`, bis ein echter Collector-Lauf geprueft ist.
Mock-Tests ersetzen weder einen Image-Pull noch einen Healthcheck.
