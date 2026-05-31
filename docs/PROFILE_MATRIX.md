# Profile Matrix

Diese Matrix fasst den aktuellen Ausbauzustand als modulare Plattform zusammen. Sie trennt bewusst zwischen produktionsnahen Kernpfaden, spezialisierten Studios und Profilen mit erhoehter Risiko- oder Governance-Last.

## Kern- und Plattformprofile

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `Programmierer` | Core / Coding | lokaler Coding- und Agenten-Stack | hoch | WSL2, VPS, Workstation | aktueller Hauptfokus bei den Funktionstests |
| `LLM_Builder` | Core / LLMOps | Modellbau, Fine-Tuning, GGUF, Ollama | mittel | GPU-Workstation | hohe SSD-/VRAM-Last |
| `RAG_Wissensdatenbank` | RAG / Knowledge | Qdrant, Chroma, LightRAG, Open WebUI | mittel | MiniPC, WSL2, VPS | Dokumentrechte und PII beachten |
| `Model_Router_Gateway` | LLMOps | LiteLLM, Routing, Fallbacks, Gateway | mittel bis hoch | VPS, Kubernetes | `.env` ausserhalb des Repos halten |
| `Monitoring_Observability` | Monitoring | Prometheus, Grafana, Loki, Uptime, Langfuse | mittel | VPS, Kubernetes | Dashboards nur intern oder via Auth |
| `Backup_Recovery` | Platform Ops | Restic, Borg, Rclone, MinIO | mittel | VPS, NAS, Workstation | Restore-Tests sind Pflicht |

## Coding, Evaluation und Governance

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `AI_Project_Manager` | Coding | Repo-Struktur, Releases, Issues, lokale CI | mittel | WSL2, VPS | GitHub-Tokens nie ins Repo |
| `Prompt_Engineering_Studio` | LLMOps | Prompt-Registry, Tests, Systemprompts, Vergleiche | mittel | WSL2, Workstation | Prompt-Datensaetze koennen intern sein |
| `AI_Agent_Evaluation` | LLMOps | Regressionstests, Agenten-Benchmarks, Tracing | mittel | WSL2, VPS | Eval-Sets und Logs datensparsam halten |
| `Repo_Maintainer` | Coding | Lints, Releases, Changelogs, PR-Hygiene | mittel | WSL2, VPS | lokale Hooks und CI-Aktionen pruefen |
| `Security_DevSecOps` | Security | SAST, Secret-Scan, Container-/SBOM-Checks, sicherer Remote-Zugriff und Tunnel | mittel | VPS, Workstation | Findings vertraulich behandeln |
| `AI_Governance_Audit` | Security / Governance | Modellkarten, Audit-Logs, AI-Act-nahe Checks | mittel | VPS, Workstation | kein Ersatz fuer Rechtsberatung |
| `Cost_Energy_Optimizer` | Ops | Ressourcen, Kosten, Laufzeiten, Host-Telemetrie | mittel | MiniPC, VPS, GPU-Host | Metriken koennen Nutzungsdaten offenlegen |

## Automation, Apps und Office

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `NoCode_LowCode_AI` | Automation | n8n, Activepieces, Node-RED, Flowise, LangFlow | mittel | VPS, MiniPC | Connector-Credentials strikt trennen |
| `Browser_Automation_Agent` | Automation | Playwright, Puppeteer, GBOX, kontrolliertes Web-/Desktop-/Android-Testing | mittel | WSL2, Workstation | Crawling und Device-Automation nur rechtskonform und bewusst |
| `Local_AI_App_Builder` | Apps | Appsmith, Budibase, NocoDB, Directus, Open WebUI, GBOX | mittel | MiniPC, VPS | interne Apps default nur lokal |
| `UI-UX-Designer-Penpot-AI` | Apps / Design | Penpot, Design-Systeme, Prototyping, Design-to-Code | mittel | MiniPC, VPS, Workstation | Web-UI und MCP nur lokal oder privat freigeben |
| `Email_Office_Automation` | Office | DMS, PDF, OCR, Nextcloud, Office-Workflows | mittel | MiniPC, VPS | Mail- und Dokumentdaten lokal halten |
| `Office_Productivity` | Office | Paperless, PDF, OCR, Wissensdokumente | mittel | MiniPC, VPS | gute Basis, aber kein Mailstack |

## Data, Knowledge und Recherche

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `Data_Engineering` | Data | ETL, Storage, Data Prep, MinIO | mittel | VPS, Workstation | Rollen- und Quelltrennung wichtig |
| `Data_Analytics_BI` | Data | DuckDB, Jupyter, Metabase, Reports | mittel | MiniPC, VPS | personenbezogene Daten anonymisieren |
| `Synthetic_Data_Lab` | Data | Testdaten, Datensynthese, Eval-Fragen | mittel | Workstation | synthetische Daten klar kennzeichnen |
| `Document_Intelligence` | Knowledge | OCR, Tika, Docling, Paperless | mittel | MiniPC, VPS | sensible Dokumente nur lokal |
| `Personal_Knowledge_Memory` | Knowledge | private Memory-/RAG-Schicht | mittel | MiniPC | Sync, Backups und Verschluesselung einplanen |
| `OSINT_Research` | Knowledge | legale Recherche, Archivierung, Suchindexe | niedrig bis mittel | VPS, Workstation | kein Doxxing, keine Intrusion, keine Credential-Suche |
| `Knowledge_Librarian` | Knowledge | PDF, Markdown, Office, Scans, Paperless, Docling, lokale Suche | mittel | MiniPC, NAS, Workstation | Dokumente und Indizes lokal schuetzen |

## Wissenschaft und Forschung

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `Physik` | Science | Simulation, Messdaten, Paper, JupyterLab | mittel | Workstation, GPU optional | Ergebnisse validieren |
| `Chemie` | Science | Molekueldaten, Paper, Laborberichte | mittel | Workstation | keine Gefahrstoffanleitungen |
| `Biologie` | Science | Omics, Mikroskopie, Sensorik | mittel | Workstation, MiniPC | keine medizinische Diagnose |
| `Bioinformatik` | Science | Sequenzen, Varianten, Pipelines | mittel | Workstation, Kubernetes optional | Studiendaten pseudonymisieren |
| `Molekuelsimulation` | Science / HPC | OpenMM/GROMACS/LAMMPS-nahe Analyse | experimentell | GPU-Workstation | hoher Speicher-/GPU-Bedarf |
| `Robotik_Labor` | Science / Robotics | Laborautomation, ROS-nahe Simulation, Sensorik | experimentell | MiniPC, Edge, Workstation | Realhardware nur mit Freigabe |
| `Materialwissenschaft` | Science | Materials Informatics, Strukturen, Simulation | mittel | Workstation, GPU optional | Materialeigenschaften fachlich validieren |
| `Mathematik_Simulation` | Science | Formeln, Optimierung, numerische Simulation | mittel | MiniPC, Workstation | Modellannahmen dokumentieren |
| `Astronomie_Space_AI` | Science | FITS, Teleskopdaten, Raumfahrt-Recherche | mittel | Workstation | Standort-/Beobachtungsdaten schuetzen |
| `Medizinische_Literatur_Recherche` | Science / Medical | Paper, Evidenznotizen, Dokumentanalyse | mittel | MiniPC, Workstation | keine Diagnose, keine Therapieentscheidung |
| `Umwelt_Klima_Energie` | Science / Energy | Klima, Wetter, PV, Batterie, Verbrauch | mittel | MiniPC, Smart Home | keine kritische Schaltung ohne Freigabe |

## IoT, Media und Spezialpfade

| Profil | Kategorie | Fokus | Reifegrad | Hardware | Hinweise |
|---|---|---|---|---|---|
| `Robotics_IoT_Edge_AI` | Smart Home / IoT | Home Assistant, MQTT, Zigbee, ESPHome | mittel | MiniPC, Edge, VPS | lokale Netze und Kameradaten schuetzen |
| `Smart_Home_Automation` | Smart Home / IoT | Node-RED, Mosquitto, Zigbee2MQTT | mittel | MiniPC | Reverse Proxy und Tunnel bewusst haerten |
| `Personal_Assistant_Local_First` | Assistant | lokaler Jarvis, RAG, n8n, Open WebUI | mittel | MiniPC, Workstation | Aktionen brauchen Rollen und Freigabe |
| `Boardroom` | Assistant | strategische Entscheidungsrunde mit Rollen, Peer-Review und Chairman-Verdict | niedrig | MiniPC, Workstation | nur Vorschlag/Review, keine automatische Aktion |
| `Voice_Command_Center` | Voice / Smart Home | STT, TTS, Home Assistant, Node-RED | mittel | MiniPC, Mikrofon-Setup | kritische Befehle nur mit Bestaetigung |
| `Image_Generation_Studio` | Media | ComfyUI, Forge, Upscaling, Cleanup | mittel | GPU-Workstation | Modellrechte, VRAM und SSD einkalkulieren |
| `Video_Generation_Studio` | Media | Interpolation, Upscaling, Video-KI | niedrig bis mittel | starke GPU | hoher VRAM-/SSD-Bedarf |
| `Voice_Clone_TTS_Studio` | Media / Voice | TTS, STT, Voiceover, Voice-Clone | niedrig bis mittel | GPU optional | Ethik, Rechte und Einwilligung beachten |
| `Web3_Crypto_Agent` | Web3 Safe | Analyse, Recherche, RPC-Tooling | niedrig bis mittel | VPS, Workstation | keine Live-Orders oder Seeds als Default |
| `Web_App_Builder` | Coding / Apps | Vite/React, Dashboards, Admin-Panels | mittel | WSL2, Workstation | keine Secrets ins Frontend |
| `Repo_Maintainer_Agent` | Coding / Ops | Repo-Pflege, Registry-Checks, lokale CI, Release-Hygiene | mittel | WSL2, VPS | keine automatischen Force-Pushes |
| `Zero_Trust_Remote_Access` | Security | Tailscale, Cloudflare Tunnel, UFW, CrowdSec | mittel | MiniPC, VPS | Standard: nicht oeffentlich |
| `Kubernetes_GPU_Orchestrator` | Ops / GPU | GPU-Worker, Render, LLM, Science-Batches | experimentell | GPU-Workstation, K3s | Secrets und Worker isolieren |
| `Storage_NAS_Backup` | Storage / Backup | Restic, Borg, Rclone, MinIO, NAS | mittel | MiniPC, NAS, VPS | Restore-Tests sind Pflicht |

## Bewusst zurueckgestellt

Diese Profile wurden geprueft, aber in diesem Schritt nicht als eigene Top-Level-Profile neu angelegt, weil sie derzeit zu stark mit vorhandenen Profilen ueberlappen oder noch keine saubere Toolbasis im Repo haben:

- `Voice_Call_Agent`
- `Meeting_Assistant`
- `Legal_Tax_Document_AI`
- `Health_Fitness_Knowledge`
- `Android_App_AI_Dev` / `myBox` mit `gbox`
- `Desktop_App_AI_Dev`
- `Dataset_Curation_Labeling`

Sie bleiben sinnvolle Ausbaupfade, sollten aber erst nach stabilerer Tool-/Installationsabdeckung separat verdrahtet werden.
# Zusatz: Planned Profile 2026

Neue Profile unter `docs/Profile/` sind standardmaessig `planned` oder `beta`.
Sie starten keine schweren Installer automatisch.

| Profil | Status | Schwerpunkt |
|---|---|---|
| Job_Queue_Manager | beta | lokale Job Queue |
| DNS_DDoS_Hardening | planned | HE DNS, DDoS, VPS Hardening |
| Mailserver_AI_Assistant | planned | Stalwart/OpenClaw/Ollama Mail |
| Codex_Queue_Worker | planned | Codex-Auftraege seriell |
| Memory_Import_Export | planned | Memory/RAG Governance |
## Voice Studio Erweiterung 2026

| Profil | Status | Ressourcen | Zielgeraet | Zweck |
| --- | --- | --- | --- | --- |
| Voice_Studio | planned | medium | WSL2, MiniPC, VPS | Zentrales Studio fuer TTS, Voice-Over, Sprecherrollen und lokale Audio-Workflows. |
| AI_Singer | planned | gpu-heavy | GPU Workstation | KI-Gesang, Singer-Training und Song-Demos. |
| AI_Choir | planned | gpu-heavy | GPU Workstation | SATB-Chor, grosse Layer-Arrangements und Chor-Demos. |
| Voice_Clone | planned | gpu-heavy | GPU Workstation | Voice-Cloning nur fuer eigene oder freigegebene Stimmen. |
| Podcast_Studio | planned | medium | WSL2, MiniPC, VPS | Podcast-Skript, Sprecherrollen, TTS-Drafts und Export. |
| Audiobook_Studio | planned | medium | WSL2, MiniPC, VPS | Hoerbuchproduktion mit Kapiteln, Rollenstimmen und Queue. |
| Voice_Assistant | beta | medium | Home Server, MiniPC | Lokaler Sprachassistent, Piper als Standard, Home Assistant optional. |
| Dubbing_Studio | planned | gpu-heavy | GPU Workstation | Synchronisation, Voice-Over und Mehrsprecher-Dubbing mit Freigabe. |
| Voice_Laboratory | planned | gpu-heavy | GPU Workstation | Experimentelles Labor fuer neue Voice-, Singing- und Chor-Modelle. |

Alle Voice-Studio-Profile sind read-only-first und installieren schwere Komponenten nicht automatisch. Rohaufnahmen, Stimmmodelle und Datasets gehoeren nach `~/.openclaw_ultimate_user_data/voice_studio/`, nicht ins Repository.
## AI Media Production Studio 2026

| Profil | Status | Ressourcen | Zielgeraet | Zweck |
| --- | --- | --- | --- | --- |
| AI_Actor | planned | gpu-heavy | GPU Workstation | Virtueller Schauspieler fuer Dialoge, Monologe und Emotionen. |
| AI_Actress | planned | gpu-heavy | GPU Workstation | Virtuelle Schauspielerin fuer Dialoge, Monologe und Emotionen. |
| AI_News_Anchor | planned | heavy | Gaming PC / VPS-Orchestrierung | Nachrichtensprecher fuer News, Wetter, Sport und Technik-News. |
| AI_Moderator | planned | heavy | Gaming PC | Moderator fuer Shows, Livestreams und Tutorials. |
| AI_Podcast_Host | planned | medium | WSL2 / MiniPC / VPS | Podcast-Host mit Skript, Rollenstimme und Show Notes. |
| AI_Radio_Host | planned | medium | WSL2 / MiniPC | Radio-Host fuer Ansagen, Sendungen und Jingles. |
| AI_Documentary_Narrator | planned | medium | WSL2 / MiniPC | Dokumentationssprecher mit ruhigem Stil. |
| AI_Audiobook_Narrator | planned | medium | WSL2 / MiniPC | Hoerbuchsprecher fuer Kapitel und Rollenstimmen. |
| AI_Dubbing_Artist | planned | gpu-heavy | GPU Workstation | Synchronsprecher fuer Dubbing, Voice-Over und LipSync. |
| AI_Comedian | planned | medium | WSL2 / MiniPC | Comedy-Rolle fuer Sketche und Pointen. |
| AI_Sports_Commentator | planned | medium | WSL2 / MiniPC | Energiegeladener Sportkommentator. |
| AI_Interviewer | planned | medium | WSL2 / MiniPC | Interviewrolle fuer Podcasts und Expertenformate. |
| AI_Influencer | planned | heavy | Gaming PC | Virtuelle Content-Persona mit Kennzeichnungspflicht. |
| AI_Virtual_Human | planned | gpu-heavy | RTX Workstation | Vollstaendige virtuelle Person mit Stimme, Avatar und Rollenprofil. |
| AI_Film_Director | planned | medium | WSL2 / VPS / GPU | Regieprofil fuer Drehbuch, Storyboard und Schnitt. |
| AI_Casting_Director | planned | medium | WSL2 / MiniPC | Rollenbibliothek, Casting und Stimmenauswahl. |
| AI_Voice_Director | planned | medium | WSL2 / MiniPC | Sprecherfuehrung, Emotion, Timing, Dubbing und Chor. |

Alle Profile sind documentation-first. Avatar-, LipSync- und Deepfake-nahe Workflows benoetigen Einwilligung, KI-Kennzeichnung und manuelle Freigabe.

## Next-Level-Ergaenzungen 2026-05-31

| Profil | Zweck | Status | Ressourcen | Zielhost |
| --- | --- | --- | --- | --- |
| AI_Model_Router_Gateway | Modellrouting, Fallbacks, Kostenkontrolle, Local-first | planned | medium | WSL2, MiniPC, Oracle VPS, GPU Server |
| Voice_AI_Callcenter | STT/TTS, Telefonie, Support-Agenten | planned | medium | MiniPC, Oracle VPS, GPU Workstation |
| Email_AI_Office | Mailserver plus KI-Sortierung und Antwortentwuerfe | planned | medium | Oracle VPS, Home Server |
| Observability_Control_Tower | Monitoring fuer Dienste, Hosts, Queue und Agenten | planned | medium | Oracle VPS, Home Server, Kubernetes |
| Security_BlueTeam_SOC | Defensive Logs, IDS, Schwachstellenanalyse | planned | heavy | Oracle VPS, Home Server, Kubernetes |
| Network_DDNS_ZeroTrust | HE/DDNS, VPN, Reverse Proxy, Zero Trust | planned | medium | Oracle VPS, Raspberry Pi, Home Server |
| Media_Music_Video_Studio | Audio-/Video-/Bildpipelines mit GPU-Opt-in | planned | gpu-heavy | RTX/GPU Workstation |

Alle Profile bleiben `documentation-first`, bis sichere Installer, Uninstaller, Doctor-Checks und Rollback-Pfade existieren.

