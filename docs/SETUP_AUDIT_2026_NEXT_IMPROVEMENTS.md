# Setup Audit 2026 Next Improvements

## Was ist bereits gut?
- Das Setup hat bereits breite Profil-, Tool-, Security-, Mail-, Media-, Voice-, Queue- und HE/Oracle/Homecluster-Dokumentation.
- Schwere Tools werden zunehmend als `planned`, `optional`, `experimental` oder `documentation-first` markiert.
- Installationslogs und Metriken liegen ausserhalb des Repositories unter `~/.openclaw_ultimate_user_data`.
- Der Coqui-TTS-Installer zeigt bereits gute Preflight-Logik fuer Python-Version, WSL-Speicher und Windows-C:-Speicher.
- Der Job-Queue-Ansatz ist als Schutz gegen parallele schwere Agentenjobs angelegt.

## Was ist doppelt?
- Mehrere Profilnamen beschreiben aehnliche Rollen: `Job_Queue_Manager`, `Queue_Worker_Orchestrator`, `Resource_Scheduler`.
- Media-/Voice-Dokumente existieren teils als historische Top-Level-Dateien und zusaetzlich in neuen Unterverzeichnissen.
- Security-Profile ueberschneiden sich bei Firewall, DDoS, Zero Trust, Supply Chain und Secrets.
- RAG-/Document-Profile ueberschneiden sich bei Docling, Tika, OCR, Paperless und Nextcloud.

## Was fehlt wirklich noch?
- Einheitliche Registry-Pruefung fuer Tools mit Ports, Secrets, Doctor-Check und Uninstaller.
- Minimaler Queue-Orchestrator mit Pause/Resume und klarer Config unter `~/.openclaw/job-queue/config.env`.
- Doctor-Checks fuer Mail-DNS, Observability, Queue, Ressourcenbudget und Secrets.
- Konkrete Low-Resource-Pfade fuer MiniPC/WSL2.
- Konsolidierte Link- und Matrixpflege zwischen alten Top-Level-Dokumenten und neuer Struktur.

## Was ist zu schwer fuer MiniPC/WSL2?
- Airbyte, Kubernetes/k3s, vLLM, grosse Avatar-/Video-Tools, ComfyUI mit grossen Modellen, DiffSinger, RVC, Seed-VC, Hallo2, SkyReels-A1, EMO.
- Grafana/Prometheus/Loki als voller Stack kann fuer MiniPC/WSL2 zu schwer sein; Glances oder Netdata sind bessere Starts.
- Mailserver-Produktivbetrieb ist auf WSL2 nicht sinnvoll; besser Oracle VPS mit DNS/rDNS/Firewall.

## Was sollte nur optional installiert werden?
- Docker/Kubernetes, Cloudflare, vLLM, LocalAI, Airbyte, Activepieces, Nextcloud, Stalwart-Produktion, RVC/DiffSinger/Avatar-Stacks.
- Infisical/OpenBao nur, wenn Betrieb, Backup und Zugriffskontrolle verstanden sind.
- Android-Sicherheitsanalyse-Tools nur fuer eigene oder autorisierte Apps.

## Was braucht Doctor-/Preflight-Pruefung?
- Python-Versionen fuer Coqui/XTTS, Node/pnpm fuer n8n/OpenWebUI, Docker/Podman nur optional, GPU/VRAM fuer Media-Tools.
- Mail: MX, SPF, DKIM, DMARC, PTR/rDNS, Ports, Rate-Limits.
- Queue: Config, Lockfiles, laufende Worker, haengende Jobs, Loggroesse.
- Netzwerk: UFW/nftables, WireGuard, Reverse Proxy, oeffentliche Ports.

## Was braucht Sicherheitswarnungen?
- Voice-Cloning, Avatarvideo, LipSync, AI-Actors, Android-MitM, Mail-KI-Antworten, Browser-/MCP-Automation, Trading, Robotik und Smart Home.
- Admin-Panels duerfen nicht oeffentlich ohne Auth erreichbar sein.
- API-Keys und Tokens duerfen nie in Markdown, Logs oder Git landen.

## Prioritaeten
- P0: Secrets, Ports, Queue, Ressourcenchecks, README-Startpfad.
- P1: Tool-/Profil-Registry-Sync, Doctor-Skripte, Mail-DNS-Checks.
- P2: echte Installer nur nach Dry-Run, Status, Uninstaller, Log und Rollback.

