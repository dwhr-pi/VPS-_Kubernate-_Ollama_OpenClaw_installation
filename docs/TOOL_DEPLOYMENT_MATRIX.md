# Tool Deployment Matrix

Diese Matrix beantwortet die praktische Frage: Welche Tools gehoeren eher auf den MiniPC zuhause, welche auf eine VPS, welche in K3s und welche laufen eigenstaendig mit Web-UI, Desktopfenster oder App-Anbindung?

Neue Profile ab 11.17 werden zuerst als Dachprofile geplant. Spezialnamen wie `PiHole_DNS_Security` oder `React_Dashboard_Builder` sind Aliasziele und werden erst zu eigenen Deployments, wenn eigene Installer und Healthchecks existieren.

Legende:

- `Empfohlen`: guter Standardort
- `Optional`: sinnvoll, aber nur bei Bedarf
- `Nicht empfohlen`: technisch moeglich, aber fuer dieses Setup meist unguenstig
- `Advanced`: nur mit Erfahrung, Backup und Monitoring

## Zielumgebungen

| Umgebung | Zweck | Typische Staerken | Typische Grenzen |
|---|---|---|---|
| MiniPC Standalone | lokales Komplettsetup ohne Cloud-Abhaengigkeit | Daten bleiben lokal, gute Latenz, WSL2/Home-Lab | RAM/SSD/GPU begrenzt |
| MiniPC Home Server | zentrale lokale Dienste im Heimnetz | RAG, Automationen, Smart Home, Media, Dashboards | nicht oeffentlich ohne Tunnel |
| Haupt-VPS | leichtgewichtiger, oeffentlich erreichbarer Einstiegspunkt | Tunnels, Reverse Proxy, Monitoring, kleine Webdienste | wenig GPU, begrenzter Speicher |
| Zusatz-VPS / K3s Node | skalierbare Zusatzdienste | Worker, Monitoring, GitOps, leichte Services | Netzwerk/Storage/Updates komplexer |
| GPU-Workstation | Medien-KI und grosse Modelle | VRAM, Rendering, Bild/Video/Audio | Strom, Waerme, Modellpflege |
| Windows Desktop | GUI-Tools, Browser, Design, Android Studio | lokale Bedienung, Desktopfenster, Dateizugriff | nicht immer servergeeignet |
| Android / Mobile | Bedienung und Benachrichtigung | App-Zugriff, Tailscale, Home Assistant | keine schwere Serverlast |

## Empfohlene Platzierung nach Tool

| Tool | MiniPC Standalone | MiniPC Home | Haupt-VPS | Zusatz-VPS/K3s | Desktop/Window | Web-UI | App/Android-Anbindung | Hinweise |
|---|---|---|---|---|---|---|---|---|
| Ollama | Empfohlen | Empfohlen | Optional kleine Modelle | Optional | nein | API | indirekt via Open WebUI | grosse Modelle besser lokal/GPU |
| OpenClaw | Empfohlen | Empfohlen | Optional | Advanced | nein | je nach Frontend | indirekt | Agenten nur mit sicheren Tool-Grenzen |
| LiteLLM | Optional | Empfohlen | Empfohlen | Empfohlen | nein | API | indirekt | API-Keys nie ins Repo |
| Open WebUI | Empfohlen | Empfohlen | Optional mit Auth | Optional | Browser | ja | Browser/PWA moeglich | nicht offen ohne Auth |
| Qdrant | Empfohlen | Empfohlen | Optional | Empfohlen | nein | API | indirekt | sensible Dokumente lokal halten |
| ChromaDB | Empfohlen | Empfohlen | Optional | Optional | nein | nein/API | indirekt | gut fuer lokale RAG-Tests |
| LightRAG | Optional | Empfohlen | Optional | Optional | nein | je nach Setup | indirekt | Datenquellen pruefen |
| Langfuse | Optional | Empfohlen | Optional | Empfohlen | nein | ja | Browser | Prompt-/Trace-Daten schuetzen |
| OpenLIT | Optional | Empfohlen | Optional | Empfohlen | nein | Observability | indirekt | Telemetrie datensparsam |
| Prometheus | Optional | Empfohlen | Empfohlen | Empfohlen | nein | ja | indirekt | intern halten |
| Grafana | Optional | Empfohlen | Empfohlen mit Auth | Empfohlen | nein | ja | Browser/App | Android/iOS Grafana-App moeglich |
| Loki | Optional | Empfohlen | Optional | Empfohlen | nein | via Grafana | indirekt | Logs koennen Secrets enthalten |
| Uptime Kuma | Empfohlen | Empfohlen | Empfohlen | Optional | nein | ja | Browser/PWA | gut fuer einfache Uptime |
| Healthchecks | Optional | Empfohlen | Empfohlen | Optional | nein | ja | Browser | Cron-/Job-Monitoring |
| Netdata | Optional | Empfohlen | Optional | Optional | nein | ja | Browser | Host-Telemetrie nicht oeffentlich |
| Tailscale | Empfohlen | Empfohlen | Empfohlen | Empfohlen | Desktop-App | Admin-Web | Android/iOS App | ideal fuer privaten Zugriff |
| cloudflared | Optional | Optional | Empfohlen | Empfohlen | nein | Tunnel | indirekt | nur bewusst oeffentlich |
| UFW | Optional | Empfohlen | Empfohlen | Empfohlen | nein | nein | nein | Vorsicht bei Remote-Zugriff |
| CrowdSec | Optional | Empfohlen | Empfohlen | Optional | nein | optional | nein | gute VPS-Haertung |
| Fail2Ban | Optional | Empfohlen | Empfohlen | Optional | nein | nein | nein | SSH/Webserver-Schutz |
| Trivy | Empfohlen | Empfohlen | Optional | Empfohlen | CLI | nein | nein | Container-/FS-Scan |
| Gitleaks | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | nein | vor Commit nutzen |
| Semgrep | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | nein | Codeanalyse |
| Syft | Optional | Empfohlen | Optional | Empfohlen | CLI | nein | nein | SBOM-Erstellung |
| Grype | Optional | Empfohlen | Optional | Empfohlen | CLI | nein | nein | CVE-Analyse |
| ClamAV | Empfohlen | Empfohlen | Optional | Optional | CLI/Daemon | nein | nein | lokale Dateihygiene |
| YARA | Optional | Empfohlen | Optional | Optional | CLI | nein | nein | Regel-Scans |
| n8n | Empfohlen | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser/PWA | Credentials auslagern |
| Activepieces | Optional | Optional | Optional | Optional | nein | ja | Browser | Alternative zu n8n |
| Node-RED | Empfohlen | Empfohlen | Optional | Optional | nein | ja | Browser | Smart Home/IoT |
| Mosquitto | Optional | Empfohlen | Nicht empfohlen offen | Optional intern | nein | nein | MQTT Apps | nur mit Auth/LAN/Tailnet |
| Zigbee2MQTT | Optional | Empfohlen | Nicht empfohlen | Nicht empfohlen | nein | ja | Home Assistant | USB-Dongle lokal |
| ESPHome | Optional | Empfohlen | Nicht empfohlen | Nicht empfohlen | nein | ja | Home Assistant | lokale Firmware |
| Home Assistant | Optional | Empfohlen | Nicht empfohlen ohne VPN | Optional | nein | ja | Android/iOS App | lokal/Tailscale ideal |
| Paperless-ngx | Empfohlen | Empfohlen | Optional | Optional | nein | ja | Browser/App-Clients | private Dokumente lokal |
| Apache Tika | Empfohlen | Empfohlen | Optional | Optional | nein | API | indirekt | Parser-Service |
| Docling | Empfohlen | Empfohlen | Optional | Optional | CLI/API | nein | indirekt | Dokumentanalyse |
| Stirling PDF | Empfohlen | Empfohlen | Optional | Optional | nein | ja | Browser | PDFs lokal bearbeiten |
| Nextcloud | Optional | Empfohlen | Optional | Advanced | Desktop-Client | ja | Android/iOS App | braucht Backup/TLS |
| MinIO | Optional | Empfohlen | Optional | Empfohlen | nein | ja | S3 Clients | starke Keys, Backup |
| Restic | Empfohlen | Empfohlen | Empfohlen | Empfohlen | CLI | nein | nein | Backup-Standard |
| BorgBackup | Optional | Empfohlen | Optional | Optional | CLI | nein | nein | Alternative/Ergaenzung |
| Rclone | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | Android via RC eher advanced | Cloud-Ziele bewusst |
| DuckDB | Empfohlen | Empfohlen | Optional | Optional | CLI/Lib | nein | indirekt | lokale Datenanalyse |
| JupyterLab | Empfohlen | Empfohlen | Nicht empfohlen offen | Optional | Browser | ja | Browser | Token/Auth beachten |
| Metabase | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | BI-Dashboards |
| Airbyte | Optional | Optional | Nicht empfohlen klein | Advanced | nein | ja | Browser | ressourcenintensiv |
| Meilisearch | Optional | Empfohlen | Optional | Empfohlen | nein | API | indirekt | Indexe schuetzen |
| Appsmith | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | interne Tools |
| Budibase | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | Low-Code UI |
| NocoDB | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | DB-UI absichern |
| Directus | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | API/CMS |
| ComfyUI | Optional bei GPU | Optional bei GPU | Nicht empfohlen | Advanced GPU | Browser | ja | Browser | GPU/VRAM-lastig |
| Stable Diffusion Forge | Optional bei GPU | Optional bei GPU | Nicht empfohlen | Advanced GPU | Browser | ja | Browser | Modelle gross |
| Blender | Optional | Optional | Nicht empfohlen | Render-Worker advanced | Desktopfenster | nein | nein | Desktop/GPU besser |
| RealESRGAN | Optional bei GPU | Optional bei GPU | Nicht empfohlen | Optional GPU | CLI | nein | indirekt | Upscaling |
| GFPGAN | Optional bei GPU | Optional bei GPU | Nicht empfohlen | Optional GPU | CLI | nein | indirekt | Bildrestauration |
| Rembg | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | indirekt | CPU moeglich |
| Whisper.cpp | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | indirekt | lokale STT |
| faster-whisper | Optional | Empfohlen | Optional | Optional GPU | CLI/API | nein | indirekt | GPU hilfreich |
| Piper | Empfohlen | Empfohlen | Optional | Optional | CLI/API | nein | indirekt | lokale TTS |
| Coqui TTS | Optional nur mit Python 3.9-3.11 | Optional GPU | Nicht empfohlen klein | Advanced | CLI/API | optional | indirekt | Python 3.12 inkompatibel; Piper bevorzugen |
| Aider | Empfohlen | Empfohlen | Optional | Optional | Terminal | nein | nein | Coding-Agent, Git sauber halten |
| OpenHands | Optional | Optional | Optional mit Sandbox | Advanced | Web/Container | ja | Browser | sehr kontrolliert nutzen |
| Continue.dev | Empfohlen Desktop | Optional | Nicht sinnvoll | Nicht sinnvoll | IDE-Erweiterung | nein | nein | VS Code/JetBrains |
| GitHub CLI | Empfohlen | Empfohlen | Empfohlen | Empfohlen | CLI | nein | nein | Token sicher speichern |
| act | Empfohlen | Empfohlen | Optional | Optional | CLI | nein | nein | lokale GitHub Actions |
| pre-commit | Empfohlen | Empfohlen | Empfohlen | Empfohlen | CLI | nein | nein | Repo-Hygiene |
| Promptfoo | Empfohlen | Empfohlen | Optional | Optional | CLI/Web optional | optional | nein | Eval-Daten schuetzen |
| Flowise | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | visuelle LLM-Flows |
| LangFlow | Optional | Empfohlen | Optional mit Auth | Optional | nein | ja | Browser | Python-nahe LLM-Flows |

## Ergaenzte Tool-Bewertung ab 11.18

| Tool/Baustein | MiniPC/WSL2 | VPS | GPU/Server | Status | Hinweis |
|---|---|---|---|---|---|
| LocalAI | Optional kleine Modelle | Optional | Empfohlen bei Ressourcen | optional | OpenAI-kompatibel, aber Speicherbedarf pruefen. |
| OSV-Scanner | Empfohlen | Empfohlen | Empfohlen | optional | Leichter Vulnerability-Check fuer Dependencies. |
| Lynis | Optional | Empfohlen | Empfohlen | optional | Host-Hardening-Audit, keine Auto-Fixes. |
| Glances | Empfohlen | Empfohlen | Optional | optional | Leichtes Systemmonitoring fuer MiniPC/WSL2. |
| Kopia | Optional | Optional | Optional | optional | Backup-Alternative, erst nach Restore-Test. |
| Cline/Roo Code | Desktop | Nicht sinnvoll | Nicht sinnvoll | documentation-only | IDE-Erweiterungen, nicht als Serverdienst. |
| Devcontainer-Vorlage | Empfohlen | Optional | Optional | documentation-only | Projektvorlage statt globaler Installer. |
| bats-core | Empfohlen | Empfohlen | Empfohlen | optional | Shell-Tests fuer Setup-Skripte. |
| Browserless | Nicht empfohlen klein | Optional mit Auth | Optional | experimental | Browser-Service nie offen betreiben. |
| Headscale | Nicht empfohlen fuer Einsteiger | Optional | Optional | experimental | Tailscale-Alternative mit Admin-Aufwand. |

## Standalone-MiniPC-Empfehlung

Gute Standalone-Auswahl fuer schwache bis mittlere Hardware:

- Ollama mit kleinen Modellen
- OpenClaw
- Open WebUI
- Qdrant oder ChromaDB, nicht zwingend beide
- n8n oder Huginn, nicht beide sofort
- Uptime Kuma
- Tailscale
- Restic/Rclone
- Gitleaks, Trivy, ClamAV
- Paperless-ngx/Stirling PDF nur bei Bedarf

Nicht sofort fuer Standalone:

- grosse GPU-Media-Stacks ohne GPU
- K3s
- Airbyte
- mehrere Low-Code-Plattformen parallel
- Web3/Trading-Live-Komponenten

## VPS-Empfehlung

Gute VPS-Auswahl:

- Tailscale oder cloudflared
- UFW, Fail2Ban, CrowdSec
- Uptime Kuma oder Healthchecks
- Grafana/Prometheus nur mit Auth oder intern
- LiteLLM nur wenn API-Keys sauber ausgelagert und Zugriff geschuetzt ist
- Reverse Proxy/Tunnel statt offener Admin-Ports

Nicht empfohlen auf kleiner VPS:

- ComfyUI, Stable Diffusion, Blender
- grosse RAG-Datenbanken mit privaten Dokumenten
- Home Assistant mit direktem Internetzugriff
- offene Datenbankports

## Zusatz-VPS oder K3s

Geeignet fuer:

- Monitoring-Worker
- leichte Web-UIs mit Auth
- GitOps-/DevOps-Tools
- Backup-/Sync-Ziele
- Suchindexe oder RAG nur bei sauberer Datenklassifikation

Advanced:

- K3s nur nach stabiler Docker-/Netzwerk-/Backup-Basis
- Storage und Secrets vor App-Deployment klaeren
- Auto-Updates nur mit Rollback

## myNextCloud AI

| Baustein | MiniPC/WSL2 | VPS | Raspberry Pi | Kubernetes | Risiko |
|---|---|---|---|---|---|
| myNextCloud Server Dev | geeignet | geeignet | eingeschraenkt | spaeter | mittel |
| myNextCloud Mobile Build | Windows/Android Studio empfohlen | nein | nein | nein | mittel |
| Ollama Datei-KI | geeignet bei lokalem Modell | nur mit privatem Zugriff | extern anbinden | spaeter | mittel |
| n8n Workflows | optional | geeignet mit Auth | eingeschraenkt | spaeter | mittel |
| Cloudflare Access | geeignet | geeignet | geeignet | geeignet | niedrig-mittel |
| Tailscale Admin-Zugriff | empfohlen | empfohlen | empfohlen | empfohlen | niedrig |

Default: documentation-first. Keine automatische Nextcloud-, Android-, n8n- oder Cloudflare-Installation ohne explizite Bestaetigung.

## Desktop- und App-Anbindung

| Bereich | Windows/Desktop | Android/Mobile |
|---|---|---|
| Tailscale | Desktop-App | Android/iOS App |
| Home Assistant | Browser/Desktop-App optional | offizielle App |
| Nextcloud | Desktop-Sync-Client | Android/iOS App |
| Grafana | Browser | Grafana-App oder Browser |
| Open WebUI | Browser/PWA | Browser/PWA |
| n8n/Huginn/Node-RED | Browser | Browser |
| Continue.dev | VS Code/JetBrains | nein |
| Blender | Desktopprogramm | nein |
| Android Builder | Android Studio/SDK | Zielplattform |

## Sicherheitsstandard

- Admin-UIs nicht direkt oeffentlich exponieren.
- Standardbindung: `127.0.0.1`, LAN oder Tailnet.
- Oeffentliche Freigaben nur ueber Cloudflare Tunnel oder Reverse Proxy mit Auth.
- VPS-Firewall zuerst, App danach.
- Private Dokumente und Chat-Memory bevorzugt auf MiniPC/Home-Server.
- Security-, Browser- und Agenten-Tools nur defensiv und mit Allowlist.
