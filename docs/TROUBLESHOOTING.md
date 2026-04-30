# Troubleshooting

## Häufige Probleme

### Versionsanzeige passt nicht

- `grep 'APP_VERSION=' setup_ultimate.sh`
- `git show origin/main:setup_ultimate.sh | grep 'APP_VERSION='`

### Menü oder Dialoge sehen kaputt aus

- Setup neu starten
- `dialog`-Farben prüfen
- bei harten TTY-Problemen Session neu öffnen

### OpenClaw oder Ollama fehlen im Status

- Statusdateien im Benutzer-Workspace prüfen
- `bash scripts/operations/status_report.sh`

### Repo-Update blockiert

- `git status`
- `git fetch origin --prune`
- `git reset --hard origin/main`
- `git clean -fd`

### Zu wenig Speicher

```bash
bash scripts/lib/resource_check.sh --summary
```

### Security-Scan

```bash
bash scripts/operations/security_scan.sh
```
