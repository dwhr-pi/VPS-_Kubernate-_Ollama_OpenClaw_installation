# Security Guide

## Grundprinzipien

- keine API-Keys im Klartext in Git
- `.env`-Dateien nur lokal oder im Benutzer-Workspace pflegen
- Agenten mit Shell- oder Browser-Zugriff immer als risikobehaftet behandeln
- Trading- und Wallet-Funktionen standardmäßig im Safe-Mode

## Wichtige Maßnahmen

### Secrets

- nutze [configs/.env.example](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/configs/.env.example:1) als Vorlage
- echte Werte nur lokal eintragen
- optional später `age` oder `sops` ergänzen

### Gitleaks

```bash
bash scripts/operations/security_scan.sh
```

### Firewall

- `ufw` aktivieren
- nur benötigte Ports öffnen
- öffentliche WebUIs nie ohne Auth

### Fail2Ban

- für SSH und exponierte Dienste nutzen
- Basisskript im Repo vorhanden

### SSH-Hardening

- Passwort-Login nach Möglichkeit deaktivieren
- Public-Key-Only bevorzugen
- Root-Login verbieten

### Docker Rootless

- optional und sinnvoll für härtere Hosttrennung
- nicht jede Compose-Anleitung im Repo ist dafür bereits optimiert

### Shell-/Browser-Agenten

- niemals breit im Internet veröffentlichen
- nur lokal oder hinter Auth/Tunnel
- Schreibzugriff bewusst minimieren
