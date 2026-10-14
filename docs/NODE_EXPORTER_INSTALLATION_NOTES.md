# Node Exporter: Root-Mount unter WSL/Docker

## Ursache

Das Image wurde erfolgreich geladen. Der Containerstart scheitert an
`/:/host:ro,rslave`: Der Docker-Daemon kann den Quellmount nicht als
Shared/Slave-Mount verwenden. Dies ist kein GitHub-, Passwort- oder Pull-Fehler.
Der [Upstream](https://github.com/prometheus/node_exporter#docker) zeigt rslave
fuer Host-Monitoring; nicht jede WSL-/Docker-Umgebung erfuellt die Voraussetzungen.

## Neuer Standard

```bash
bash scripts/tools/node_exporter_install.sh --dry-run
bash scripts/tools/node_exporter_install.sh
```

Der Dry-Run zeigt ausschliesslich die geplante Compose-Datei. Standard ist
`NODE_EXPORTER_MOUNT_MODE=limited`: nur `/proc` und `/sys` read-only, kein
Root-Mount und kein privileged Container. Ausgewaehlt werden CPU, RAM, Load,
Kernelstatistiken, VM-, Netzwerk- und Blockgeraete-I/O-Metriken. Andere
Collector sind deaktiviert; insbesondere **keine Dateisystem-Kapazitaeten**.
Blockgeraete-I/O ist kein Ersatz fuer freien Speicherplatz.
Es gibt kein `mount --make-rshared /` und keinen automatischen Mount-Umbau.
Der Installationslauf ersetzt wie bisher die erzeugte Compose-Datei unter
`/opt/node_exporter`; eigene Anpassungen vor erneutem Lauf sichern.

Der Log vom 14. Oktober 2026 zeigt, dass Docker auch den zuvor vorgeschlagenen
Root-Mount mit rprivate ablehnt: Der Root-Bind umfasst das Daemon-Datenverzeichnis
`/var/lib/docker` und verlangt daher rslave/rshared. Die vorherige Korrektur
war fuer diese Umgebung nicht ausreichend. rprivate ist als Option entfernt.

Auf einem geeigneten echten Linux-Host ist fuer vollstaendigeres Host-Monitoring
bewusst das [Upstream-Root-Mount-Profil](https://github.com/prometheus/node_exporter#docker) moeglich:

```bash
NODE_EXPORTER_MOUNT_MODE=root bash scripts/tools/node_exporter_install.sh --dry-run
NODE_EXPORTER_MOUNT_MODE=root bash scripts/tools/node_exporter_install.sh
```

Das Root-Profil verwendet rslave und liest weitreichende Hostdaten. Es repariert
keinen inkompatiblen Host. Bei erneutem Mount-Fehler den Standard limited nutzen,
statt die Root-Mount-Propagation zu veraendern. Bereits gesetzte
`NODE_EXPORTER_MOUNT_PROPAGATION=rprivate` entfernen; sie wird bewusst abgelehnt.
Die alte rslave-Variable allein aktiviert keinen Root-Mount mehr.

## Zugriff und Messgrenzen

Host-Netzwerk/PID-Namespace bleiben erhalten; der HTTP-Listener wird auf
`127.0.0.1:9100` begrenzt. Ein Prometheus-Container im Bridge-Netz kann dessen
localhost nicht direkt erreichen. Scraping muss bewusst fuer die gewaehlte
Netzwerktopologie eingerichtet werden; Port 9100 nicht oeffentlich freigeben.

Bei Docker Desktop oder einem entfernten Docker-Kontext wird der Daemon-Host
gemessen, nicht automatisch die aufrufende WSL-Distro oder der Windows-Host.
Fuer native Windows-Metriken empfiehlt Upstream den windows_exporter.

## Kontrolle nach Installation

```bash
sudo docker compose -f /opt/node_exporter/docker-compose.yml ps
sudo docker compose -f /opt/node_exporter/docker-compose.yml logs --tail 50
curl --fail --max-time 10 http://127.0.0.1:9100/metrics
```

Diese Befehle sind manuelle Schritte auf dem Zielsystem. Ein erfolgreicher
Compose-Start beweist noch nicht, dass alle Collector-Metriken stimmen.
Das GitHub-Repository wird als Quelle geklont; ausgefuehrt wird weiterhin das
Container-Image, kein lokaler Source-Build. Der mutable `latest`-Tag bleibt fuer
diese Mount-Korrektur unveraendert; Release-/Digest-Pinning und echter WSL-Test
sind TODO. Tests im Worktree verwenden Mocks, keinen Docker-Daemon.
