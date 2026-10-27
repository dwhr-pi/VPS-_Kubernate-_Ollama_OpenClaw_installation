# OpenTelemetry: nativer Build und historische Docker-Hinweise

> Aktuell seit 27.10.2026: Der Tools-Installer verwendet einen
> [nativen GitHub-Core-Build](tools/opentelemetry-native.md), ohne Docker oder
> automatischen Collector-Start. Die folgenden Docker-Befehle und Aussagen zu
> Opt-in, Status und Reserven dokumentieren ausschliesslich den historischen
> Installer. `OPENTELEMETRY_INSTALL_DOCKER` aktiviert den alten Weg nicht mehr.

## Historischer Stand: Docker-Rechte und Speicher

## Fehlerursache

`permission denied` am Docker-Socket entsteht hier vor dem Image-Pull.
Der Installer hat den vorhandenen `run_docker_compose_tool`-Helfer umgangen.
Er verwendet ihn jetzt fuer Daemon-Pruefung, Compose-Validierung und Start.
Ohne direkten Daemon-Zugriff verwendet der Helfer bewusst `sudo docker compose`.
Wenn auch sudo den Daemon nicht erreicht, bricht er ab; niemals `chmod 666`
am Docker-Socket verwenden. Docker-Gruppenmitgliedschaft entspricht weitreichenden
Root-Rechten. Das Skript aendert keine Gruppen oder Socket-Rechte.

## Vorbereitung

```bash
bash scripts/tools/opentelemetry_install.sh --check
bash scripts/tools/opentelemetry_install.sh --dry-run
bash scripts/tools/opentelemetry_install.sh
```

Check prueft Speicher und sichtbares Compose, ohne sudo/Download/Dienststart.
Dry-Run zeigt auch bei fehlendem Docker den Plan, ohne es bereitzustellen.
Der echte Lauf prueft zusaetzlich Daemon-Rechte.
Das Protokoll meldet nur 6,7 GB auf Windows-C:. Die neue konservative
Setup-Reserve ist 10 GiB auf C: bei erkannter WSL und 2 GiB auf `/opt`.
Das sind Schutzwerte, keine offiziellen Collector-Mindestanforderungen.
Docker-Daten koennen auf einem anderen Laufwerk liegen; dessen freien Speicher
zusaetzlich pruefen. Nicht erkannte Windows-Mounts werden nicht mitgeprueft.
Die Reserve garantiert keinen ausreichenden Platz fuer weitere Tools.

## Docker fehlt im PATH

Die Meldung beweist nicht, dass Docker auf dem gesamten Rechner fehlt. Unter
WSL kann Docker Desktop vorhanden sein, aber dessen Integration fuer diese
Distro fehlen. Diese Variante zuerst bewusst pruefen. Der Installer repariert
keine Windows-/WSL-Einstellungen und startet keinen bestehenden Daemon neu.

Beim echten Lauf wird eine fehlende Docker-/Compose-Abhaengigkeit jetzt
gefuehrt angeboten, mit Standard Nein. Nicht-interaktiv ist bewusst moeglich:

```bash
OPENTELEMETRY_INSTALL_DOCKER=1 bash scripts/tools/opentelemetry_install.sh
```

Das Opt-in erlaubt ausschliesslich die Paketbereitstellung im Installationslauf;
Check/Dry-Run installieren auch damit nichts. Vorhandenes Docker/Compose wird
weiterverwendet. Fehlt nur Compose, wird bei erkannter Paketfamilie nur dessen
Plugin angefordert. Bei unbekanntem Client (etwa Docker Desktop) erfolgt kein
Engine-Wechsel. Mit vorhandenem Docker-Repository werden CE-Pakete verwendet;
ansonsten Ubuntu docker.io/docker-compose-v2, sofern dort verfuegbar.
Bestehendes containerd.io ohne passenden CE-Kandidaten fuehrt zum Abbruch.
`apt --no-remove` verbietet automatische Paketentfernungen.

Es gibt kein `curl | sh`, keine Gruppenaenderung und keine pauschale Reparatur
einer laufenden Engine. Die Installation einer neuen Engine kann jedoch durch
Paket-Skripte Dienste starten und Netzwerk-/Firewall-Regeln beeinflussen. Siehe
[Docker-Installationshinweise](https://docs.docker.com/engine/install/ubuntu/).
Bleibt der Daemon unerreichbar, bricht der Installer ab; systemd/WSL-Konfiguration
muss dann bewusst geprueft werden. Kein Erfolg ohne nutzbaren Daemon.

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
