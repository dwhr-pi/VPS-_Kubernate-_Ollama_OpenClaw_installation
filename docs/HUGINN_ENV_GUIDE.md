# Huginn `.env` Guide

Diese Datei erklaert, **wo** die Huginn-`.env` in diesem Setup gepflegt wird und **wie** sie sicher bearbeitet werden soll.

## Pfade

- Bearbeitbare Vorlage im Benutzer-Workspace:
  `~/.openclaw_ultimate_user_data/huginn/.env.template`
- Sichere Huginn-Installationswerte im Benutzer-Workspace:
  `~/.openclaw_ultimate_user_data/huginn/install_settings.env`
- Runtime-Datei der Huginn-Installation:
  `/opt/huginn/.env`
- Repo-Vorlage:
  `scripts/config_templates/huginn/.env.template`

## Empfohlener Workflow

1. Oeffne im Setup unter `Optionen` den Punkt `Huginn Konfiguration (.env Vorlage)`.
2. Bearbeite dort die Vorlage im Benutzer-Workspace.
3. Lege dort bei Bedarf auch den Huginn-Upstream-Stand (`HUGINN_REPO_REF`) fest.
4. Wende die Vorlage bewusst auf `/opt/huginn/.env` an.

Dadurch bleiben deine Anpassungen ausserhalb des Git-Repositories und ueberstehen Setup-Updates deutlich sauberer.

## Was ist wichtig?

- `APP_SECRET_TOKEN` sollte gesetzt sein.
  Wenn der Wert leer bleibt, erzeugt das Setup bei der Installation einen lokalen Secret-Token.
- `INVITATION_CODE` sollte nicht auf dem unsicheren Huginn-Default `try-huginn` bleiben.
  Wenn der Wert leer ist oder noch auf `try-huginn` steht, erzeugt das Setup jetzt automatisch einen lokalen Zufallscode.
- Huginn nutzt upstream haeufig den Web-Port `3000`.
  Dieses Setup verwendet fuer Huginn bewusst standardmaessig `3002`, damit kein Konflikt mit OpenClaw auf `3000` und Grafana auf `3001` entsteht.
- Fuer die Datenbank braucht Huginn mindestens:
  - `DATABASE_ADAPTER`
  - `DATABASE_NAME`
  - bei `postgresql` oder `mysql2` auch `DATABASE_USERNAME` und `DATABASE_PASSWORD`
- Fuer lokale Setups ist `APP_HOST=127.0.0.1` ein guter Default.

## `v2022.08.18` vs `master`

Fuer Huginn gibt es in diesem Setup aktuell zwei bewusst unterschiedliche Richtungen:

- `v2022.08.18`
  - konservativer Altstand
  - in unseren bisherigen Tests der leichter kontrollierbare Legacy-Pfad
- `master`
  - offizieller aktuellerer Upstream-Stand
  - deutlich moderner bei Ruby und einigen Umgebungsoptionen

Wichtige Unterschiede:

- Ruby:
  - `v2022.08.18` stammt aus dem Ruby-2.6/2.7-Uebergang.
  - `master` nutzt in der offiziellen Installationsanleitung derzeit Ruby `3.4.8`.
- Datenbank-Defaults:
  - beide Stande verwenden in den offiziellen Beispieldateien weiter `mysql2` als Default-Adapter
  - beide haben weiter MySQL-/MariaDB-Pfade
  - `master` entfernt den alten `DATABASE_RECONNECT`-/`reconnect: true`-Pfad, der in `v2022.08.18` die Warnung `MYSQL_OPT_RECONNECT is deprecated` ausloest
- Neue Umgebungsoptionen auf `master`:
  - `OPENAI_API_KEY`
  - `OPENAI_BASE_URL`
  - `ADDITIONAL_GEMS`
  - `FARADAY_HTTP_BACKEND`
- Mail/HTTP/LLM:
  - `master` ist fuer modernere OpenAI-kompatible APIs und konfigurierbare HTTP-Backends sichtbar besser vorbereitet
  - `v2022.08.18` ist hier deutlich aelter und braucht mehr lokale Sonderbehandlung

Wichtig zur Datenbankeinschaetzung:

- Ich sehe in den offiziellen Installations- und Beispiel-Dateien keinen Hinweis auf einen grundsaetzlichen Wechsel weg von MySQL/MariaDB.
- `master` bleibt also fuer unser Setup ein sinnvoller Kandidat, wenn wir Huginn weiter auf MySQL/MariaDB betreiben wollen.
- Ich sehe in diesen Quellen auch keinen offensichtlichen Hinweis auf einen grossen, sofort problematischen Datenbankmodell-Bruch zwischen `v2022.08.18` und `master`.
- Das ist aber eine vorsichtige Einschaetzung aus den offiziellen Installationsdateien, keine vollstaendige Migrationsgarantie. Der sichere Nachweis bleibt der frische `db:create`-/`db:migrate`-Lauf auf `master`.

Unsere aktuelle Setup-Empfehlung:

- fuer konservative Reproduktion und Legacy-Fixes: `v2022.08.18`
- fuer den naechsten aktiven Vergleichslauf und modernere Huginn-Funktionen: `master`

## Install-Logs fuer den `master`-Test

Den neuesten Huginn-Installationslog findest du mit:

```bash
ls -1t /home/ubuntu/.openclaw_ultimate_user_data/install_logs/*Huginn*.log | head -n 5
```

Den Schluss des neuesten Logs gibst du mir dann am besten so:

```bash
tail -n 120 /home/ubuntu/.openclaw_ultimate_user_data/install_logs/NEUER_LOGNAME.log
```

Oder direkt den relevanten Fehler-/Hinweisblock:

```bash
grep -nE 'Hinweis:|Fehler:|rake aborted!|LoadError|ArgumentError|ConnectionError|mysql2|pg_ext|grpc|net-imap|net-pop|assets:precompile|systemd|huginn-web|huginn-worker' /home/ubuntu/.openclaw_ultimate_user_data/install_logs/NEUER_LOGNAME.log | tail -n 200
```

## Installierte Version und Datenbank vor Deinstallation erkennen

Bevor Huginn deinstalliert wird, sollte immer festgehalten werden, welche Kombination gerade installiert oder fehlgeschlagen ist.
Das Setup bringt dafuer einen Statuscheck mit:

```bash
cd ~/openclaw_ultimate_setup
bash scripts/huginn_status.sh
```

Der Status zeigt:

- Repository-Pfad
- aktiven Git-Ref, Branch oder exakten Tag
- letzten Commit
- Datenbankadapter aus `/opt/huginn/.env`
- geplante Benutzerkonfiguration aus `~/.openclaw_ultimate_user_data/huginn/install_settings.env`
- neuesten Huginn-Installationslog
- erkannte Problemklasse, z. B. `v2022.08.18 + PostgreSQL`

Im Setup-Menue liegt derselbe Check unter:

```text
Optionen -> Huginn Konfiguration (.env Vorlage) -> Installierte Huginn-Version und Datenbank erkennen
```

Beim Deinstallieren zeigt das Huginn-Uninstall-Skript diesen Status ebenfalls an, bevor `/opt/huginn` geloescht wird.

Bekanntes Fehlerbild:

```text
LoadError: .../pg-1.1.3/lib/pg_ext.so: undefined symbol: rb_tainted_str_new
```

Das ist typisch fuer den alten `v2022.08.18`-Stand mit `DATABASE_ADAPTER=postgresql` unter neuerem Ruby.
Fuer unser stabiles Setup bleibt bei `v2022.08.18` daher MySQL/MariaDB empfohlen.
PostgreSQL bleibt erhalten, aber als bewusster Original-/Upstream-Testpfad.

Das Setup enthaelt dafuer einen optionalen Kompatibilitaetsversuch:

```env
HUGINN_ENABLE_PG_RUBY32_COMPAT=true
```

Wenn dieser Schalter aktiv ist, versucht der Installer den alten `pg ~> 1.1.3`-Pfad auf einen Ruby-3.2-kompatiblen `pg`-Zweig zu aktualisieren und den Lockfile gezielt neu zu schreiben.
Das ist fuer PostgreSQL-Tests gedacht, nicht als neue Standardempfehlung fuer das konservative Huginn-Profil.

Aktueller Testerfolg:

- `v2022.08.18 + PostgreSQL + Ruby 3.2.3` konnte mit diesem Compat-Pfad bis zu laufenden `huginn-web.service`- und `huginn-worker.service`-Diensten gebracht werden.
- Der lokale HTTP-Test auf `127.0.0.1:3002` antwortete erfolgreich.
- Die bekannten Warnungen zu `DidYouMean` und altem `ERB.new`/Sprockets-Code sind Legacy-Warnungen des alten Rails-/Ruby-Stacks und nicht automatisch ein Installationsabbruch.

Falls danach ein Bundler-Hinweis zu `twitter >= 0` oder `version solving has failed` erscheint, ist das meist kein neuer PostgreSQL-Fehler.
Dann wurde der alte Huginn-Lockfile zu breit neu aufgeloest.
Der Installer vermeidet deshalb jetzt bei Nokogiri-Reparaturen einen kompletten Lockfile-Neuaufbau und aktualisiert stattdessen nur `nokogiri`, `racc` und `mini_portile2` gezielt.

## Gmail und andere Mailanbieter

Ja, Huginn ist nicht auf Gmail beschraenkt.

Wichtig ist die Unterscheidung:

- `gmail_xoauth` ist nur ein spezieller Gmail-OAuth-Pfad fuer aeltere Huginn-Staende
- normale andere Mailadressen funktionieren typischerweise ueber klassische Mailprotokolle wie `IMAP`, `POP3` und `SMTP`

Praktisch bedeutet das:

- fuer **eingehende Mails** nutzt du in Huginn spaeter Agenten oder Zugangsdaten mit den Serverdaten deines Mailanbieters
- fuer **ausgehende Mails** nutzt Huginn die SMTP-Werte aus der `.env`

Das ist also nicht auf Gmail beschraenkt. Typische Kandidaten sind zum Beispiel:

- eigene Domain-Postfaecher
- mailbox.org
- GMX
- WEB.DE
- Outlook / Microsoft 365
- IONOS
- andere IMAP-/SMTP-faehige Anbieter

Gmail ist in diesem Setup nur deshalb sichtbarer, weil der alte Huginn-Upstream dafuer einen eigenen OAuth-Sonderpfad mit `gmail_xoauth` mitbringt.
Fuer andere Adressen ist der klassische IMAP-/SMTP-Weg oft sogar unkomplizierter.

## Was gehoert in die `.env` und was nicht?

In die Huginn-`.env` gehoert aktuell vor allem der **ausgehende SMTP-Pfad**.

Beispielhafte Felder:

- `SMTP_DOMAIN`
- `SMTP_USER_NAME`
- `SMTP_PASSWORD`
- `SMTP_SERVER`
- `SMTP_PORT`
- `SMTP_AUTHENTICATION`
- `SMTP_ENABLE_STARTTLS_AUTO`

Wichtig:

- Die `.env` ist **nicht automatisch die komplette Mailbox-Konfiguration fuer eingehende Mails**.
- IMAP-/POP3-Zugangsdaten fuer konkrete Mailabrufe liegen spaeter je nach Huginn-Agent oder Credential im jeweiligen Workflow.
- Deshalb muss nicht fuer jeden Mailanbieter ein eigener globaler Setup-Schalter gebaut werden.

## Passwort-Reset und Account-Mails

Wichtig: Huginn versendet Account-Mails, Einladungen und Passwort-Reset-Mails ueber Rails ActionMailer.
Das ist **nicht automatisch dasselbe** wie die OpenClaw-Diagnosemail ueber `msmtp`.

Das bedeutet:

- `msmtp` kann fuer Setup-Diagnoseberichte funktionieren, waehrend Huginn selbst trotzdem keine Passwort-Reset-Mail senden kann.
- Huginn braucht dafuer eigene Mailwerte in `/opt/huginn/.env`.
- Der Absender muss zum SMTP-Konto passen, sonst lehnen Anbieter wie WEB.DE, GMX oder Gmail die Mail oft ab.
- Viele Mailanbieter muessen Drittanbieter-Mailprogramme oder App-Passwoerter zuerst im Webinterface freischalten.

Aktuelle Pruefung:

```bash
grep -E '^(SMTP_|SMTP_DELIVERY_METHOD|EMAIL_FROM_ADDRESS|DOMAIN|APP_HOST|APP_PORT)' /opt/huginn/.env \
  | sed -E 's/(PASSWORD|PASS|SECRET|TOKEN|KEY)=.*/\1=[REDACTED]/I'
```

Wenn Huginn ueber den bereits lokal eingerichteten `msmtp`-/`sendmail`-Pfad versenden soll, ist diese Variante meist am einfachsten:

```env
SMTP_DELIVERY_METHOD=sendmail
EMAIL_FROM_ADDRESS=deine-adresse@example.com
DOMAIN=127.0.0.1:3002
APP_HOST=127.0.0.1
APP_PORT=3002
```

Danach Huginn neu starten:

```bash
sudo systemctl restart huginn-web.service huginn-worker.service
```

Wenn Huginn direkt ueber SMTP versenden soll, braucht Huginn stattdessen vollstaendige SMTP-Werte:

```env
SMTP_DELIVERY_METHOD=smtp
SMTP_DOMAIN=example.com
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USER_NAME=deine-adresse@example.com
SMTP_PASSWORD=HIER_NICHT_INS_REPO_SCHREIBEN
EMAIL_FROM_ADDRESS=deine-adresse@example.com
DOMAIN=127.0.0.1:3002
APP_HOST=127.0.0.1
APP_PORT=3002
```

Sicherheitsregel:

- echte SMTP-Passwoerter niemals ins Git-Repository schreiben
- wenn moeglich App-Passwort statt Hauptpasswort verwenden
- lokale `.env` nur auf dem Zielsystem pflegen
- vor externem Betrieb `DOMAIN` auf die echte geschuetzte Domain setzen, z. B. hinter Tailscale, Cloudflare Tunnel oder Reverse Proxy mit Auth

Wenn du ausgesperrt bist und E-Mail noch nicht funktioniert, ist der lokale Terminalweg sicherer als ein Passwort-Reset per Mail:

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rails runner "u=User.find_by(username: 'admin') || User.first; u.password='NEUES_SICHERES_PASSWORT'; u.password_confirmation='NEUES_SICHERES_PASSWORT'; u.save!"
```

Bei der `master`-Installation mit separatem rbenv-Pfad kann vorher diese Umgebung noetig sein:

```bash
export RBENV_ROOT="$HOME/.rbenv-openclaw-huginn"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$(rbenv init - bash)"
```

## Alltagstaugliche erste Mail-Aufgabe

Eine wirklich nuetzliche erste Huginn-Aufgabe fuer den Alltag waere:

- ein bestimmtes Postfach oder einen bestimmten Ordner ueberwachen
- nur wichtige Mails herausfiltern
- daraus strukturierte Events erzeugen
- und dir taeglich oder sofort eine kurze Zusammenfassung geben

Ein guter Startfall waere zum Beispiel:

### Mail-Eingang fuer Rechnungen, Termine und wichtige Benachrichtigungen

Ziel:

- Rechnungen
- Versandbestaetigungen
- Terminmails
- Support- oder Systemmeldungen

automatisch erkennen und sortieren.

Moeglicher Huginn-Fluss:

1. Mailabruf ueber dein IMAP-Postfach
2. Filter auf Absender, Betreff oder Stichwoerter
3. Umformung in klare Event-Felder
4. taegliche Sammelmail oder direkte Weitergabe an einen anderen Agenten

Das ist alltagstauglich, weil es nicht nur ein Demo-Agent ist, sondern sofort echte Postfaecher entlasten kann.

Eine konkrete deutsche Vorlage dazu liegt jetzt auch hier:

- [HUGINN_MAIL_WORKFLOWS_DE.md](C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/HUGINN_MAIL_WORKFLOWS_DE.md:1)
- [HUGINN_LOG_DIAGNOSTIC_WORKTREE.md](C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/HUGINN_LOG_DIAGNOSTIC_WORKTREE.md:1)

## Invitation Code und erster Benutzer

Huginn liest den Registrierungs-Code direkt aus `/opt/huginn/.env`:

```bash
grep '^INVITATION_CODE=' /opt/huginn/.env
```

Wenn du bewusst einen neuen Code setzen willst:

```bash
new_code="$(openssl rand -hex 12)"
sed -i "s/^INVITATION_CODE=.*/INVITATION_CODE=${new_code}/" /opt/huginn/.env
printf 'Neuer Huginn Invitation Code: %s\n' "$new_code"
```

Wenn du den ersten Admin lieber direkt im Terminal statt ueber die Web-Registrierung anlegen willst, geht das ohne Invitation Code so:

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rails runner "u=User.new(username: 'admin', email: 'admin@example.com', password: 'change-me-now', password_confirmation: 'change-me-now', admin: true); u.requires_no_invitation_code!; u.save!"
```

Danach solltest du das Passwort sofort auf einen eigenen sicheren Wert aendern.

## Erster Funktionstest im Webinterface

Ein sehr einfacher erster Test ist ein `Manual Event Agent`.

1. Oeffne `Agents`.
2. Klicke `New Agent`.
3. Suche in der Suchleiste gezielt nach `Manual Event Agent`, statt den Typ manuell in der langen Liste zu suchen.
4. Vergib einen Namen, z. B. `Erster Test`.
5. Trage als Optionen zum Beispiel ein:

```json
{
  "payload": {
    "message": "Hallo aus meinem ersten Huginn-Test",
    "source": "manual_test"
  }
}
```

6. Speichere den Agenten.

Wichtig:

- Bei diesem Agententyp gibt es je nach Huginn-Oberflaeche nicht immer einen auffaelligen `Run`-Button.
- Beim `Manual Event Agent` wird auf der Detailseite stattdessen ein eigenes Formular mit einem `Submit`-Button verwendet.
- Dort kann direkt ein JSON-Event eingetragen und abgesendet werden, zum Beispiel:

```json
{
  "message": "Hallo aus meinem ersten Huginn-Test",
  "source": "manual_test"
}
```

- Je nach Huginn-Oberflaeche laesst sich derselbe Inhalt auch nicht als freier JSON-Text, sondern als einzelne Eingabezeilen pflegen.
- Dann handelt es sich im Webinterface um einzelne Bloecke:
  - links der Schluessel
  - rechts der Wert
- Fuer das erste Beispiel trägst du dann zuerst ein:
  - links `message`
  - rechts `Hallo aus meinem ersten Huginn-Test`
- Danach klickst du rechts etwas oberhalb in der Zeile auf das gruene `+`-Symbol.
- Dadurch entsteht die naechste Zeile fuer:
  - links `source`
  - rechts `manual_test`
- Inhaltlich entspricht das genau diesem JSON:

```json
{
  "message": "Hallo aus meinem ersten Huginn-Test",
  "source": "manual_test"
}
```

- Wenn mehrere Test-Events auf einmal erzeugt werden sollen, kann auf der Detailseite stattdessen ein Top-Level-Schluessel `payloads` mit einem Array von Objekten verwendet werden.
- Der einfachste Erfolgsindikator ist, dass beim Agenten in der Liste oder Detailansicht die Anzahl der `Events` hochgeht.
- Wenn dort bereits `2` oder mehr Events stehen, hat der Test im Kern schon funktioniert.

Danach kannst du in der Agent-Detailansicht oder ueber `Events` pruefen, ob Nutzdaten wie diese sichtbar sind:

- `message: Hallo aus meinem ersten Huginn-Test`
- `source: manual_test`

## Erste funktionierende Agent-Kette

Ein guter zweiter Test ist eine kleine Kette aus:

1. `Manual Event Agent`
2. `Event Formatting Agent`

Beispiel fuer den `Event Formatting Agent`:

```json
{
  "instructions": {
    "message": "Nachricht: {{ message }}",
    "origin": "{{ source }}"
  },
  "mode": "clean"
}
```

Wichtig:

- Der `Manual Event Agent` muss den `Event Formatting Agent` als Empfaenger gesetzt haben.
- Beim `Event Formatting Agent` sollte `Propagate immediately` auf `Yes` stehen.
- Beim `Trigger Agent` ist `Propagate immediately` im aktuellen UI keine Textauswahl, sondern eine Checkbox direkt unter `Sources`.
- Fuer die echte Verarbeitung reicht der Webserver allein nicht aus. Huginn braucht zusaetzlich einen laufenden Worker-Prozess.

Wenn danach beim `Event Formatting Agent` `Last received event` und `Events created` hochgehen, funktioniert die Agent-Kette.

## Website Agent Hinweis

Beim `Website Agent` dieses Huginn-Stands muss der Wert in `extract` fuer HTML/XML als XPath-Ausdruck angegeben werden.

Wichtig:

- `value: "text"` ist hier nicht korrekt.
- Fuer sichtbaren Text sollte stattdessen zum Beispiel `value: "string(.)"` oder `value: "normalize-space(.)"` verwendet werden.
- Erst `css` waehlt die HTML-Knoten aus, danach liest `value` den Inhalt per XPath aus.

Beispiel fuer einen robusteren ersten Website-Test:

```json
{
  "expected_update_period_in_days": "2",
  "url": "https://example.com/",
  "type": "html",
  "mode": "all",
  "extract": {
    "headline": {
      "css": "h1",
      "value": "string(.)"
    }
  }
}
```

Wenn stattdessen `headline` oder `page_title` leer bleibt, liegt der Fehler oft nicht mehr am Abruf, sondern an einem unpassenden `value`-Ausdruck.

## Weitere Beispiele

- Weitere Huginn-Anwendungsbeispiele koennen spaeter direkt aus der Huginn-Oberflaeche, aus der offiziellen Huginn-Dokumentation oder aus Video-Tutorials erschlossen werden.
- Fuer dieses Setup ist zuerst wichtig, dass die kleinen lokalen Grundtests sauber funktionieren:
  - Agent speichern
  - Event erzeugen
  - Event empfangen
  - Agent-Kette verarbeiten

## Scenario-Import Hinweis

Beim Export und erneuten Import eines bestehenden Scenarios dieses Huginn-Stands kann der Import vorhandene Objekte anhand ihrer internen Export-Identitaet wiedererkennen und aktualisieren.

Das bedeutet praktisch:

- Wenn ein Scenario exportiert wird,
- danach lokal nur umbenannt wird,
- und dann dieselbe Exportdatei erneut importiert wird,

kann der Import den lokalen Datensatz wieder mit dem Namen aus der Exportdatei ueberschreiben.

Wichtig:

- Das ist in diesem Fall nicht automatisch ein neuer Installationsfehler.
- Fuer einen echten Klon oder eine parallele Variante sollte nicht einfach dieselbe Exportdatei unveraendert erneut importiert werden.
- Fuer sichere Tests besser:
  - das Scenario nur bearbeiten statt reimportieren,
  - oder vor dem Reimport die alte Testvariante loeschen,
  - oder die Exportdatei gezielt fuer einen echten Klon anpassen.

## Huginn lokal starten

Fuer einen funktionierenden lokalen Betrieb auf diesem Setup werden zwei Prozesse gebraucht:

### 1. Webserver

```bash
cd /opt/huginn
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -b 127.0.0.1 -p 3002
```

### 2. Worker

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rails runner bin/threaded.rb
```

### Einzeiler: Webserver + Worker zusammen

```bash
cd /opt/huginn && (RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -b 127.0.0.1 -p 3002 &) && RAILS_ENV=production bundle exec rails runner bin/threaded.rb
```

### Einzeiler: beide lokalen systemd-Dienste

```bash
sudo systemctl start huginn-web.service huginn-worker.service
```

### Einzeiler: nur Webserver

```bash
cd /opt/huginn && RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -b 127.0.0.1 -p 3002
```

### Einzeiler: nur Worker

```bash
cd /opt/huginn && RAILS_ENV=production bundle exec rails runner bin/threaded.rb
```

Ohne den Worker werden Events oft nur in die Queue gelegt, aber nicht weiterverarbeitet. Typische Symptome sind:

- Agenten erzeugen zwar Events
- verbundene Empfaenger-Agenten erhalten aber nichts
- `Last received event` bleibt auf `never`
- Job-Eintraege erscheinen, werden aber nicht sauber abgearbeitet

## Huginn als lokaler Dauerbetrieb

Das Setup richtet Huginn jetzt nach erfolgreicher Installation nach Moeglichkeit auch als zwei lokale `systemd`-Dienste ein:

- `huginn-web.service`
- `huginn-worker.service`

Die Rollen bleiben dabei gleich:

- `huginn-web.service` startet die Weboberflaeche
- `huginn-worker.service` verarbeitet Jobs, Events und Agent-Ketten
- Huginn nutzt in diesem Setup standardmaessig `127.0.0.1:3002`, damit kein Konflikt mit OpenClaw auf `3000` und Grafana auf `3001` entsteht

Nützliche Befehle:

```bash
sudo systemctl status huginn-web.service huginn-worker.service
```

```bash
sudo systemctl restart huginn-web.service huginn-worker.service
```

```bash
sudo systemctl stop huginn-web.service huginn-worker.service
```

```bash
sudo systemctl start huginn-web.service huginn-worker.service
```

```bash
sudo systemctl start huginn-web.service
```

```bash
sudo systemctl start huginn-worker.service
```

Im Setup-Hauptmenue gibt es dafuer jetzt zusaetzlich den Punkt `Installierte Dienste starten`.
Dort kannst du alle aktuell startbaren Tools gesammelt oder gezielt starten und dir ein anpassbares Autostart-Skript erzeugen lassen.

Wenn `systemd` in der Zielumgebung nicht verfuegbar ist, bleibt der manuelle Zwei-Prozess-Start aus den obigen Befehlen der Fallback.

## Freigabe nach aussen

Die Huginn-Weboberflaeche sollte nicht roh ins Internet gestellt werden.

Empfohlen:

- lokal oder nur im privaten Netz testen
- fuer Admin-Zugriff bevorzugt `Tailscale`
- fuer oeffentliche Freigaben nur ueber abgesicherten Reverse Proxy oder Cloudflare Tunnel

## Bezug zum Installer

Der Huginn-Installer nutzt diese Vorlage, wenn `/opt/huginn/.env` noch nicht existiert.
Wenn die Runtime-Datei schon existiert, bleibt sie unberuehrt, bis du sie bewusst ueber den Huginn-Konfigurationseditor ersetzt.
