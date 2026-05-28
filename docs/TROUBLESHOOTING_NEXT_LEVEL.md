# Troubleshooting Next Level

Dieses Dokument ergaenzt `docs/TROUBLESHOOTING.md`.

## WSL2 langsam

Nach Windows-Neustart mehrere Minuten warten. Docker Desktop/WSL initialisieren lassen.

## Python nicht gefunden

Windows App Execution Alias deaktivieren oder Python installieren. In WSL bevorzugt `python3` nutzen.

## Ollama nicht erreichbar

```bash
curl http://127.0.0.1:11434/api/tags
```

## OpenClaw Token mismatch

Token in Client und Gateway neu setzen. Token nie committen.

## Docker permission denied

Docker-Gruppe/User pruefen oder bewusst `sudo docker` nutzen.

## Schweres Tool haengt

Log oeffnen, Speicher/RAM/Swap pruefen, Batch nicht blind fortsetzen.
