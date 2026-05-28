# WSL2 Troubleshooting

## Langsamer Start nach Windows-Neustart

WSL2 kann nach dem Neustart mehrere Minuten brauchen, besonders wenn Docker Desktop, grosse VHDX-Dateien oder viele Images beteiligt sind.

## Typische Checks

```powershell
wsl --status
wsl --list --verbose
wsl --shutdown
```

In Ubuntu:

```bash
df -h
free -h
systemctl is-system-running || true
docker version || true
```

## Speicher

Wenn die WSL-Distro auf C: liegt, ist freier Windows-C:-Speicher der praktische Engpass fuer VHDX-Wachstum. Unter 20 GB frei sollten schwere Installationen blockiert werden.

## Docker

- Docker Desktop starten und warten.
- Danach erst WSL/Setup starten.
- Bei `permission denied /var/run/docker.sock` entweder Usergruppe korrigieren oder bewusst `sudo docker` nutzen.

## Reparaturpfad

1. Setup stoppen.
2. Logs sichern.
3. Cleanup nur mit Vorschau starten.
4. Windows/WSL Speicher pruefen.
5. Erst danach grosse Tools wiederholen.
