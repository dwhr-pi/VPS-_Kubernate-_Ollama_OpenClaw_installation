# Docs Changelog

## 2026-05-31

- DuckDB-Installer von `apt install duckdb` auf offizielles GitHub-Release-Binary umgestellt, weil Ubuntu 24.04/Noble kein `duckdb`-Paket in den Standard-Repositories bereitstellt.
- DuckDB-Registry um Quelle, Installationsmodus, Ressourcenklasse und Sicherheitsnotiz ergaenzt.
- DuckDB-Installationshinweise mit Dry-Run, Check, Ressourcenbedarf und Deinstallation dokumentiert.
- DuckDB-Installer installiert fehlende Basiswerkzeuge `curl` und `unzip` jetzt vor dem GitHub-Release-Download automatisch nach.
- FinRAG-Installer um Python-Kompatibilitaetspruefung ergaenzt: FinRAG benoetigt Python `>=3.10,<3.12`; Ubuntu 24.04 Python 3.12 wird jetzt vor dem pip-Build sauber abgefangen.
- FinRAG-Installationshinweise mit sicherem Python-3.10/3.11-Pfad dokumentiert.
- FinRAG-Installer kann bei fehlendem Python 3.10/3.11 jetzt isoliertes CPython 3.11 aus `python/cpython` nach `/opt/openclaw-python` bauen, ohne `/usr/bin/python3` zu ersetzen.
- FinRobot-Installer um dieselbe Python-Kompatibilitaetspruefung ergaenzt: FinRobot benoetigt Python `>=3.10,<3.12`; Ubuntu 24.04 Python 3.12 wird jetzt vor dem pip-Build sauber abgefangen.
- FinRobot-Installationshinweise mit sicherem Python-3.10/3.11-Pfad dokumentiert.
- FinRobot-Installer kann bei fehlendem Python 3.10/3.11 jetzt isoliertes CPython 3.11 aus `python/cpython` nach `/opt/openclaw-python` bauen, ohne `/usr/bin/python3` zu ersetzen.
- Flowise-Installer von der falschen Quelle `FlowiseAI/FlowiseChatbot` auf die oeffentliche Quelle `FlowiseAI/Flowise` umgestellt.
- Flowise-Clone non-interactive gemacht (`GIT_TERMINAL_PROMPT=0`), damit bei falscher URL keine GitHub-Username-/Passwortabfrage mehr erscheint.
- Flowise-Installer bricht jetzt bei kaputtem/leerem Zielordner oder fehlender `package.json` ab, statt nach fehlgeschlagenem Clone trotzdem `pnpm install` zu starten.
- Zentrale Git-Zielordner-Reparatur eingefuehrt: abgebrochene Clone-Reste oder falsche Git-Origins werden automatisch nach `~/.openclaw_ultimate_user_data/setup_repair_backups/` gesichert und anschliessend sauber neu geklont.
- Flux CLI Installer von `curl | bash` auf direkten GitHub-Release-Download mit SHA256-Pruefung umgestellt.
- Flux CLI Architekturhinweise fuer Intel/AMD `amd64`, ARM64 und 32-bit ARM dokumentiert.
- Docker/Compose-Helfer vermeidet jetzt den Konflikt `docker.io` gegen `containerd.io`: Docker.com-Pakete werden bevorzugt, Ubuntu `docker.io` nur als Fallback genutzt.
- Docker-/containerd-Konflikt dokumentiert.
- Grype-Installer von `apt install grype` auf offizielles GitHub-Release mit SHA256-Pruefung umgestellt.
- Helm-Installer von `apt install helm` auf offizielles Helm-Release mit GitHub-Versionsermittlung und SHA256-Pruefung umgestellt.
- Huginn-Installer prueft lokale MySQL/MariaDB-Verfuegbarkeit jetzt vor dem langen Bundler-Schritt und kann MariaDB nur mit bewusstem `HUGINN_AUTO_INSTALL_LOCAL_DB=true` vorbereiten.

## 2026-05-28

- Setup Review and Roadmap angelegt.
- Recommended Tools Matrix ergaenzt.
- Documentation-first Profile fuer DevOps, Security, Coding-Agenten, n8n, Smart Home, Medien, Kubernetes, Privacy, Android und Monitoring ergaenzt.
- Quickstart, Architecture, Security Model, Profiles Overview, Tool Integration Matrix, Troubleshooting und VPS/Homelab/K3s Guide angelegt.

Keine schweren Tools wurden installiert. Keine Secrets wurden erzeugt.
