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
`/:/host:ro,rprivate`. Es gibt kein `mount --make-rshared /`, keine automatische
Aenderung am Host und keinen privileged Container. Der Root-Mount bleibt jedoch
ein weitreichender Lesezugriff auf Hostdaten und muss bewusst erlaubt werden.
Der Installationslauf ersetzt wie bisher die erzeugte Compose-Datei unter
`/opt/node_exporter`; eigene Anpassungen vor erneutem Lauf sichern.

Mit rprivate werden nachtraegliche Mount-Aenderungen nicht propagiert.
Zusatzlaufwerke/Mountpoints gegebenenfalls gezielt read-only einbinden und
Metriken kontrollieren. Auf geeignetem echtem Linux ist bewusst moeglich:

```bash
NODE_EXPORTER_MOUNT_PROPAGATION=rslave bash scripts/tools/node_exporter_install.sh
```

Diese Option repariert keinen inkompatiblen Host. Bei erneutem Mount-Fehler
den Standard verwenden, statt die Root-Mount-Propagation blind zu veraendern.

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
