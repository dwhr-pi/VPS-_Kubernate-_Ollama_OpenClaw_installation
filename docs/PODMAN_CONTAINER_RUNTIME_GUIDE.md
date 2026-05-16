# Podman Container Runtime Guide

## Einordnung

Podman ist eine Container-Runtime und eine Alternative bzw. Ergaenzung zu Docker. Im Ultimate KI Setup kann Podman fuer isolierte Tool-Stacks, lokale Dienste, Tests, Sandbox-Workflows und spaeter auch rootless Container genutzt werden.

Podman ist kein einzelnes KI-Tool und kein Webinterface. Es stellt die Laufzeit bereit, auf der andere Dienste oder Container-Workflows laufen koennen.

## Typische Log-Ausgabe

Bei der Installation koennen systemd-Dienste und Timer automatisch aktiviert werden, zum Beispiel:

```txt
Created symlink /etc/systemd/system/default.target.wants/podman-auto-update.service
Created symlink /etc/systemd/system/timers.target.wants/podman-auto-update.timer
Created symlink /etc/systemd/system/default.target.wants/podman-clean-transient.service
Created symlink /etc/systemd/system/default.target.wants/podman-restart.service
Created symlink /etc/systemd/system/default.target.wants/podman.service
Created symlink /etc/systemd/system/sockets.target.wants/podman.socket
```

Das bedeutet:

- `podman.socket`: stellt eine lokale Podman-API per systemd Socket bereit.
- `podman.service`: aktiviert den Podman API Service bei Bedarf.
- `podman-auto-update.timer`: kann Container automatisch aktualisieren, wenn sie entsprechend markiert sind.
- `podman-clean-transient.service`: raeumt temporaere Container-/Service-Zustaende auf.
- `podman-restart.service`: hilft beim Neustart von Podman-Units nach Boot/Systemstart.

## Sicherheitsbewertung

Auf einem privaten MiniPC oder einer WSL-Testumgebung ist Podman meist sinnvoll. Auf einem VPS sollte man bewusster entscheiden:

- Auto-Update kann Dienste unerwartet veraendern.
- Ein aktivierter Socket sollte nicht unkontrolliert extern erreichbar sein.
- Container sollten nicht blind mit `--privileged` laufen.
- Volumes mit Secrets oder `.env`-Dateien muessen klar getrennt bleiben.
- Rootless Podman ist fuer lokale Agenten- und Sandbox-Workflows vorzuziehen.

## Schnelltest

```bash
podman --version
podman info
systemctl status podman.socket
systemctl list-timers | grep podman || true
```

Rootless-Test:

```bash
podman run --rm hello-world
```

Wenn `hello-world` nicht verfuegbar ist:

```bash
podman run --rm docker.io/library/alpine:latest echo "Podman funktioniert"
```

## Auto-Update pruefen oder deaktivieren

Status pruefen:

```bash
systemctl status podman-auto-update.timer
systemctl list-timers | grep podman || true
```

Auto-Update deaktivieren, wenn reproduzierbare Setups wichtiger sind:

```bash
sudo systemctl disable --now podman-auto-update.timer
sudo systemctl disable --now podman-auto-update.service || true
```

Wieder aktivieren:

```bash
sudo systemctl enable --now podman-auto-update.timer
```

Empfehlung fuer dieses Setup: Auto-Update standardmaessig nur bewusst nutzen, nicht als versteckte Pflichtfunktion. Fuer produktionsnahe Tests lieber feste Image-Tags, Backups und manuelle Updates.

## Podman Socket

Status:

```bash
systemctl status podman.socket
```

Deaktivieren:

```bash
sudo systemctl disable --now podman.socket
sudo systemctl disable --now podman.service || true
```

Aktivieren:

```bash
sudo systemctl enable --now podman.socket
```

Der Socket sollte nicht nach aussen freigegeben werden. Wenn Remote-Zugriff noetig ist, dann nur ueber SSH, Tailscale oder eine bewusst abgesicherte Verbindung.

## Nutzung im Setup

Geeignete Kombinationen:

- `Code_Sandbox`: isolierte Testcontainer fuer Agenten-Patches.
- `OpenClaw`: spaeter als kontrollierter Container-Runner fuer Tool-Aufrufe.
- `n8n`, `Huginn`, `Flowise`, `Langfuse`: alternative Container-Ausfuehrung, wenn Compose/Podman-Compose gepflegt wird.
- `Security`: Trivy/Grype/Syft koennen Podman-Images scannen.
- `DevOps/SRE`: lokale Reproduktion von VPS- oder K3s-nahen Workflows.

## Docker-Kompatibilitaet

Viele Docker-Befehle lassen sich sinngemaess mit Podman ausfuehren:

```bash
podman ps
podman images
podman logs <container>
podman stop <container>
podman rm <container>
```

Compose-Unterstuetzung haengt vom installierten Paket ab:

```bash
docker compose version || true
podman-compose --version || true
```

## Deinstallation und Aufraeumen

Vor Deinstallation aktive Container pruefen:

```bash
podman ps -a
podman images
```

Dienste stoppen:

```bash
sudo systemctl disable --now podman-auto-update.timer || true
sudo systemctl disable --now podman.socket || true
sudo systemctl disable --now podman.service || true
```

Pakete nur entfernen, wenn keine anderen Setup-Teile Podman verwenden:

```bash
sudo apt remove podman podman-compose -y
```

Speicherplatz pruefen:

```bash
podman system df
```

Nicht blind ausfuehren, aber bei bewusstem Cleanup moeglich:

```bash
podman system prune
```

## TODO fuer das Setup

- Doctor-Check fuer `podman --version`, `podman info`, `podman.socket` und `podman-auto-update.timer`.
- Installationsoption: Auto-Update aktivieren/deaktivieren.
- Profilhinweis fuer MiniPC, VPS, WSL2 und K3s-nahe Testumgebungen.
- Security-Hinweis in Tool-Matrix: Socket nur lokal, keine Default-Exposition.
