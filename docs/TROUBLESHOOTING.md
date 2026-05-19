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
- wenn im Lockfile noch der alte Huginn-gRPC-Stack (`grpc 1.42.0`, `googleapis-common-protos 1.3.12`, `google-protobuf 3.21.5`) steckt und Ruby nicht auf `2.7` laeuft, zieht das Setup den Kompatibilitaetsfix jetzt **bereits vor dem ersten** `bundle install` ein
- wenn trotzdem ein `grpc`-Buildfehler erkannt wird, versucht das Setup einen gezielten Refresh der Google-/gRPC-Transitivabhaengigkeiten
  - dabei wird `grpc` auf einen kompatiblen neueren `1.x`-Stand gezogen
- wenn selbst dieser Refresh haengt oder nicht sauber durchlaeuft, kann das Setup als letzten robusten Fallback die optionale `google-cloud-translate`-Abhaengigkeit deaktivieren
  - dadurch fehlt dann der `GoogleTranslateAgent`, aber Huginn kann auf Systemen mit problematischem Legacy-gRPC-Stack trotzdem weiter installiert werden
- dieser Fallback greift jetzt nicht nur vorbereitend, sondern auch im echten `bundle install`-Fehlerpfad automatisch
  - das Setup meldet dabei klar, dass der `GoogleTranslateAgent` deaktiviert wurde und startet den Bundler-Lauf danach erneut
- wenn zunaechst `mini_racer` oder `libv8-node` ausfaellt und der nachfolgende Bundler-Lauf erst danach in `grpc` kippt, greift derselbe Google-Translate-Fallback jetzt ebenfalls automatisch
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

### Huginn oder Bundler scheitert an `nokogiri ... can no longer be found`

Typische Hinweise:

```text
Your bundle is locked to nokogiri (1.13.8-x86_64-linux) ...
but that version can no longer be found in that source.
```

Bedeutung:

- das aeltere Huginn-Lockfile kann plattformspezifische `nokogiri`-Eintraege fuer `x86_64-linux` enthalten
- wenn Rubygems genau diese vorkompilierte Binärversion nicht mehr ausliefert, stoppt `bundle install` schon vor spaeteren Abhaengigkeiten
- der Fehler ist dann kein `grpc`-Problem mehr, sondern ein veralteter `nokogiri`-Lockfile-Stand

Das Setup reagiert jetzt robuster:

- es erkennt plattformspezifische `nokogiri`-Lockfile-Eintraege und weist frueh darauf hin
- wenn Bundler an einer entfernten `nokogiri`-Binärversion haengen bleibt, startet das Setup automatisch einen gezielten Refresh von:
  - `nokogiri`
  - `mini_portile2`
  - `racc`
- davor wird der bisherige Lockfile-Stand als `Gemfile.lock.bak.before_nokogiri_refresh` gesichert
- nach dem Refresh startet `bundle install` automatisch erneut
- wenn danach spaeter noch der bekannte Google-/gRPC-Pfad faellt, greift weiterhin der vorhandene `GoogleTranslateAgent`-Fallback

Manuelle Pruefung:

```bash
cd /opt/huginn
grep -n "nokogiri" Gemfile.lock
bundle update nokogiri mini_portile2 racc
bundle install
```

### Welche Huginn-Upstream-Version soll ich mit `HUGINN_REPO_REF` verwenden?

- fuer eine laenger stabile Standardinstallation bleibt `HUGINN_REPO_REF=v2022.08.18` die empfohlene Voreinstellung
- fuer dieses Setup ist bei `v2022.08.18` MySQL/MariaDB der empfohlene Datenbankpfad
- PostgreSQL ist bewusst eher ein Original-/Upstream-Testpfad, weil es in dieser lokalen Installation bereits wiederholt Zusatzprobleme mit alten Huginn-/Gem-Staenden gab
- fuer modernere AI-/LLM-, Docker- oder Kubernetes-Szenarien kann bewusst ein neuerer Branch wie `master` getestet werden
- `master` benoetigt aktuell Ruby `>= 3.4.0`; das Setup nutzt dafuer bei Bedarf einen getrennten rbenv-Pfad unter `~/.rbenv-openclaw-huginn`, damit der stabile `v2022.08.18`-Pfad nicht kaputtgeht
- die Auswahl liegt in `~/.openclaw_ultimate_user_data/huginn/install_settings.env`, die bearbeitbare Huginn-`.env.template` in `~/.openclaw_ultimate_user_data/huginn/.env.template`
- eine ausfuehrliche Einordnung der Varianten `Release-Tag`, `master/main`, `Commit SHA` und `eigener Fork` steht hier:
  - [HUGINN_REPO_REF_GUIDE.md](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/HUGINN_REPO_REF_GUIDE.md)

### Neuesten Huginn-Installationslog automatisch auswerten

Der Logname enthaelt Datum, Uhrzeit und Vorgang. Statt den neuesten Namen manuell einzusetzen, nutze:

```bash
bash scripts/huginn_log_diagnostics.sh
```

Optional mit explizitem Log:

```bash
bash scripts/huginn_log_diagnostics.sh /home/ubuntu/.openclaw_ultimate_user_data/install_logs/DEIN_HUGINN_LOG.log
```

### Tool-Logs allgemein auswerten und optional per E-Mail senden

Die Diagnose ist nicht auf Huginn beschraenkt. Fuer den neuesten Installationslog aller Tools:

```bash
bash scripts/tool_log_diagnostics.sh
```

Fuer ein bestimmtes Tool:

```bash
bash scripts/tool_log_diagnostics.sh --tool Clawhub_CLI
bash scripts/tool_log_diagnostics.sh --tool OpenManus
bash scripts/tool_log_diagnostics.sh --tool Huginn
```

Das Script zeigt den Bericht weiterhin im Terminal und fragt anschliessend, ob der Bericht per E-Mail an `ai-chat-to-markdown@web.de` gesendet werden soll. Der Versand nutzt nur lokal vorhandene Mailprogramme wie `mail` oder `sendmail`.

Wichtig:

- keine SMTP-Passwoerter, App-Passwoerter oder API-Keys ins Repository schreiben
- fuer echten Versand lokal z. B. `mailutils` oder `msmtp` sicher konfigurieren
- fuer WEB.DE und aehnliche Provider muss der Envelope-Absender zur SMTP-Adresse passen; setze dafuer lokal `MAIL_FROM` in `~/.openclaw_ultimate_user_data/mail/mail_settings.env`
- Huginn kann spaeter als erste Aufgabe genau diese Diagnoseberichte weiterverarbeiten oder weiterleiten

Beispiel ohne Passwort:

```bash
cp ~/.openclaw_ultimate_user_data/mail/mail_settings.env.template ~/.openclaw_ultimate_user_data/mail/mail_settings.env
nano ~/.openclaw_ultimate_user_data/mail/mail_settings.env
chmod 600 ~/.openclaw_ultimate_user_data/mail/mail_settings.env
```

Inhalt:

```bash
MAIL_FROM="deine-adresse@web.de"
MSMTP_ACCOUNT="default"
```

Komfortabler ist der Editor im Setup:

```bash
bash ~/openclaw_ultimate_setup/setup_ultimate.sh
# Optionen -> E-Mail-Diagnose konfigurieren / Testmail senden
```

Der Editor schreibt die Konfiguration `.env`-aehnlich in:

- `~/.openclaw_ultimate_user_data/mail/mail_settings.env`
- `~/.openclaw_ultimate_user_data/mail/smtp_password`
- `~/.msmtprc`

Das SMTP-/App-Passwort wird getrennt in `smtp_password` gespeichert und mit `chmod 600` abgesichert. Wenn beim Eintragen der Daten `msmtp`, `mail` oder `sendmail` fehlen, installiert das Setup die Komponente `Mail_Utils_MSMTP` automatisch nach.

Wichtig beim E-Mail-Anbieter:

- SMTP/IMAP bzw. Zugriff fuer Drittanbieter-Apps muss haeufig erst im Konto aktiviert werden.
- Das entspricht der Freigabe fuer externe Mail-Apps auf Handy, Tablet oder Desktop.
- Einige Anbieter verlangen ein eigenes App-Passwort statt des normalen Konto-Passworts.
- Der Envelope-Absender muss zur SMTP-Adresse passen, sonst lehnen Anbieter wie WEB.DE den Versand mit `Sender address is not allowed` ab.

Der Menuepunkt `Testmail ohne Logs senden` versendet bewusst nur eine kurze Pruefmail und keine Installations- oder Diagnoseberichte. Die lokale Testmail-Datei liegt in `~/.openclaw_ultimate_user_data/mail/last_test_mail.txt` und kann im selben Menue wieder geloescht werden. Bereits zugestellte Testmails muessen im Postfach des Anbieters geloescht werden.

### Alte Installations- und Diagnose-Logs aufraeumen

Wenn viele Installationsversuche laufen, wachsen die Logordner im Benutzer-Workspace schnell an:

- `~/.openclaw_ultimate_user_data/install_logs/`
- `~/.openclaw_ultimate_user_data/diagnostic_reports/`

Die sichere Log-Rotation loescht nur Dateien in diesen Benutzerordnern und behaelt standardmaessig die neuesten 30 Dateien je Ordner. Ein Trockenlauf zeigt zuerst, was geloescht wuerde:

```bash
bash scripts/cleanup_setup_logs.sh --dry-run --days 14 --keep 30
```

Anwenden:

```bash
bash scripts/cleanup_setup_logs.sh --apply --days 14 --keep 30
```

Im Setup-Menue liegt die Funktion unter `Optionen` -> `Installationsueberwachung`. Dort kann auch aktiviert werden, dass alte Logs vor jeder Tool-Installation oder -Deinstallation automatisch rotiert werden.

### Mehrere Fehlerlogs richtig einordnen

Bei wiederholten Installationsversuchen bleiben bewusst auch alte Fehlerlogs erhalten. Das ist gut fuer die Nachverfolgung, kann aber verwirren: Ein alter Treffer wie `npm error Lifecycle script build failed`, `Permission denied` oder ein Docker-Mount-Fehler bedeutet nicht automatisch, dass der aktuelle Stand noch defekt ist.

Vorgehen:

- Zuerst immer das neueste Log nach Zeitstempel pruefen, z. B. `20260519_191415_main_menu_ruflo.log`.
- Danach erst aeltere Logs als Fehlerhistorie lesen.
- Wenn ein neueres Log mit `wurde erfolgreich vorbereitet`, `Bundle complete`, `Build ist vorhanden` oder `success` endet, ueberstimmt dieser letzte erfolgreiche Lauf die alten Fehlerlogs.
- Fuer eine Lauf-Zusammenfassung `bash scripts/install_run_diagnostics.sh` nutzen.
- Fuer aktuell offene Fehler `bash scripts/last_install_log.sh --failed` nutzen. Das Script trennt inzwischen offene Fehler von alten Fehlerlogs, die durch einen spaeteren erfolgreichen Lauf desselben Tools ueberholt wurden.
- Fuer den neuesten Tool-Bericht `bash scripts/tool_log_diagnostics.sh` nutzen.

Bekannte Beispiele aus der Fehlerhistorie:

- Ruflo vor dem Fix: `Permission denied`, `pnpm install fuer Ruflo fehlgeschlagen`, `Lifecycle script build failed`, alter Root-Build mit unfertigen v3-/Plugin-Bereichen.
- Ruflo nach dem Fix: `Ruflo CLI-Build ist vorhanden` und `Ruflo wurde erfolgreich vorbereitet`.
- Prometheus: Docker-Mount-Fehler, wenn `/opt/prometheus/prometheus.yml` auf dem Host ein Verzeichnis statt einer Datei ist oder fehlt.
- K3s-Deinstallation: `Unit k3s.service not loaded` ist meist ein harmloser Hinweis, wenn K3s bereits entfernt oder nie als systemd-Service geladen war.

Wichtig: Prometheus und K3s sind keine Voraussetzung fuer Ruflo. Wenn diese Fehler zusammen mit Ruflo-Logs auftauchen, stammen sie aus aelteren, anderen Installationsversuchen im gemeinsamen Logordner. Sie verschwinden nicht dadurch, dass man Prometheus oder K3s fuer Ruflo installiert, sondern durch Log-Rotation, durch gezielte Reparatur des jeweiligen Tools oder durch die neue Laufdiagnose, die den neuesten Status pro Tool getrennt ausweist.

### Huginn `master` mit PostgreSQL nachtesten

Der Pfad `HUGINN_REPO_REF=master` plus `DATABASE_ADAPTER=postgresql` nutzt Ruby `3.4.x` ueber den getrennten rbenv-Pfad `~/.rbenv-openclaw-huginn`.

Validierter lokaler Teststand vom 14. Mai 2026:

- Repository: `/opt/huginn`
- Git-Stand: `9895f308` auf `master`
- Ruby: `3.4.9`
- Datenbank: `DATABASE_ADAPTER=postgresql`, `DATABASE_HOST=127.0.0.1`, `DATABASE_PORT=5432`
- Webdienst: `huginn-web.service` aktiv, Puma auf `127.0.0.1:3002`
- Worker: `huginn-worker.service` aktiv
- HTTP-Nachtest: `HTTP/1.1 200 OK` auf `http://127.0.0.1:3002`

Nach einer erfolgreichen Installation pruefen:

```bash
bash scripts/huginn_status.sh
```

Erwartete grobe Signale:

- `huginn-web.service` und `huginn-worker.service` sind vorhanden
- Huginn nutzt Port `3002`
- `curl -I http://127.0.0.1:3002` liefert eine HTTP-Antwort
- Datenbankadapter zeigt `DATABASE_ADAPTER=postgresql`

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
## pnpm: ERR_PNPM_IGNORED_BUILDS

Symptom:

```text
[ERR_PNPM_IGNORED_BUILDS] Ignored build scripts: esbuild, sharp, better-sqlite3, ...
Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.
```

Bedeutung:

pnpm 10/11 blockiert Build-Skripte von Abhaengigkeiten standardmaessig oder nach Policy, damit Pakete beim Installieren nicht ungefragt Code ausfuehren. Das ist eine Sicherheitsfunktion, aber native Module wie `esbuild`, `sharp`, `argon2`, `better-sqlite3`, `onnxruntime-node` oder `hnswlib-node` koennen dadurch unvollstaendig bleiben.

Empfohlener Umgang:

- Nicht blind alle Builds erlauben.
- Im jeweiligen Projektverzeichnis `pnpm ignored-builds` ausfuehren.
- Nur bekannte und benoetigte Pakete mit `pnpm approve-builds` oder einer gepflegten `allowBuilds`-Liste freigeben.
- Danach `pnpm install --no-frozen-lockfile` und den Build erneut starten.

Ruflo:

Das Ruflo-Installskript erkennt diesen Fall und fragt interaktiv, ob nur bekannte Ruflo-Build-Abhaengigkeiten in `pnpm-workspace.yaml` unter `allowBuilds: true` eingetragen werden sollen. Alte oder kaputte `onlyBuiltDependencies`-Versuche werden gesichert und durch eine saubere Workspace-Datei ersetzt. Wenn die Freigabe abgelehnt wird, bricht der Installer bewusst ab, weil der CLI-Build sonst reproduzierbar an fehlenden nativen Modulen scheitert. Fuer nicht-interaktive Tests kann bewusst `RUFLO_APPROVE_BUILDS=1` gesetzt werden.

Hinweis zu Ruflo Alpha/Upstream:

Der komplette Upstream-Befehl `pnpm build` kompiliert aktuell auch unfertige v3-/Plugin-Bereiche und kann mit TypeScript-Fehlern scheitern. Das Setup nutzt deshalb als Installationskriterium den gezielten v3-CLI-Build `npx -y pnpm@8.15.0 --dir v3 --filter @claude-flow/cli run build` und prueft danach, ob `v3/@claude-flow/cli/dist/src/index.js` vorhanden ist.

Der Ruflo-v3-Workspace verlangt derzeit `pnpm@8.15.0`, waehrend das Root-Setup mit aktuellem pnpm/Corepack laufen kann. Weil Corepack in manchen Shells trotzdem bei pnpm 11 bleibt, ruft das Installskript fuer die v3-Workspace-Schritte bewusst `npx -y pnpm@8.15.0` auf. Danach baut es `@claude-flow/memory` und `@claude-flow/swarm` vor und installiert `@ruvector/learning-wasm` als optionale CLI-Abhaengigkeit.

Validierter Stand:

- Der erfolgreiche Ruflo-Lauf ist daran erkennbar, dass `@claude-flow/memory` und `@claude-flow/swarm` gebaut werden.
- Danach muss `Ruflo CLI-Build ist vorhanden` erscheinen.
- Zum Schluss muss `Ruflo wurde erfolgreich vorbereitet` erscheinen.
- Warnungen zu fehlenden optionalen Bin-Links, Peer Dependencies oder `agentic-flow` sind in diesem Alpha-Stand dokumentierte Upstream-Einschraenkungen, solange der CLI-Build vorhanden ist.
- Ruflo bleibt deshalb im Setup als `experimental` einzustufen, auch wenn die CLI vorbereitet wurde.

Wenn `git pull` in `/opt/ruflo` mit `Your local changes ... v3/pnpm-lock.yaml would be overwritten by merge` abbricht, stammen diese lokalen Aenderungen normalerweise von vorherigen `pnpm install`-/Build-Laeufen. `/opt/ruflo` ist kein Benutzer-Arbeitsrepo, sondern ein Upstream-Checkout. Der Installer sichert deshalb Status und Diffs nach `~/.openclaw_ultimate_user_data/backups/ruflo_git_dirty_*`, setzt nur `/opt/ruflo` per `git reset --hard`/`git clean -fd` sauber zurueck und aktualisiert danach erneut. Das betrifft nicht das OpenClaw-Setup-Repository.
