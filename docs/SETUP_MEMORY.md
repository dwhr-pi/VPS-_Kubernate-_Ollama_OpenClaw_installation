# Setup Memory

Diese Datei dient als dauerhafte Projekt-Erinnerung fuer spaetere Chats und Folgearbeiten am Setup.

## Stand 2026-05-11

### Huginn

- Der aktuelle Huginn-Installer wurde intensiv fuer Ruby `3.2.x` gehaertet.
- Das Setup erzeugt jetzt auch automatisch einen echten Huginn-`INVITATION_CODE`, wenn die `.env` noch leer ist oder noch auf dem unsicheren Default `try-huginn` steht.
- Der aktuelle Huginn-Invitation-Code laesst sich jederzeit mit `grep '^INVITATION_CODE=' /opt/huginn/.env` im Terminal nachlesen.
- Der erste Huginn-Admin kann bei Bedarf ohne Web-Registrierung direkt per `rails runner` angelegt werden, indem `requires_no_invitation_code!` gesetzt wird.
- Der `dry_runnable.rb`-Pfad wurde fuer Ruby 3.2 angepasst, damit Agenten wieder speicherbar sind.
- Der `jobs_helper.rb`-Pfad wurde fuer den aktuellen Psych/YAML-Stack auf `YAML.unsafe_load` umgestellt, damit die `Jobs`-Seite wieder funktioniert.
- Fuer echte Huginn-Verarbeitung reichen im aktuellen Setup nicht nur der Webserver, sondern zusaetzlich ein Worker-Prozess mit `RAILS_ENV=production bundle exec rails runner bin/threaded.rb`.
- Beim `Website Agent` dieses Huginn-Stands muss HTML-Extraction in `extract` mit XPath-Werten wie `string(.)` oder `normalize-space(.)` arbeiten; `value: "text"` fuehrt hier leicht zu leeren Payload-Feldern trotz erfolgreichem Abruf.
- Scenario-Export und Reimport koennen bestehende Scenarios anhand ihrer internen Export-Identitaet wiedererkennen; ein lokal umbenanntes Scenario kann beim Reimport derselben Exportdatei wieder auf den alten Exportnamen zurueckfallen.
- Eine einfache funktionierende Testkette wurde erfolgreich bestaetigt:
  - `Manual Event Agent`
  - `Event Formatting Agent`
- Die alten problematischen Huginn-Zweige werden jetzt proaktiv erkannt und bei Bedarf entschärft:
  - `google-cloud-translate` / `grpc 1.42.0`
  - `mini_racer` / `libv8-node`
  - `ruby-growl`
  - `net-ftp-list`
  - `gmail_xoauth`
  - `mysql2 0.5.3`
- Der reale Huginn-Lauf vom `2026-05-11` erreichte nach den Gem-Fixes nicht mehr den alten Bundler-/gRPC-Abbruch, sondern scheiterte erst bei der Datenbankverbindung.

### Aktueller echter Restfehler bei Huginn

- Logdatei: `/home/ubuntu/.openclaw_ultimate_user_data/install_logs/20260511_173138_tool_install_Huginn.log`
- Relevanter Fehler:
  - `Mysql2::Error::ConnectionError: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'`
- Befund dazu:
  - `DATABASE_ADAPTER=mysql2`
  - `DATABASE_NAME=huginn_development`
  - `DATABASE_USERNAME=root`
  - `DATABASE_PASSWORD=""`
  - kein lokaler Socket unter `/var/run/mysqld/mysqld.sock`
  - `mysql.service` und `mariadb.service` waren auf dem System nicht vorhanden

### MySQL-/MariaDB-Nutzung im Repository

Geprueft wurden:

- `scripts/tools/`
- `scripts/profiles/`
- `stacks/`

Aktueller Befund:

- Eine aktive MySQL-/MariaDB-Nutzung ist im aktuellen Setup derzeit vor allem bei `Huginn` sichtbar.
- Das Trading-Profil mit `Zenbot_trader` bzw. der verlinkten externen GitHub-Plattform richtet im lokalen Setup aktuell **keinen** MySQL-/MariaDB-Dienst ein.
- Fuer `ZenTrade AI` wurde im aktuellen lokalen Repository **kein** eigener Quelltreffer gefunden. Falls spaeter ein externer `ZenTrade AI`-Stand angebunden wird, muss dessen Datenbankbedarf separat im Zielrepo geprueft werden.
- In den aktuellen Profilskripten und Stacks gibt es ausdrueckliche **PostgreSQL- und SQLite-Pfade**, die nicht pauschal auf MySQL/MariaDB umgestellt werden sollten.

### Bewusste DB-Ausnahmen im Projekt

Diese Komponenten sind im aktuellen Setup fachlich bewusst nicht auf MySQL/MariaDB verdrahtet:

- `Data_Engineering` installiert explizit `postgres` und `pgvector`.
- `Personal_Knowledge_OS` installiert explizit `sqlite_vec`.
- `Programmierer` fuehrt sowohl `sqlite` als auch `postgres` als allgemeine Infrastrukturbausteine.
- `Langfuse` nutzt im Tool-Setup PostgreSQL.
- `Healthchecks` nutzt im Tool-Setup PostgreSQL.
- `Paperless_NGX` nutzt im Tool-Setup PostgreSQL.
- `llmops-platform` nutzt fuer `langfuse` einen eigenen PostgreSQL-Dienst.
- Das Kubernetes-Beispiel fuer `zenbot` zeigt aktuell `MongoDB`, nicht MySQL/MariaDB.

### Projektregel fuer kuenftige Chats

- MariaDB/MySQL soll im Projekt bevorzugt dort verwendet werden, wo der Zielstack frei zwischen Adaptern waehlen kann und der Betrieb damit vereinheitlicht werden soll.
- PostgreSQL-, SQLite- oder MongoDB-native Pfade sollen **nicht** automatisch auf MariaDB/MySQL umgestellt werden, nur um einen globalen Einheitsstandard zu erzwingen.
- Vor jeder kuenftigen DB-Umstellung ist zuerst zu pruefen, ob der jeweilige Upstream-Stack technisch oder dokumentarisch auf PostgreSQL, SQLite oder MongoDB zugeschnitten ist.
- Fuer `Huginn` ist MySQL/MariaDB aktuell der reale operative Kandidat, solange keine bewusste Entscheidung fuer `postgresql` oder `sqlite3` getroffen wird.

### Praktische Schlussfolgerung

Fuer Huginn gibt es aktuell drei sinnvolle DB-Pfade:

1. lokalen MySQL- oder MariaDB-Dienst installieren und starten
2. externen MySQL-Host in `/opt/huginn/.env` ueber `DATABASE_HOST` und optional `DATABASE_PORT` setzen
3. Huginn auf `postgresql` oder `sqlite3` umstellen

### Wichtige Dateien

- [scripts/tools/huginn_install.sh](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/tools/huginn_install.sh:1)
- [docs/HUGINN_ENV_GUIDE.md](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/HUGINN_ENV_GUIDE.md:1)
- [scripts/config_templates/huginn/.env.template](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/config_templates/huginn/.env.template:1)

### Hinweis fuer Folge-Chats

Wenn ein spaeterer Chat an Huginn weiterarbeitet, sollte er zuerst diese Punkte als bekannt voraussetzen:

- Der fruehere `grpc 1.42.0`-Fehler ist nicht mehr der primaere Blocker.
- Der aktuelle reale Restfehler ist die fehlende lokale MySQL-/MariaDB-Infrastruktur fuer Huginn.
- Vor weiteren Gem-/Bundler-Eingriffen sollte zuerst entschieden werden, ob Huginn mit `mysql2`, `postgresql` oder `sqlite3` betrieben werden soll.
