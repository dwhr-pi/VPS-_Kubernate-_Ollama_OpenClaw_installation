# Setup Memory

Diese Datei dient als dauerhafte Projekt-Erinnerung fuer spaetere Chats und Folgearbeiten am Setup.

## Stand 2026-05-11

## Stand 2026-05-16

### LangGraph / Bibliothekstools

- LangGraph ist kein eigenstaendiger Webdienst und kein Desktopprogramm, sondern eine Python-Bibliothek fuer zustandsbehaftete Agenten- und Workflow-Graphen.
- Eine erfolgreiche Installation unter `/opt/langgraph/venv` bedeutet nur, dass LangGraph importierbar ist. Es funktioniert dadurch noch nicht automatisch direkt in OpenClaw.
- OpenClaw soll LangGraph spaeter ueber ein klares Tool-/Worker-Skript nutzen, z. B. `scripts/langgraph/run_graph_tool.py`.
- Geplanter Ablauf: OpenClaw Task -> LangGraph Python-Worker -> Ollama/LiteLLM/Qdrant/Langfuse -> Markdown/JSON-Ergebnis unter `~/.openclaw_ultimate_user_data/langgraph/runs`.
- Erste sinnvolle LangGraph-Use-Cases: Repo-Review-Graph, Install-Log-Diagnose-Graph, RAG-Antwort-Graph, Profil-Planungs-Graph, defensiver Security-Audit-Graph.
- Fuer alle Bibliothekstools gilt: Installation allein reicht nicht. Sie brauchen Smoke-Test, Beispielskript, Ergebnisformat, Doctor-Check und eine klare Integrationsbeschreibung.
- Neue Doku dazu:
  - `docs/LANGGRAPH_INTEGRATION_GUIDE.md`
  - `docs/TOOL_USAGE_AND_INTEGRATION_GUIDE.md`

### TODO: LangGraph funktional nachruesten

- `scripts/langgraph/run_graph_tool.py` erstellen.
- `examples/langgraph/repo_review_graph.py` erstellen.
- OpenClaw-Tooldefinition fuer LangGraph-Aufrufe ergaenzen.
- LangGraph-Doctor-Check in `scripts/doctor.sh` aufnehmen.
- Optional Langfuse/OpenLIT-Tracing anbinden.
- Safety: Default `read-only`, `dry-run`, keine Secrets im Graph-State.

### CrewAI / Multi-Agent-Teams

- CrewAI wurde erfolgreich als Python-Agentenframework unter `/opt/crewai/venv` installiert, laut Log mit `crewai-1.14.4`.
- CrewAI ist wie LangGraph kein eigenstaendiger Webdienst, sondern wird ueber Python-Skripte, Teams und Rollen-Workflows genutzt.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/crewai/run_crew_task.py` -> CrewAI Team -> Ollama/LiteLLM/Qdrant -> Markdown/JSON-Report.
- Gute erste Teams: Repo-Maintainer-Team, Install-Log-Diagnose-Team, Profil-Builder-Team, defensives Security-Review-Team.
- Neue Doku dazu: `docs/CREWAI_INTEGRATION_GUIDE.md`.

### TODO: CrewAI funktional nachruesten

- `scripts/crewai/run_crew_task.py` erstellen.
- `examples/crewai/repo_maintainer_team.py` erstellen.
- CrewAI-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- OpenClaw-Tooldefinition fuer CrewAI-Aufrufe ergaenzen.
- Ausgabeordner `~/.openclaw_ultimate_user_data/crewai/runs` standardisieren.
- Optional Langfuse/OpenLIT-Tracing anbinden.
- Safety: Default `read-only`, `dry-run`, keine autonomen Shell-/Browseraktionen.

## Als veraltet identifiziert

Diese Punkte gelten im Projektverlauf inzwischen als veraltet, problematisch oder nur noch als Legacy-Verhalten:

### Setup / Update-Pfad

- Der fruehere weiche Setup-Update-Pfad mit `git pull --ff-only` ohne harten Repo-Abgleich war fehleranfaellig, weil alte lokale Repo-Dateien neue Staende blockieren oder teilweise stehen bleiben konnten.
- Fuer das Setup-Repository gilt deshalb der harte Abgleich auf `main` inzwischen als bevorzugter Standard.

### Huginn Upstream / Installer-Meldungen

- Die Formulierung `HUGINN_REPO_REF ueberschreiben` gilt als veraltet; der Wert wird jetzt im Setup ausgewaehlt oder festgelegt.
- Ein Huginn-Lauf ohne vorgeschaltetes Auswahlmenue fuer den Upstream-Stand gilt als veraltet; die Ref-Wahl gehoert jetzt vor den eigentlichen Installationslauf.

### Huginn Konfigurationsablage

- Ein neuer Huginn-Lauf, der sich blind an Huginns alter `.env.example` orientiert, gilt als veraltet.
- Sichere Huginn-Werte gehoeren in den Benutzer-Workspace unter `~/.openclaw_ultimate_user_data/huginn/`.
- Alte Datenbank-Defaults wie `huginn_development`, `root` und leeres Passwort gelten fuer dieses Setup als Legacy und sollen nicht mehr der Standard sein.

### Huginn Datenbankpfade

- Die alten Fallbacks in `config/database.yml` mit `username: root`, Produktionspasswort-Fallback und `reconnect: true` gelten als Legacy.
- Der alte PostgreSQL-Gemstand `pg-1.1.3` gilt unter Ruby 3.2 in diesem Huginn-Upstream als veraltet und inkompatibel.
- Der alte mysql2-Pfad `0.5.3` gilt unter Ruby 3.2 als veraltet.

### Huginn Ruby-/Gem-Altlasten

- Die folgenden Huginn-Teilbereiche gelten in diesem Upstream auf moderner Ruby-Basis als veraltet oder besonders stoeranfaellig:
  - `google-cloud-translate` mit altem `grpc 1.42.0`
  - `mini_racer` / `libv8-node`
  - `ruby-growl`
  - `net-ftp-list`
  - `gmail_xoauth` ohne nachgezogene `net-imap` / `net-smtp` / `net-pop`-Kompatibilitaet
- Das alte Asset-/Startverhalten ohne Production-Asset-Precompile gilt ebenfalls als veraltet.

### Huginn Laufzeitverhalten

- Ein Huginn-Betrieb nur mit Webserver ohne Worker gilt fuer echte Verarbeitung als unvollstaendig und damit als veralteter Betriebsmodus.
- Bei HTML-Extraction im `Website Agent` gilt `value: "text"` in diesem Huginn-Stand als veraltet bzw. unpassend; erwartet werden XPath-Ausdruecke wie `string(.)` oder `normalize-space(.)`.
- Das alte YAML-Ladeverhalten ueber `YAML.load` im Jobs-Pfad gilt fuer den aktuellen Psych-Stack als veraltet.

### Huginn UI-/Workflow-Eigenheiten

- Der Eindruck, dass ein Scenario-Reimport immer einen echten Klon erzeugt, gilt fuer diesen Huginn-Stand als falsch bzw. veraltet.
- Bestehende Scenarios koennen beim Reimport anhand ihrer Export-Identitaet wiedererkannt und aktualisiert werden.

### Huginn

- Der aktuelle Huginn-Installer wurde intensiv fuer Ruby `3.2.x` gehaertet.
- Das Setup erzeugt jetzt auch automatisch einen echten Huginn-`INVITATION_CODE`, wenn die `.env` noch leer ist oder noch auf dem unsicheren Default `try-huginn` steht.
- Der aktuelle Huginn-Invitation-Code laesst sich jederzeit mit `grep '^INVITATION_CODE=' /opt/huginn/.env` im Terminal nachlesen.
- Der erste Huginn-Admin kann bei Bedarf ohne Web-Registrierung direkt per `rails runner` angelegt werden, indem `requires_no_invitation_code!` gesetzt wird.
- Der `dry_runnable.rb`-Pfad wurde fuer Ruby 3.2 angepasst, damit Agenten wieder speicherbar sind.
- Der `jobs_helper.rb`-Pfad wurde fuer den aktuellen Psych/YAML-Stack auf `YAML.unsafe_load` umgestellt, damit die `Jobs`-Seite wieder funktioniert.
- Fuer echte Huginn-Verarbeitung reichen im aktuellen Setup nicht nur der Webserver, sondern zusaetzlich ein Worker-Prozess mit `RAILS_ENV=production bundle exec rails runner bin/threaded.rb`.
- Huginn nutzt in diesem Setup jetzt standardmaessig den Port `3002`, damit kein Konflikt mit OpenClaw auf `3000` und Grafana auf `3001` entsteht.
- Portkonflikte muessen im Setup kuenftig immer mitgedacht werden: upstream-defaults und setup-empfohlene Ports sollten beide benannt werden. Fuer Huginn gilt: upstream oft `3000`, Setup-Empfehlung bewusst `3002`.
- Beim `Website Agent` dieses Huginn-Stands muss HTML-Extraction in `extract` mit XPath-Werten wie `string(.)` oder `normalize-space(.)` arbeiten; `value: "text"` fuehrt hier leicht zu leeren Payload-Feldern trotz erfolgreichem Abruf.
- Scenario-Export und Reimport koennen bestehende Scenarios anhand ihrer internen Export-Identitaet wiedererkennen; ein lokal umbenanntes Scenario kann beim Reimport derselben Exportdatei wieder auf den alten Exportnamen zurueckfallen.
- Der Installer richtet nach erfolgreicher Huginn-Installation nach Moeglichkeit zwei lokale `systemd`-Dienste ein: `huginn-web.service` und `huginn-worker.service`.
- Im Setup-Hauptmenue gibt es jetzt einen zentralen Start-Manager `Installierte Dienste starten`, der bekannte Startziele gesammelt oder gezielt anstossen kann.
- Der Start-Manager erzeugt bei Bedarf ein anpassbares Autostart-Skript unter `~/.openclaw_ultimate_user_data/autostart/start_selected_tools.sh`.
- Dieses Autostart-Skript muss vor dem eigentlichen Start einen Abbruchpfad zurueck ins Setup anbieten, damit Konfigurationsaenderungen vor einem erneuten Start moeglich bleiben.
- Der Installer bevorzugt fuer neue Huginn-`.env` jetzt die sichere Vorlage aus `~/.openclaw_ultimate_user_data/huginn/.env.template` und bereinigt alte DB-Defaults wie `root`/`huginn_development`.
- Die Warnung `MYSQL_OPT_RECONNECT is deprecated` stammt im Huginn-Stand nicht primaer vom MySQL-Server-Update, sondern vom alten `reconnect`-Default in `config/database.yml`; der Installer setzt diesen Default jetzt auf `false`.
- Wenn die sichere Huginn-Vorlage versehentlich auf `DATABASE_ADAPTER=postgresql` steht, laeuft der alte `pg-1.1.3`-Stack unter Ruby 3.2 in `pg_ext.so` aus; der Installer gibt dafuer jetzt einen gezielten Hinweis statt nur allgemein bei `db:create` zu scheitern.
- Der offizielle aktuelle Huginn-Upstream spricht in der Installationsdoku derzeit weiterhin von `master`; unsere Huginn-Auswahl und Doku sollten diesen Namen fuer den Teststand konsistent verwenden statt zwischen `main` und `master` zu mischen.
- `master` ist gegenueber `v2022.08.18` sichtbar moderner bei Ruby, OpenAI-kompatiblen `.env`-Optionen und dem HTTP-Backend-Pfad; MySQL/MariaDB bleibt laut offizieller Installationsdateien aber weiter ein realer Standardpfad.
- Eine einfache funktionierende Testkette wurde erfolgreich bestaetigt:
  - `Manual Event Agent`
  - `Event Formatting Agent`
- Die alten problematischen Huginn-Zweige werden jetzt proaktiv erkannt und bei Bedarf entschärft:

### Sprachpakete

- Das Setup kann jetzt nachinstallierbare Sprachpakete aus `~/.openclaw_ultimate_user_data/language_packs/` laden.
- Sprachpakete werden nach der eingebauten Setup-Sprache als Overlay geladen und koennen vorhandene `TXT_*`-Texte gezielt ueberschreiben.
- Fuer die Verwaltung gibt es jetzt `Optionen -> Sprachpakete verwalten`.
- Das Repo enthaelt mit `language_packs/de_core_ui/` bereits ein erstes deutsches Starter-Paket, das spaeter in ein eigenes Repo ausgelagert werden kann.
- Das separate Repo `Ultimate_KI_Setup-Sprachenpakete` soll kuenftig parallel zum Haupt-Setup mit gepflegt werden, damit exportierbare Sprachpakete und Setup-Integration nicht auseinanderlaufen.
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
