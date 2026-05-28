# Changelog

## V11.18

- Next-Level Review-Paket ergaenzt: Setup-Bewertung, Profil-/Tool-Gap-Analyse, Entscheidungsbaum, Low-Resource-Modus, Backup/Restore, Remote-Safe-Defaults, WSL2-, Node/pnpm-, Ollama-, Agent-Routing- und MCP-Guides.
- Profil-, Tool-Lifecycle- und Menuestruktur-Standards ergaenzt; schneller Lifecycle-Audit `scripts/check_tool_lifecycle.sh` in Dry-Run und CI eingebunden.
- Safe-Default-Bindings gehaertet: OpenClaw-/Profil-Templates sowie ArchiveBox/Vault-Beispiele binden nun standardmaessig an `127.0.0.1` statt `0.0.0.0`.
- Secrets-/Keys-, GPU-, VPS-, Cloudflare/Tailscale-, Local-First-Kosten- und Known-Issues-Dokumente ergaenzt.
- Minimale sichere Wrapper fuer Preflight, Secret-Scan, Security-Scan, Profile-Matrix-Check und Tool-Registry-Check ergaenzt.
- Geplante Next-Level-Profile als documentation-first Backlog dokumentiert, ohne sie als schwere Auto-Installer zu aktivieren.
- CI-Workflow `.github/workflows/ci.yml` und `scripts/next_level_dry_run_check.sh` fuer Bash-Syntax, Shellcheck, shfmt, Markdown, Secret-Scan, Registry-Sync und Dry-Run-Sicherheitschecks ergaenzt.
- myNextCloud AI documentation-first Integration ergaenzt: Profile, Tool-Doku, Upstream-Sync, Branding-/Lizenzcheck, Cloudflare/Tailscale, n8n/Ollama/OpenClaw/Whisper/Home-Assistant-Konzepte.
- sichere Helper-Skripte unter `scripts/mynextcloud/` ergaenzt; schreibende Aktionen laufen nur mit `--apply`.
- JSON-Profile fuer `myNextCloud_File_Agent`, `myNextCloud_Admin_Agent` und Android-Branding/Build-Checks angelegt.
- 36 neue documentation-first Profile fuer LLMOps, Automatisierung, RAG, Medien, Security, Hardware/Homelab und Alltag ergaenzt.
- neue Review-Dokumente: Scorecard, Missing-Profiles/Tools-Review, Profilstatus, Hardware-Entscheidungsbaum, Risiko-Level und sichere Installationspfade.
- neuer nicht-destruktiver Systemprofil-Detector `scripts/system_profile_detect.sh` fuer WSL2, RAM, Swap, Speicher, Node, Docker/Podman, systemd und GPU-Hinweise.
- Airbyte-Installer um RAM-Pruefung, abctl-Zeitlimit und bessere Klassifikation fuer `workload-api-server`/`context deadline exceeded` erweitert.
- Setup-Update-Ausgabe unterscheidet lokale `M`-Aenderungen von gruen dargestellten, tatsaechlich aktualisierten Dateien.
- Coqui_TTS-Installer prueft jetzt Python 3.9-3.11, bricht unter Python 3.12 klar ab und bleibt in Profilen optional, damit Piper/Whisper weiter installiert werden koennen.
- Fehlender generischer `scripts/profile_pack_installer.sh` fuer einfache Profilpakete ergaenzt.
- `docs/SETUP_HEALTH_REVIEW.md`, `docs/GITHUB_TOOL_CANDIDATES_REVIEW.md` und `docs/SAFE_DEFAULTS.md` ergaenzt.
- `setup_ultimate.sh` fragt bei schweren/experimentellen Tools explizit nach Zustimmung, bevor Installationen starten.
- `scripts/check_profile_registry_sync.sh` meldet jetzt fehlende Docs/Installer/Uninstaller, Legacy-Gruppen und unbekannte Profil-Tools.
- `scripts/doctor.sh` prueft zusaetzlich Docker/Podman, Node/pnpm/corepack, Python/venv/pipx, GitHub CLI, OpenClaw-Workspace, Speicher, Ports, Markdown und Registry-Sync.
- GitHub Actions Workflow `.github/workflows/repo-health.yml` fuer Shellcheck, shfmt, Secret-Scan, Markdown-Linkcheck und Registry-/Config-Checks angelegt.

## V11.16

- neue Review- und Roadmap-Doku
- neue Profile für DevOps, Data, Document AI, Voice Assistant, Web3, Compliance, Personal Knowledge und Repo-Maintenance
- neue Security-Audits
- neues Gesamt-Healthcheck-Skript
- neuer Ressourcen-Estimator
- neue Tool-Installer für Maintainer-, Voice-, Web3- und Compliance-Bausteine
- Menü- und Profilintegration erweitert

## V11.15

- Registry-Grundlagen, Audit-Doku, Matrixen und zusätzliche Studio-Profile
