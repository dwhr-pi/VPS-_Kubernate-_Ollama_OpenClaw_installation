# Troubleshooting WSL2, OpenClaw und Ollama

## WSL2 systemd

Symptom: Dienste starten nicht per `systemctl`.

Pruefen:

```bash
ps -p 1 -o comm=
```

Wenn nicht `systemd`, WSL-Konfiguration pruefen und WSL neu starten.

## Docker Socket Permission

Symptom:

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

Fix im Setup: Docker-Compose-Helfer nutzt `sudo docker compose`, wenn `docker info` ohne sudo fehlschlaegt.

## Ollama connection refused

Pruefen:

```bash
curl http://127.0.0.1:11434/api/tags
systemctl status ollama
```

## OpenClaw Token mismatch

- `.env` und `config.json` im Userdatenbereich pruefen.
- Keine Tokens in Git speichern.

## pnpm/node/Bun-Versionen

- Monorepos koennen feste Paketmanager erwarten.
- Activepieces nutzt aktuell Bun; n8n/pnpm braucht ausreichend RAM und Speicher.
- NodeSource-Node kann Ubuntu-Node-Pakete ersetzen; Logs pruefen.

## DOS-Line-Endings

Symptom:

```text
/usr/bin/env: bash\r: No such file or directory
```

Fix:

```bash
find scripts -name '*.sh' -print0 | xargs -0 dos2unix
```
