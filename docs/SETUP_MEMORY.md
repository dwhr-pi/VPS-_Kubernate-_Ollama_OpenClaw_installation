# Setup Memory

Diese Datei dient als dauerhafte Projekt-Erinnerung fuer spaetere Chats und Folgearbeiten am Setup.

## Stand 2026-05-11

## Stand 2026-05-16

### Aider / Coding-Agent

- Letzter Installationsfehler: `rm: cannot remove '/opt/aider': Permission denied`.
- Ursache: Der gemeinsame Scaffold-Installer hatte `/opt/aider` mit `sudo` vorbereitet, loeschte alte Clone-Reste beim Neuaufbau aber ohne `sudo`.
- Fix: `scripts/tools/helpers/scaffold_tool_common.sh` nutzt jetzt eine pfadgeschuetzte Aufraeumfunktion fuer `/opt/*` und User-Home-Pfade, bevor ein Git-Clone neu erstellt wird.
- Wichtig: Der Fix ist bewusst zentral, damit auch andere Scaffold-Tools von alten Root-Resten sauber repariert werden koennen.
- Neue Doku dazu: `docs/AIDER_INTEGRATION_GUIDE.md`.

### TODO: Aider funktional nachruesten

- `scripts/aider/run_aider_task.sh` erstellen.
- Allowlist fuer erlaubte Repositories und optionalen Dry-Run-Patchmodus ergaenzen.
- OpenClaw-Tooldefinition fuer Repo-Analyse, Patch-Vorschlag und Testlauf ergaenzen.
- Nach Aider-Aenderungen automatisch `git diff`, `scripts/validate_config.sh` und passende Tests anbieten.

### OpenCode / Coding-Agent-Scaffold

- Letzter Installationsfehler: `rm: cannot remove '/opt/opencode': Permission denied`.
- Ursache ist sehr wahrscheinlich eine alte Helper-Version oder eine andere Setup-Kopie, weil OpenCode den gemeinsamen Scaffold-Helper nutzt.
- Aktueller Fix: Der Scaffold-Helper nutzt eine pfadgeschuetzte `sudo rm -rf`-Routine fuer alte `/opt/<tool>`-Reste.
- Im neuen Installationslog muss `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.` erscheinen. Fehlt diese Zeile, wurde nicht der aktuelle Setup-Stand gestartet.
- Neue Doku dazu: `docs/OPENCODE_INTEGRATION_GUIDE.md`.

### TODO: OpenCode funktional nachruesten

- `scripts/opencode/run_opencode_task.sh` erstellen.
- OpenCode-Startkommando je Upstream-Stand automatisch erkennen.
- OpenClaw-Tooldefinition fuer OpenCode als optionalen Coding-Agent ergaenzen.
- Doctor-Check fuer `/opt/opencode`, Git-Ref und Modellkonfiguration ergaenzen.

### GitHub CLI / gh

- Letzter Installationsfehler: `rm: cannot remove '/opt/github_cli': Permission denied`.
- GitHub CLI nutzt ebenfalls den gemeinsamen Scaffold-Helper und baut aus `https://github.com/cli/cli.git` nach `/opt/github_cli`.
- Der aktuelle Helper entfernt alte `/opt/<tool>`-Reste mit einer pfadgeschuetzten `sudo rm -rf`-Routine.
- Im neuen Installationslog muss `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.` erscheinen. Fehlt diese Zeile, wurde noch eine alte Setup-Kopie gestartet.
- Neue Doku dazu: `docs/GITHUB_CLI_INTEGRATION_GUIDE.md`.

### TODO: GitHub CLI funktional nachruesten

- `scripts/github_cli/gh_safe.sh` als Allowlist-Wrapper erstellen.
- Read-only Default fuer `gh repo view`, `gh issue list`, `gh pr list`, `gh run list`.
- Schreibende Aktionen nur nach expliziter Freigabe.
- Doctor-Check fuer `gh --version` und optional `gh auth status`.

### Podman / Container Runtime

- Installationslog zeigt aktivierte systemd-Einheiten: `podman-auto-update.service`, `podman-auto-update.timer`, `podman-clean-transient.service`, `podman-restart.service`, `podman.service`, `podman.socket`.
- Das ist kein Fehler, aber eine wichtige Autostart-/Update-Nebenwirkung.
- `podman.socket` stellt eine lokale API bereit und darf nicht unbewusst extern freigegeben werden.
- `podman-auto-update.timer` kann Container aktualisieren, wenn passende Labels/Units genutzt werden. Fuer reproduzierbare Tests sollte Auto-Update optional und bewusst bleiben.
- Neue Doku dazu: `docs/PODMAN_CONTAINER_RUNTIME_GUIDE.md`.

### TODO: Podman funktional nachruesten

- Doctor-Check fuer `podman --version`, `podman info`, `podman.socket` und `podman-auto-update.timer`.
- Setup-Option fuer Auto-Update aktivieren/deaktivieren ergaenzen.
- Podman als Runtime fuer `Code_Sandbox` und spaetere OpenClaw-Toolausfuehrung dokumentieren.
- Security-Hinweis: Socket nur lokal, rootless bevorzugen, keine `--privileged`-Defaults.

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

### AutoGen / Multi-Agent-Chats

- AutoGen wurde laut Installationslog erfolgreich unter `/opt/autogen/venv` installiert, u. a. mit `pyautogen-0.10.0`, `autogen-core-0.7.5` und `autogen-agentchat-0.7.5`.
- AutoGen ist kein Webdienst, sondern ein Python-Framework fuer Multi-Agent-Chats, Reviewer-Agenten, Planner/Worker-Muster und User-Proxy-Freigaben.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/autogen/run_autogen_task.py` -> Planner/Worker/Reviewer/User-Proxy -> Ollama/LiteLLM/Qdrant -> Markdown/JSON-Report.
- Gute erste Szenarien: Repo-Review-Chat, Installationsfehler-Triage, Security-Findings-Review, Profil-Design-Review.
- Neue Doku dazu: `docs/AUTOGEN_INTEGRATION_GUIDE.md`.

### TODO: AutoGen funktional nachruesten

- `scripts/autogen/run_autogen_task.py` erstellen.
- `examples/autogen/repo_review_chat.py` erstellen.
- AutoGen-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- OpenClaw-Tooldefinition fuer AutoGen-Aufrufe ergaenzen.
- Ausgabeordner `~/.openclaw_ultimate_user_data/autogen/runs` standardisieren.
- User-Proxy-/Approval-Konzept fuer riskante Aktionen dokumentieren.
- Safety: Default `read-only`, `dry-run`, keine autonomen Shell-/Browseraktionen ohne Freigabe.

### Playwright / Browser Automation

- Playwright ist kein Webdienst, sondern ein Browser-Automation-Framework.
- Eine vorhandene Python-Umgebung unter `/opt/playwright/venv` reicht nur fuer den Python-Import; fuer echte Browserlaeufe muessen Browser-Binaries wie Chromium installiert sein.
- Pruefbefehle: `source /opt/playwright/venv/bin/activate`, `python -c "import playwright"`, `python -m playwright install chromium`.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/playwright/browser_worker.py` -> headless Chromium -> Screenshot/HTML/JSON unter `~/.openclaw_ultimate_user_data/playwright/`.
- Playwright kann fuer OpenClaw, Browser_Automation_Agent, Huginn, n8n, LangGraph, CrewAI und AutoGen als sicher begrenzter Browser-Worker dienen.
- Neue Doku dazu: `docs/PLAYWRIGHT_INTEGRATION_GUIDE.md`.

### TODO: Playwright funktional nachruesten

- `scripts/playwright/browser_worker.py` erstellen.
- `scripts/playwright/screenshot_url.py` erstellen.
- Allowlist unter `~/.openclaw_ultimate_user_data/playwright/allowed_targets.txt` einfuehren.
- Doctor-Check fuer Playwright-Import und Chromium-Binary ergaenzen.
- OpenClaw-Tooldefinition fuer Browser-Screenshot und HTML-Extraktion ergaenzen.
- Safety: nur erlaubte Ziele, Rate-Limit, keine Captcha-Umgehung, keine Cookies/Screenshots ins Repo.

### ChromaDB / lokaler Vektorstore

- ChromaDB wurde laut Installationslog erfolgreich unter `/opt/chromadb/venv` installiert, u. a. mit `chromadb-1.5.9`.
- ChromaDB ist kein klassisches Desktopprogramm. Es kann als Python-Bibliothek direkt in RAG-/Memory-Skripten oder optional als lokaler HTTP-Server genutzt werden.
- ChromaDB wird nicht automatisch von Ollama oder OpenClaw genutzt. Es braucht eine Pipeline: Import/Chunking -> Embeddings -> ChromaDB -> Retrieval -> Kontext fuer Ollama/OpenClaw.
- Empfohlener Datenpfad: `~/.openclaw_ultimate_user_data/chromadb/`.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/chromadb/query_memory.py` -> ChromaDB PersistentClient -> relevante Dokumente/Erinnerungen -> OpenClaw-Kontext.
- ChromaDB passt zu OpenClaw, Memory_Import_Export, Personal_Knowledge_Memory, Document_Intelligence, LangGraph, CrewAI und AutoGen.
- Neue Doku dazu: `docs/CHROMADB_INTEGRATION_GUIDE.md`.

### TODO: ChromaDB funktional nachruesten

- `scripts/chromadb/import_markdown_memory.py` erstellen.
- `scripts/chromadb/query_memory.py` erstellen.
- Embedding-Modell und Standardpipeline fuer Ollama/OpenClaw festlegen.
- Doctor-Check fuer ChromaDB-Import und optionalen Serverport ergaenzen.
- OpenClaw-Tooldefinition fuer ChromaDB-RAG-Kontext ergaenzen.
- Memory_Import_Export-Profil mit ChromaDB-Beispielpipeline verbinden.
- Safety: keine privaten ChromaDB-Datenbanken oder Exporte ins Repo.

### Code_Sandbox

- Diagnosemeldung `Keine Treffer fuer das Diagnosemuster gefunden` ist bei erfolgreicher Installation kein Fehler, sondern bedeutet nur, dass der Logfilter keine bekannten Problemzeilen gefunden hat.
- Logstatus: `Starte Installation von Code_Sandbox...` gefolgt von `Code_Sandbox wurde erfolgreich installiert.`
- Code_Sandbox ist aktuell ein vorbereitetes Sandbox-Modul unter `/opt/code_sandbox`, kein vollstaendiger Runner und kein Webdienst.
- Die Installation erzeugt `.env.template`, `README.md` und einen Platzhalter-`run.sh`.
- Ziel: OpenClaw, Programmierer-, LLM-Builder- und Agentenprofile sollen spaeter riskante Codeausfuehrung ueber Docker/Podman/Devcontainer statt direkt auf dem Host starten.
- Neue Doku dazu: `docs/CODE_SANDBOX_USAGE_GUIDE.md`.

### TODO: Code_Sandbox funktional nachruesten

- `scripts/code_sandbox/run_in_sandbox.sh` erstellen.
- Policy-Datei unter `~/.openclaw_ultimate_user_data/code_sandbox/policy.env` einfuehren.
- Docker-Backend mit `--network none`, `--memory`, `--cpus` und Timeout bauen.
- Optional Podman- und Devcontainer-Backend.
- OpenClaw-Tooldefinition fuer Sandbox-Kommandos ergaenzen.
- Doctor-Check fuer Docker/Podman und Sandbox-Testlauf.
- Safety: keine Secrets, kein Docker-Socket-Mount, kein `--privileged`, keine Host-Pfade ausser explizitem Workspace.

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
