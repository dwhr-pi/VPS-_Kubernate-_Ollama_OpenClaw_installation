# Mosquitto: Port 9001 bereits belegt

Das Image wurde erfolgreich geladen. Docker scheitert beim Binden von `0.0.0.0:9001`, weil der Port
schon belegt ist. Das ist kein Download- oder Docker-Rechtefehler. Der Installer veroeffentlichte
diesen WebSocket-Port, ohne einen WebSocket-Listener zu konfigurieren. Diese Freigabe ist entfernt.

## Neuer Plan

```bash
bash scripts/tools/mosquitto_install.sh --dry-run
bash scripts/tools/mosquitto_install.sh
```

MQTT bleibt intern Port 1883, extern nur `127.0.0.1:1883`. Wenn auch 1883 belegt ist, bewusst einen
freien Hostport waehlen:

```bash
MOSQUITTO_HOST_PORT=1884 bash scripts/tools/mosquitto_install.sh --dry-run
MOSQUITTO_HOST_PORT=1884 bash scripts/tools/mosquitto_install.sh
```

Es werden keine konkurrierenden Dienste gestoppt oder Ports automatisch umverteilt. Die Registry
prueft weiterhin den Standardport 1883; bei eigener Portwahl auch Clients und Monitoring anpassen.
Portkonflikte werden weiterhin beim Compose-Start erkannt. Der Dry-Run zeigt nur den Plan.

## Konfiguration und Zugang

Vorhandene `config/mosquitto.conf` bleibt unveraendert. Fehlt sie, wird eine Minimalkonfiguration
mit `listener 1883`, `allow_anonymous false`, deaktivierter Persistenz und stdout-Logging angelegt.
**Clients bleiben gesperrt, bis Auth eingerichtet ist.** Keine Passwoerter werden erzeugt oder im
Repo gespeichert. Siehe
[Mosquitto-Authentifizierung](https://mosquitto.org/documentation/migrating-to-2-0/).

Auf dem Zielsystem bewusst eine Passwortdatei erstellen (interaktive Eingabe, kein Passwort als
Kommandozeilenargument):

```bash
sudo docker compose -f /opt/mosquitto/docker-compose.yml run --rm \
  --volume /opt/mosquitto/config:/credentials \
  mosquitto mosquitto_passwd -c /credentials/passwords mqtt_user
```

`-c` erstellt eine neue Datei und ueberschreibt eine vorhandene: nur bei der Ersteinrichtung
verwenden, fuer weitere Benutzer weglassen. Passwortdatei und ACL muessen fuer den Broker lesbar
sein; keine pauschalen 777-Rechte setzen. In `mosquitto.conf` danach bewusst
`password_file /mosquitto/config/passwords` und eine passende `acl_file` ergaenzen. Zugang nur auf
benoetigte Topics begrenzen. Anschliessend gezielt den Broker neu starten und authentifizierten
Pub/Sub testen.

Der Installer ersetzt wie bisher die erzeugte Compose-Datei. Eigene Anpassungen vor erneutem Lauf
sichern. Bestehende Persistenz-/Logging-Konfiguration benoetigt passende Rechte auf data/log; keine
automatische Migration dieser Daten. Der Container erhaelt das Konfigurationsverzeichnis nur
read-only.

## Netz und offene Punkte

Home Assistant auf einem anderen Rechner erreicht localhost nicht. MQTT fuer das Heimnetz nur
bewusst per VPN/geschuetzter Schnittstelle und Auth/TLS anbinden. WebSockets nur bei tatsaechlichem
Bedarf mit eigenem Listener, Auth und bewusst gewaehlter Freigabe ergaenzen, nicht automatisch Port
9001 oeffnen.

Die 8307 MB auf Windows-C: sind eine separate Speicherwarnung, nicht die Ursache dieses Fehlers.
Freien Speicher vor weiteren Installationen pruefen. GitHub wird als Quelle geklont; ausgefuehrt
wird das Container-Image, kein Source-Build. Image-Digest-Pinning, frueher Port-Preflight und echter
Broker- Pub/Sub-Test bleiben TODO. Worktree-Tests verwenden Mocks, keine WSL/Docker-Dienste.
