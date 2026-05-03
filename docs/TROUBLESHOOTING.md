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

### `n8n` Build aus dem GitHub-Monorepo schlägt fehl

Typische Hinweise:

```text
WARN Failed to create bin ...
ELIFECYCLE Command failed.
ERROR run failed: command exited (1)
```

Bedeutung:

- das Upstream-Monorepo von `n8n` ist build-technisch empfindlich
- auf MiniPC-/WSL2-Systemen kann der direkte Build aus der aktuellen GitHub-Quelle scheitern
- die Warnungen zu fehlenden `dist/*.js`-Dateien deuten oft auf einen unvollständigen oder fehlschlagenden Turbo-/Workspace-Build hin

Das Setup reagiert jetzt robuster:

- zuerst wird weiterhin der GitHub-Quellcode-Build versucht
- wenn dieser Build scheitert, richtet das Setup automatisch eine stabilere lokale Runtime-Fallback-Installation ein
- dabei wird `n8n` lokal unter `/opt/n8n-runtime` installiert und nach `/usr/local/bin/n8n` verlinkt

Wichtig:

- Das ist kein vollständiger Quellcode-Build des Monorepos mehr, sondern ein nutzbarer Fallback für den Betrieb.
- Wenn du das volle Monorepo wirklich selbst bauen willst, ist meist ein genauer Blick auf den gerade ausgecheckten Upstream-Stand nötig.

### Huginn kehrt nach der Installation ohne klaren Hinweis ins Setup zurueck

Typische Hinweise:

```text
Could not loading huginn settings from .env file.
```

oder ein Ruecksprung direkt ins Setup, obwohl `Huginn` noch nicht eindeutig als installiert markiert wird.

Bedeutung:

- Huginn braucht mehr als nur das GitHub-Repository und `bundle install`
- zusaetzlich muessen `.env`, `APP_SECRET_TOKEN` und die Datenbankparameter sauber gesetzt sein
- wenn diese Konfiguration fehlt, schlagen Datenbank- oder Startschritte spaeter fehl

Das Setup reagiert jetzt robuster:

- standardmaessig wird Huginn auf eine stabile Release-Referenz gesetzt:
  - `v2022.08.18`
- alternativ kannst du bewusst einen anderen Upstream-Stand testen:
  - `HUGINN_REPO_REF=master`
  - oder einen anderen Tag/Branch
- die Meldung `development test` bei Bundler ist **keine Huginn-Version**, sondern nur die ausgeschlossene Gem-Gruppe:
  - `bundle config set --local without "development test"`
- wenn die Datenbankkonfiguration in `.env` noch unvollstaendig ist, markiert das Setup Huginn jetzt als **vorbereitet** statt kommentarlos fehlzuschlagen

Praktischer Ablauf:

```bash
cd /opt/huginn
grep -E '^(DATABASE_ADAPTER|DATABASE_NAME|DATABASE_USERNAME|DATABASE_PASSWORD|APP_SECRET_TOKEN|RAILS_ENV)=' .env
```

Wenn noch Werte fehlen, ergaenze sie zuerst. Danach:

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rails server -p 3000
```

Wichtig:

- `db:seed` wird absichtlich nicht blind automatisch ausgefuehrt
- so entstehen nicht versehentlich unsichere Standard-Zugangsdaten
- wenn du bewusst Beispieldaten oder einen Startnutzer anlegen willst:

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rake db:seed
```

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
