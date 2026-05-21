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
| `Browser_Automation_Agent` | Automation | Playwright, Puppeteer, kontrolliertes Web-Testing | mittel | WSL2, Workstation | Crawling nur rechtskonform und bewusst |
| `Local_AI_App_Builder` | Apps | Appsmith, Budibase, NocoDB, Directus, Open WebUI | mittel | MiniPC, VPS | interne Apps default nur lokal |
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
- `Android_App_AI_Dev`
- `Desktop_App_AI_Dev`
- `Dataset_Curation_Labeling`

Sie bleiben sinnvolle Ausbaupfade, sollten aber erst nach stabilerer Tool-/Installationsabdeckung separat verdrahtet werden.
