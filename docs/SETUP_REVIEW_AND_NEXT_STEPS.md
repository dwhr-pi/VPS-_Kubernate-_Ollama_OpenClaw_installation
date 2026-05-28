# Setup Review und naechste Schritte

Stand: 2026-05-23  
Zielbild: Base System -> Runtime -> Model Gateway -> Agent Layer -> Memory/RAG -> Tool Layer -> UI -> Monitoring -> Security.

Update 2026-05-28: Neue documentation-first Profile und Review-Dokumente wurden ergaenzt. Sie sind absichtlich nicht automatisch als schwere Installationspfade aktiviert, damit WSL2/MiniPC-Systeme stabil bleiben.

Neue Review-Dokumente:

- `docs/SETUP_SCORECARD.md`
- `docs/SETUP_HEALTH_REVIEW.md`
- `docs/SAFE_DEFAULTS.md`
- `docs/GITHUB_TOOL_CANDIDATES_REVIEW.md`
- `docs/MISSING_PROFILES_REVIEW.md`
- `docs/MISSING_TOOLS_REVIEW.md`
- `docs/PROFILE_STATUS_MATRIX.md`
- `docs/HARDWARE_DECISION_TREE.md`
- `docs/INSTALLATION_RISK_LEVELS.md`
- `docs/RECOMMENDED_MINIMAL_SETUP.md`
- `docs/RECOMMENDED_ADVANCED_SETUP.md`
- `docs/RECOMMENDED_GPU_SETUP.md`
- `docs/WSL2_SAFE_INSTALL_PATH.md`
- `docs/VPS_SAFE_INSTALL_PATH.md`
- `docs/SECURITY_HARDENING_CHECKLIST.md`

Neuer nicht-destruktiver Systemcheck:

```bash
bash scripts/system_profile_detect.sh
```

## Was bereits gut funktioniert

- Das Repository ist modular aufgebaut: Profile, Tools, Ports, Doku und Skripte sind getrennt.
- Userdaten liegen ueberwiegend ausserhalb des Repositories unter `~/.openclaw_ultimate_user_data`.
- Viele riskante Bereiche sind bereits dokumentiert: Remote Access, Secret Handling, Port-Matrix, Security-Hardening, Kostenwarnungen.
- Tool-Installationen schreiben Messwerte und Logs, inklusive Speicher vor/nach Installation.
- Es gibt bereits Korrekturen fuer typische WSL2-Probleme: Docker-Compose-Plugin via GitHub, sudo-Fallback fuer Docker-Socket, robustere GitHub-Clone-Retries.

## Doppelte oder ueberlappende Profile

| Hauptprofil | Ueberlappende Profile | Empfehlung |
|---|---|---|
| `Image_Generation_Studio` | `Image_Generation`, `Visual_Creator` | Studio als Hauptprofil, alte Profile als Legacy/Alias markieren. |
| `Video_Generation_Studio` | `Video_Generation`, `Video_Generation_ComfyUI_Wan` | Studio als Einstieg, ComfyUI/Wan als experimentelles Spezialprofil. |
| `Cyber_Security_AI` | `Security_Analyst`, `Security_DevSecOps`, `Ethical_HackerGPT` | Defensive Security klar trennen: Analyst/DevSecOps stabil, Ethical-Hacker nur defensiv und gated. |
| `Repo_Maintainer_Agent` | `Repo_Maintainer`, `Developer_CI_CD` | Repo-Maintainer-Agent als Agentenprofil, Developer-CI-CD als CI-Basis. |
| `Personal_Memory_Knowledge_OS` | `Personal_Knowledge_Memory`, `Memory_Import_Export`, `Knowledge_Librarian` | Neues Profil als Zielarchitektur, bestehende Profile als Bausteine. |
| `Model_Router_Cost_Control` | `Model_Router_Gateway`, `Prompt_Generator_Studio` | Gateway technisch, Cost-Control Governance/Kostenlogik. |

## Nur dokumentiert oder noch nicht belastbar installierbar

- Android SDK, MobSF, Frida, Headscale, Nextcloud, Seafile, scancode-toolkit und Browserless sind aktuell eher dokumentierte Zielbausteine als stabil getestete Installer.
- Einige Docker-basierte Tools funktionieren nur mit systemd/Docker-Rechten; WSL2 braucht hier besondere Hinweise.
- Grosse Monorepos wie Activepieces, Airbyte und n8n sind empfindlich gegen Node-/Bun-/pnpm-Versionen und Speicherplatz.
- GPU-/Kubernetes-/Renderfarm-Profile sind konzeptionell sinnvoll, aber nicht als stabiler Default-Pfad zu behandeln.

## Fehlende Profile, die jetzt ergaenzt wurden

- `Local_AI_Office_Suite`
- `Android_AI_App_Lab`
- `Privacy_First_Cloud_Sync`
- `Personal_Memory_Knowledge_OS`
- `AI_Testing_QA_Lab`
- `Model_Router_Cost_Control`
- `Voice_Transcription_Callcenter`
- `Network_HomeLab_ZeroTrust`
- `Data_Scraping_Browser_Agents`
- `Legal_Compliance_Safety_Review`

Diese Profile sind bewusst `planned` und documentation-first. Die Stub-Installer markieren das Profil, installieren aber keine schweren Toolchains ohne explizite Tool-Auswahl.

## Fehlende oder zu pruefende Tools

| Tool | Bewertung | Naechster Schritt |
|---|---|---|
| promptfoo | empfohlen | Installer/Checkscript stabilisieren und fuer QA-Profil nutzen. |
| Aider/OpenHands/Continue.dev | empfohlen/optional | Coding-Agenten trennen: CLI, IDE, Web-UI. |
| LlamaIndex/Haystack | empfohlen/optional | RAG-Tooling mit Qdrant/ChromaDB abstimmen. |
| Paperless-ngx/Stirling PDF | empfohlen | Office-/Dokumentenprofile anbinden. |
| Syncthing/Rclone/Nextcloud | empfohlen/optional | Cloud-Sync-Profil mit sicheren Defaults. |
| Uptime Kuma/Netdata/Grafana/Prometheus/Loki | empfohlen | Monitoring-Matrix konsolidieren. |
| Gitleaks/Trivy/Grype/Syft/Semgrep/ShellCheck/shfmt | empfohlen | QA- und Security-Profile verbinden. |
| Whisper.cpp/Piper/faster-whisper | empfohlen | Voice-Profile konsolidieren. |
| Headscale/AdGuard Home/Pi-hole | optional | Netzwerkprofil, keine offenen Admin-Ports. |
| OpenTelemetry Collector | optional | Observability-Roadmap, nicht Default. |

## Riskante oder ungetestete Setup-Pfade

- Docker in WSL2: Docker-Gruppe greift erst nach neuer Shell; Setup nutzt daher `sudo docker compose`, wenn `docker info` ohne sudo fehlschlaegt.
- Node/Bun/pnpm: Monorepos koennen paketmanager- und versionsempfindlich sein. Build-Hinweise muessen pro Tool im Log klar bleiben.
- Cloudflare/Tailscale: Remote-Freigabe nur mit Access/Auth und Port-Matrix.
- Trading, Robotik, Smart Home und Security: Human-Approval-Gates muessen Default bleiben.
- Kubernetes/GPU: nur als fortgeschrittener Pfad, keine Default-Installation.

## Priorisierte Roadmap

### Sofort

- `scripts/check_profile_registry_sync.sh` regelmaessig ausfuehren.
- Neue `planned` Profile im Menue sichtbar halten, aber nicht automatisch schwere Toolchains installieren.
- README auf Quickstart und Verweise straffen, Details in Docs belassen.

### Naechste Iteration

- Alias-/Deprecated-Felder in `docs/Profile/profiles.json` und `config/profiles.yml` vereinheitlichen.
- Fuer jedes Tool Checkscript oder Healthcheck definieren.
- Markdown-Linkcheck und Secret-Scan in `doctor.sh` integrieren.

### Experimentell

- Kubernetes-Offloading fuer GPU/Render/LLM-Worker.
- Headscale, Browserless, MobSF, scancode-toolkit, OpenTelemetry Collector.
- Automatische Generierung von `PROFILE_TOOL_MAPPING.md` aus `config/profiles.yml`.
