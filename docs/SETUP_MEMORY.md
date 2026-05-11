# Setup Memory

Diese Datei dient als dauerhafte Projekt-Erinnerung fuer spaetere Chats und Folgearbeiten am Setup.

## Stand 2026-05-11

### Huginn

- Der aktuelle Huginn-Installer wurde intensiv fuer Ruby `3.2.x` gehaertet.
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

- Eine aktive MySQL-/MariaDB-Nutzung ist im aktuellen Setup vor allem bei `Huginn` sichtbar.
- In den aktuellen Profilskripten ausserhalb von Huginn wurde keine weitere direkte MySQL-/MariaDB-Verwendung gefunden.
- In den aktuellen Stack-Dateien unter `stacks/` wurde ebenfalls keine weitere direkte MySQL-/MariaDB-Verwendung gefunden.
- Wenn spaeter weitere Komponenten MySQL oder MariaDB nutzen sollen, sollte diese Datei erweitert werden.

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
