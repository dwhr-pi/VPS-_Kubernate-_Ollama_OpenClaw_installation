# Airbyte, abctl und Kubernetes

Airbyte wird in diesem Setup nicht mehr ueber den alten Docker-Compose-Pfad mit `airbyte/webapp:latest` gestartet. Dieser Pfad ist veraltet und das Image existiert nicht mehr zuverlaessig.

Der aktuelle Installer nutzt:

- Airbyte-Quelle: <https://github.com/airbytehq/airbyte>
- Airbyte-CLI/Installer: <https://github.com/airbytehq/abctl>
- abctl-Ref: standardmaessig `v0.30.4`, anpassbar ueber `AIRBYTE_ABCTL_REF`

Der abctl-Build wird bewusst auf einen GitHub-Release-Tag gesetzt. Ein Build direkt von einem beliebigen Branch kann Versionswerte wie `v0.0.0-...` erzeugen und Airbyte selbst meldet dann unter Umstaenden ein veraltetes `abctl`.

## Was `abctl local install` wirklich macht

`abctl local install` erstellt lokal einen eigenen Kubernetes-Cluster auf Basis von `kind`. Der Cluster heisst typischerweise:

```text
airbyte-abctl
```

Das ist wichtig: Dieser Cluster ist nicht automatisch derselbe Kubernetes-Pfad wie das restliche Ultimate-KI-Setup mit K3s, spaeteren GPU-Worker-Nodes oder eigener Cluster-Orchestrierung.

## Passt das zu unserem Kubernetes?

Ja, aber nur als isolierte lokale Airbyte-Instanz. Ohne weitere Konfiguration integriert sich `abctl` nicht automatisch in den geplanten K3s-/Kubernetes-Betrieb des Setups.

Sinnvolle Betriebsarten:

| Variante | Beschreibung | Empfehlung |
|---|---|---|
| `abctl` lokal | Airbyte startet eigenen `kind`-Cluster | Einfacher Start, aber speicherintensiv |
| Bestehender K3s-Cluster | Airbyte per Helm/Manifest in eigenen Namespace installieren | Spaeter sinnvoll, aber deutlich komplexer |
| Externer Server | Airbyte auf separatem Host/VPS betreiben | Gut, wenn WSL-Speicher knapp ist |

## Warum braucht Airbyte so viel Speicher?

Airbyte besteht nicht nur aus einem kleinen Binary, sondern aus vielen Komponenten:

- Web UI
- Server
- Worker
- Bootloader
- Temporal
- Datenbank
- Connector-Sidecars
- Workload-Komponenten
- Container-Images und Kubernetes-Layer

Darum kann der Pull laenger dauern und viele Gigabyte belegen. Unter WSL ist zusaetzlich der Windows-Host-Speicher auf `C:` entscheidend, weil Docker-/WSL-Daten dort landen koennen.

## Speicherplatz-Wache im Installer

Der Airbyte-Installer bricht vor `abctl local install` ab, wenn zu wenig Speicher erkannt wird:

- mindestens 32 GB freier Linux-/WSL-Speicher
- unter WSL mindestens 20 GB freier Windows-Host-Speicher auf `C:`
- empfohlen sind eher 64 GB freier Speicher

Diese Pruefung verhindert, dass Airbyte die WSL oder Windows-Partition waehrend des Image-Pulls vollschreibt.

## Wiederholte Readiness-/Liveness-Probe-Warnungen

Beim Start kann `abctl` Meldungen wie diese ausgeben:

```text
Readiness probe failed: Get "http://10.244.x.x:9000/": connect: connection refused
Liveness probe failed: Get "http://10.244.x.x:9000/": connect: connection refused
```

Einige Warnungen direkt nach dem Start sind normal, weil Kubernetes Pods schon prueft, waehrend Airbyte-Komponenten noch hochfahren. Wenn die gleiche Worker-Meldung jedoch lange wiederholt wird, ist das meist ein Hinweis auf:

- zu wenig freier Speicher oder RAM
- sehr langsame WSL-/Docker-Image-Pulls
- einen abgestuerzten Worker-Pod
- einen alten oder teilweise kaputten `kind`-/Airbyte-Rest
- Port- oder Netzwerkprobleme im lokalen Cluster

Der Installer gibt vor `abctl local install` deshalb einen Hinweis aus und sammelt bei einem Abbruch automatisch Docker-/Kubernetes-Diagnosen, soweit `docker` und `kubectl` verfuegbar sind.

Nuetzliche manuelle Diagnosebefehle:

```bash
docker system df
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | grep -Ei 'airbyte|kind|abctl|temporal'
kubectl --context kind-airbyte-abctl -n airbyte-abctl get pods -o wide
kubectl --context kind-airbyte-abctl -n airbyte-abctl get events --sort-by=.lastTimestamp | tail -n 40
```

Wenn Airbyte nach einem Fehlversuch erneut installiert werden soll, zuerst Speicher freigeben und alte Reste nur bewusst entfernen. Docker-Volumes werden vom Cleanup-Skript absichtlich nicht automatisch geloescht.

Der Installer klassifiziert diese Fehler inzwischen automatisch, wenn `abctl` abbricht:

- `TLS handshake timeout`: lokaler Kubernetes-/kind-API-Server reagiert zu langsam oder ist ueberlastet
- `Readiness probe failed` / `Liveness probe failed`: Airbyte-Komponente startet nicht stabil genug
- `A new release of abctl is available`: verwendeter abctl-Build ist nicht auf dem erwarteten Release-Stand

## Spaetere Integration in den Setup-Kubernetes-Pfad

Fuer eine echte Integration in das geplante Kubernetes des Ultimate-KI-Setups waeren mindestens noetig:

- eigener Namespace, z. B. `airbyte`
- StorageClass/PersistentVolumes fuer Datenbank und Logs
- Ressourcenlimits fuer Worker und Connectoren
- Ingress nur hinter Tailscale, Cloudflare Access oder lokalem Reverse Proxy
- Secret-Handling ausserhalb des Repos
- klare Trennung zwischen Test- und Produktiv-Connectoren
- Healthchecks und Backup-Strategie

Bis dahin ist `abctl` die pragmatische lokale Variante, aber sie sollte als schwergewichtiges Tool behandelt werden.
