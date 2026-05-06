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

### Huginn oder Bundler scheitert beim Bauen von `grpc 1.42.0`

Typische Hinweise:

```text
third_party/abseil-cpp/absl/strings/internal/str_format/extension.h:183:20:
'FormatConversionChar' does not name a type
```

oder im Abhaengigkeitspfad:

```text
google-cloud-translate 2.3.0
google-gax 1.8.2
googleapis-common-protos 1.3.12
grpc 1.42.0
```

Bedeutung:

- das Huginn-Release `v2022.08.18` bringt ein aelteres Lockfile mit
- `grpc 1.42.0` ist darin grundsaetzlich nicht falsch, aber auf modernen Toolchains problematisch
- der Fehler wird oft erst dadurch ausgeloest, dass Bundler mit `force_ruby_platform=true` einen lokalen Source-Build erzwingt
- auf `x86_64-linux` existieren fuer neuere `grpc`-1.x-Versionen vorkompilierte Gems, die diesen Compilerpfad vermeiden

Das Setup reagiert jetzt robuster:

- es liest die erwartete Bundler-Version aus Huginns `Gemfile.lock`
  - fuer `v2022.08.18` ist das `Bundler 2.3.10`
- es bevorzugt vorkompilierte Linux-Gems und setzt **nicht mehr standardmaessig** `force_ruby_platform=true`
- wenn trotzdem ein `grpc`-Buildfehler erkannt wird, versucht das Setup einen gezielten Refresh der Google-/gRPC-Transitivabhaengigkeiten
  - dabei wird `grpc` auf einen kompatiblen neueren `1.x`-Stand gezogen
- zusaetzlich protokolliert das Skript erkannte Ruby- und Bundler-Versionen direkt im Installationslauf

Wichtig:

- das Huginn-Release `v2022.08.18` wurde mit `Ruby 2.7.6` und `Bundler 2.3.10` gepflegt
- neuere System-Rubies koennen funktionieren, sind aber fuer dieses Release nicht ideal
- in diesem Repository gibt es **kein eigenes Huginn-Dockerfile**; die Installation laeuft ueber `scripts/tools/huginn_install.sh` und das Upstream-Repo unter `/opt/huginn`

Manuelle Pruefung:

```bash
cd /opt/huginn
ruby --version
bundle --version
grep -n "google-cloud-translate\|grpc" Gemfile
awk '/^BUNDLED WITH$/{getline; print}' Gemfile.lock
bundle config
```

Wenn `force_ruby_platform` noch aktiv ist, entferne die lokale Vorgabe und installiere erneut:

```bash
cd /opt/huginn
bundle config unset --local force_ruby_platform
bundle install
```

Wenn du den gezielten `grpc`-Fallback bewusst manuell nachziehen willst:

```bash
cd /opt/huginn
bundle update grpc google-protobuf googleapis-common-protos googleapis-common-protos-types
bundle install
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
