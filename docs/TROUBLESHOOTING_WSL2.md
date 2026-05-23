# Troubleshooting WSL2

## Linux meldet viel Speicher, Windows wenig

WSL2 sieht ein virtuelles Linux-Dateisystem. Die Anzeige kann hoch wirken, obwohl die Windows-Partition fast voll ist. Entscheidend ist beides:

- freier Speicher im Linux-Dateisystem
- freier Speicher auf dem Windows-Hostlaufwerk, auf dem die WSL-VHDX liegt

Wenn Windows nur wenige GB frei hat, koennen Builds trotz hoher Linux-Anzeige abbrechen.

## systemd

Viele Services brauchen systemd. Pruefe:

```bash
systemctl --version
```

Wenn systemd fehlt, WSL-Konfiguration pruefen und WSL neu starten.

## Python venv fehlt

Fehler:

```text
ensurepip is not available
```

Loesung:

```bash
sudo apt update
sudo apt install -y python3-venv python3-pip
```

## Docker-Socket

Fehler:

```text
permission denied while trying to connect to the docker API
```

Pruefen:

```bash
docker info
sudo docker info
```

Wenn nur `sudo docker` funktioniert, Installer muessen sudo-fallback oder klare Hinweise nutzen.

## DOS-Line-Endings

Shell-Dateien muessen LF statt CRLF haben:

```bash
file scripts/*.sh
```

