# Docs Changelog

## 2026-05-31

- DuckDB-Installer von `apt install duckdb` auf offizielles GitHub-Release-Binary umgestellt, weil Ubuntu 24.04/Noble kein `duckdb`-Paket in den Standard-Repositories bereitstellt.
- DuckDB-Registry um Quelle, Installationsmodus, Ressourcenklasse und Sicherheitsnotiz ergaenzt.
- DuckDB-Installationshinweise mit Dry-Run, Check, Ressourcenbedarf und Deinstallation dokumentiert.
- FinRAG-Installer um Python-Kompatibilitaetspruefung ergaenzt: FinRAG benoetigt Python `>=3.10,<3.12`; Ubuntu 24.04 Python 3.12 wird jetzt vor dem pip-Build sauber abgefangen.
- FinRAG-Installationshinweise mit sicherem Python-3.10/3.11-Pfad dokumentiert.
- FinRobot-Installer um dieselbe Python-Kompatibilitaetspruefung ergaenzt: FinRobot benoetigt Python `>=3.10,<3.12`; Ubuntu 24.04 Python 3.12 wird jetzt vor dem pip-Build sauber abgefangen.
- FinRobot-Installationshinweise mit sicherem Python-3.10/3.11-Pfad dokumentiert.
- Flowise-Installer von der falschen Quelle `FlowiseAI/FlowiseChatbot` auf die oeffentliche Quelle `FlowiseAI/Flowise` umgestellt.
- Flowise-Clone non-interactive gemacht (`GIT_TERMINAL_PROMPT=0`), damit bei falscher URL keine GitHub-Username-/Passwortabfrage mehr erscheint.
- Flowise-Installer bricht jetzt bei kaputtem/leerem Zielordner oder fehlender `package.json` ab, statt nach fehlgeschlagenem Clone trotzdem `pnpm install` zu starten.
- Flux CLI Installer von `curl | bash` auf direkten GitHub-Release-Download mit SHA256-Pruefung umgestellt.
- Flux CLI Architekturhinweise fuer Intel/AMD `amd64`, ARM64 und 32-bit ARM dokumentiert.

## 2026-05-28

- Setup Review and Roadmap angelegt.
- Recommended Tools Matrix ergaenzt.
- Documentation-first Profile fuer DevOps, Security, Coding-Agenten, n8n, Smart Home, Medien, Kubernetes, Privacy, Android und Monitoring ergaenzt.
- Quickstart, Architecture, Security Model, Profiles Overview, Tool Integration Matrix, Troubleshooting und VPS/Homelab/K3s Guide angelegt.

Keine schweren Tools wurden installiert. Keine Secrets wurden erzeugt.
