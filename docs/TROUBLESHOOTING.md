# Troubleshooting

## OpenClaw-Build bricht bei `write-cli-startup-metadata` mit `ETIMEDOUT` ab

Typisches Fehlerbild:

```text
Error: spawnSync /usr/bin/node ETIMEDOUT
...
at renderSourceRootHelpText
at writeCliStartupMetadata
```

Bedeutung:

- der eigentliche TypeScript-/pnpm-Build ist meist schon fast fertig
- der Fehler passiert beim Generieren der CLI-Startmetadaten
- auf WSL2/MiniPC-Systemen ist oft die Startumgebung zu träge oder die geerbte `PATH` aus Windows zu groß

Das Setup reagiert jetzt robuster:

- es baut OpenClaw mit einer bereinigten Linux-`PATH`
- es setzt konservative Build-Variablen wie:
  - `OPENCLAW_DISABLE_BUNDLED_SOURCE_OVERLAYS=1`
  - `OPENCLAW_DISABLE_BUNDLED_PLUGINS=1`
  - `OPENCLAW_DISABLE_P2P=1`
- und es versucht den Build bei genau diesem Timeout-Fall automatisch noch einmal

Wenn es trotzdem scheitert, findest du das letzte Build-Log hier:

```bash
/tmp/openclaw_build.log
```

## Häufige Probleme

### Versionsanzeige passt nicht

- `grep 'APP_VERSION=' setup_ultimate.sh`
- `git show origin/main:setup_ultimate.sh | grep 'APP_VERSION='`

Wenn du dich gerade nur in `~` befindest:

```bash
grep 'APP_VERSION=' ~/openclaw_ultimate_setup/setup_ultimate.sh
git -C ~/openclaw_ultimate_setup show origin/main:setup_ultimate.sh | grep 'APP_VERSION='
```

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
