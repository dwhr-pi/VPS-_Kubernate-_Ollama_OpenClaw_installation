# Setup Review 2026 - Next Actions

Stand: 2026-05-23  
Ziel: Das Ultimate-KI-Setup bleibt lokal-first, modular, pruefbar und sicher. Diese Datei ist ein Arbeitsbericht fuer die naechsten Wartungsrunden.

## Was funktioniert bereits gut?

- Das Repository hat eine erkennbare Plattform-Architektur: Runtime, Modell-Gateway, Agenten, RAG/Memory, Tools, UI, Monitoring und Security.
- Viele Profile sind bereits dokumentiert und fachlich breit aufgestellt: Coding, Medien, RAG, Monitoring, Smart Home, Security, Wissenschaft, CAD, Robotik und Boardroom.
- `docs/Profile/profiles.json`, Profilindex, Toolindex, Toolmatrix, Port-/Security-Dokumente und ausgelagerte Userdaten sind eine gute Basis fuer maschinenlesbare Setup-Menues.
- Installationslogs, Statusdateien und Metriken in `~/.openclaw_ultimate_user_data` trennen lokale Nutzerdaten vom Git-Repository.
- Die Richtung "Primaerquelle GitHub, apt nur fuer Basis-/Build-Abhaengigkeiten" ist sauber und nachvollziehbar.

## Was ist doppelt oder ueberlappend?

| Bereich | Hauptprofil | Alias / Legacy | Empfehlung |
|---|---|---|---|
| Bild-KI | `Image_Generation_Studio` | `Image_Generation` | Studio als Hauptprofil, altes Profil als kompakter Einstieg behalten. |
| Video-KI | `Video_Generation_Studio` | `Video_Generation`, `Video_Generation_ComfyUI_Wan` | Studio als Hauptprofil, Wan/ComfyUI als Spezialroute. |
| Trading/Web3 | `Web3_Crypto_Agent` | `Trading_AI`, `Trading_Crypto_Web3`, `Trading_Analysis` | Nur Analyse/Manual Mode als Default, keine Live-Keys. |
| CAD | `CAD_Konstrukteur` | `CAD_3D_Konstruktion` | `CAD_Konstrukteur` als deutschsprachiges Hauptprofil. |
| Security | `Cyber_Security_AI` | `Security_Analyst`, `Security_DevSecOps`, `Ethical_HackerGPT` | Defensive Profile behalten, offensive Begriffe als Legacy/defensiv markieren. |
| Repo-Pflege | `Repo_Maintainer` | `Repo_Maintainer_Agent` | Einen Registry-Eintrag mit Aliasliste verwenden. |
| Android/Mobile | `Android_AI_App_Lab` | `Android_Device_Manager`, `Android_App_Security`, `Mobile_Remote_Control`, `myBOX_Android_Container` | Sammelprofil plus spaetere Spezialprofile nur bei echtem Installerbedarf. |
| Netzwerk/Heimschutz | `Network_HomeLab_ZeroTrust` | `PiHole_DNS_Security`, `FRITZBox_Mesh_Optimizer`, `Home_Network_Diagnostics` | Zero-Trust-Profil als Dach, DNS/FRITZBox als Unterkapitel. |
| Memory/Import | `Personal_Memory_Knowledge_OS` | `AI_Memory_Hub`, `Chat_Import_Export`, `Personal_Context_Vault` | Ein Hauptprofil, Import/Export als Workflow. |
| Cloud/Sync | `Privacy_First_Cloud_Sync` | `Cloud_Service_Connector`, `WebDAV_Sync_Hub`, `Rclone_Cloud_Manager` | Privacy-Profil als Dachprofil. |
| App-Bau | `Local_AI_App_Builder` | `Desktop_App_Builder`, `Electron_Tauri_App_Builder`, `React_Dashboard_Builder` | Neues Dachprofil, Tauri/Electron/React als Varianten. |

## Welche Profile fehlen noch?

- `Prompt_Generator_Allround`: Prompt-, Medien- und Agentenprompt-Fabrik mit Export als Markdown/JSON.
- `Local_AI_App_Builder`: lokaler App-/Dashboard-Bau als Dachprofil fuer Desktop, Tauri, Electron, React und Playwright.
- Spezialprofile fuer Android-Security, FRITZBox, WebDAV oder Rclone sollten erst entstehen, wenn eigene Installer und Healthchecks vorhanden sind.

## Welche Tools fehlen noch?

| Tool | GitHub-Quelle | Bewertung | Naechster Schritt |
|---|---|---|---|
| `promptfoo` | `github.com/promptfoo/promptfoo` | empfohlen | In QA-/Prompt-Profilen mit Checkscript hinterlegen. |
| `OpenHands` | `github.com/All-Hands-AI/OpenHands` | optional/schwer | Ressourcenwarnung und Docker-/Source-Pfad dokumentieren. |
| `Continue.dev` | `github.com/continuedev/continue` | empfohlen | Als IDE-Ergaenzung dokumentieren, nicht automatisch systemweit installieren. |
| `LlamaIndex` | `github.com/run-llama/llama_index` | empfohlen | Python-venv-Installer mit Versionspinning. |
| `Haystack` | `github.com/deepset-ai/haystack` | optional | Nur fuer RAG-Advanced. |
| `Qdrant` | `github.com/qdrant/qdrant` | empfohlen | Bereits sinnvoll, Ports nur lokal/Tailnet. |
| `Paperless-ngx` | `github.com/paperless-ngx/paperless-ngx` | optional/schwer | Ressourcen- und Docker-Hinweis. |
| `Stirling PDF` | `github.com/Stirling-Tools/Stirling-PDF` | empfohlen | Lokale PDF-Werkzeuge, Port absichern. |
| `Syncthing` | `github.com/syncthing/syncthing` | empfohlen | Sync-Profil mit klarer Datenklassifikation. |
| `Headscale` | `github.com/juanfont/headscale` | advanced | Nur fuer erfahrene Homelab-Nutzer. |
| `OpenTelemetry Collector` | `github.com/open-telemetry/opentelemetry-collector` | optional | Spaeter fuer Observability-Profile. |

## Welche Installer fehlen?

- Geplante Profile haben teilweise Stub-Installer. Das ist korrekt, solange sie im Menue als `planned` oder `experimental` gekennzeichnet sind.
- Nicht jeder Tool-Eintrag hat bereits Install-, Uninstall- und Healthcheck-Skript. Kritische Kandidaten: schwere Docker-Stacks, Android SDK, Paperless-ngx, Nextcloud, OpenHands, Headscale.
- Fuer neue Installer gilt: vor Start Speicher/RAM/OS erkennen, nach Abschluss Status und Healthcheck schreiben.

## Welche Profile sind dokumentiert, aber nicht im Menue auswaehlbar?

- Viele neue Spezialprofile unter `docs/Profile/` sind bereits Doku, aber noch nicht in `docs/Profile/profiles.json` registriert.
- Prioritaet: nur Dachprofile registrieren, die klare Toolplaene haben. Spezialnamen werden als Alias gefuehrt, bis echte Installer existieren.

## Welche Tools sind dokumentiert, aber nicht installierbar?

- Einige Tools in Matrix/Index sind bewusst nur Kandidaten: `OpenBao`, `SOPS`, `Kopia`, `Typesense`, `Label Studio`, `SWE-agent`, `Browserless`, `Nextcloud`.
- Diese sollten erst als installierbar markiert werden, wenn GitHub-Quelle, Installskript, Uninstallskript, Healthcheck, Ports und Security-Defaults vorhanden sind.

## Sicherheitsrisiken

- Oeffentliche Admin-Ports sind das groesste Betriebsrisiko. Default bleibt `127.0.0.1`, LAN oder Tailnet.
- Trading/Web3 darf keine Seeds, Wallets oder Live-Order-Keys automatisch nutzen.
- Security-Profile bleiben defensiv; keine offensive Automatisierung gegen fremde Systeme.
- Robotik/Smart Home/Anlagensteuerung braucht Human-Approval-Gates, Auditlog und sichere Gateways.
- Cloud-APIs koennen Kosten verursachen. Lokale Modelle sind Default, externe Anbieter nur bewusst konfiguriert.

## Pfad-Tauglichkeit

| Pfad | Gut geeignet | Vorsicht |
|---|---|---|
| WSL2/MiniPC | Ollama, OpenClaw, RAG, Docs, n8n, kleine Dashboards | Windows-Host-Speicher kann enger sein als Linux-Meldung. |
| Oracle/VPS | Tunnels, Monitoring, kleine Webdienste, Reverse Proxy | Keine privaten Dokumente ohne Verschluesselung; wenig GPU. |
| Raspberry Pi | DNS, Sync, leichte Automationen, Monitoring-Agenten | Keine schweren LLM-/GPU-/Build-Stacks. |
| GPU-Workstation | ComfyUI, Blender, Video, grosse Modelle | CUDA/ROCm, VRAM, Stromkosten und Modellcache beachten. |
| Kubernetes/K3s | Worker, Renderfarm, Monitoring, GitOps | Erst nach stabiler Einzelinstallation und Backup. |

## Roadmap

Sofort:
- `profiles.json` auf 11.17 bringen und neue Dachprofile plus Aliasgruppen registrieren.
- Fehlende Doku-Wegweiser ergaenzen: Installation Wizard, Profilpakete, empfohlener Erstinstallationspfad, Troubleshooting.
- Toolquellen transparent in `docs/GITHUB_TOOL_SOURCES.md` dokumentieren.

Spaeter:
- Menue automatisch aus `profiles.json` inkl. Status, Hardwarebedarf und Installationsart aufbauen.
- Installer/Checks pro Tool vereinheitlichen.
- Markdown-Link- und Registry-Validierung in CI aufnehmen.

Experimentell:
- OpenHands, Headscale, Nextcloud, Paperless-ngx, OpenTelemetry Collector, Android-SDK-Fullstack und Kubernetes-GPU-Orchestrierung.

