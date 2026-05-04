# Profil-Index

Dieses Verzeichnis enthält die aktuell gepflegten Profilseiten. `docs/Profil/` bleibt die historisch gewachsene Quell-/Altstruktur, `docs/Profile/` ist die benutzerorientierte, GitHub-taugliche Zielstruktur.

## Core

| Profil | Zweck |
|---|---|
| `Programmierer` | klassisches Coding, Agenten, Automatisierung |
| `LLM_Builder` | Fine-Tuning, GGUF, Ollama-Import |

## Coding

| Profil | Zweck |
|---|---|
| `Local_Codex_IDE_Agent` | lokaler Coding-Agent, Tests, Patches, Devcontainer |
| `Repo_Maintainer` | Repo-Pflege, Hooks, Releases, lokale CI |
| `Developer_CI_CD` | GitHub-/Forgejo-nahe CI/CD-Workflows |

## LLMOps

| Profil | Zweck |
|---|---|
| `MCP_Agent_Tools` | MCP, Toolserver, GitHub, Browser |
| `Model_Evaluation_Benchmark` | Benchmarking und Prompt-/RAG-Evals |
| `Prompt_Engineering_Lab` | Prompt-Registry, Tests, Regressionen |
| `Monitoring_Observability` | Metrics, Logs, Dashboards, Traces |
| `Backup_Recovery` | Backup, Restore, Offsite-Strategien |

## RAG / Knowledge

| Profil | Zweck |
|---|---|
| `RAG_Wissensdatenbank` | klassischer lokaler RAG-Stack |
| `Knowledge_Graph_RAG` | Graph-RAG und Beziehungswissen |
| `Personal_Knowledge_Memory` | lokale Memory-/RAG-Schicht |
| `Personal_Knowledge_OS` | Wissensbetrieb mit Sync und Suche |

## Automation

| Profil | Zweck |
|---|---|
| `Browser_Agent_Web_Automation` | Browser-Agenten, Tests, Crawling |
| `Agent_Orchestrator` | Rollen, Routing, Workflows |
| `Content_Automation` | Content- und Publishing-Pipelines |

## Media

| Profil | Zweck |
|---|---|
| `Image_Generation` | Bild-KI und Asset-Workflows |
| `Image_Generation_Studio` | erweiterte lokale Bild-Pipelines |
| `Video_Generation` | Video-KI und Upscaling |
| `Video_Generation_Studio` | Studio-orientierte Video-Workflows |
| `Voice_Assistant` | STT, TTS, Wakeword-nahe Flows |
| `Voice_Clone_TTS_Studio` | Voiceover und TTS-Studiosetup |
| `Music_AI_Studio` | Musik, Stems, Audio-Experimente |
| `Game_Dev_AI` | Assets, Blender, Kreativpipelines |
| `Audio_Voice_Music` | zusammengefasste Audio-Basis |

## Data

| Profil | Zweck |
|---|---|
| `Data_Engineering` | ETL, Datenpipelines, Vorbereitung |
| `Data_Analytics_BI` | BI, Reports, Jupyter, Metabase |
| `Document_AI` | OCR, PDF, DMS, Verträge |
| `Document_Intelligence` | weiter gefasste Dokumentanalyse |
| `Dataset_Curation_Labeling` | Daten sammeln, bereinigen, annotieren |
| `Synthetic_Data_Generator` | synthetische Trainings- und Testdaten |
| `AI_App_Builder` | interne KI-Webapps und Dashboards |

## Security

| Profil | Zweck |
|---|---|
| `Security_DevSecOps` | Secret-, SBOM- und Container-Scans |
| `Compliance_Privacy` | Policies, DSGVO, Governance |
| `Privacy_Anonymization_Redaction` | PII-Erkennung und Schwärzung |

## DevOps / SRE

| Profil | Zweck |
|---|---|
| `DevOps_SRE` | Betrieb, GitOps, Rollback, Clusterpflege |
| `DevOps_SRE_Agent` | operativer Agentenfokus für SRE |

## Office

| Profil | Zweck |
|---|---|
| `Office_Productivity` | DMS, PDF, Dokumente |
| `Email_Calendar_Office_Agent` | Kalender, Aufgaben, DMS |
| `Self_Hosted_Cloud_Sync` | Nextcloud, Syncthing, MinIO, Backups |

## Smart Home / IoT

| Profil | Zweck |
|---|---|
| `Smart_Home_Automation` | MQTT, Node-RED, ESPHome |
| `Smart_Home_AI_Assistant` | Sprach-/Home-Automation |
| `Robotics_IoT_Edge_AI` | Edge-AI, Sensoren, Firmware |

## Web3 Safe

| Profil | Zweck |
|---|---|
| `Web3_Crypto_Tools` | Tooling ohne Default-Live-Ausführung |
| `Web3_Crypto_Agent` | agentischer Web3-Safe-Mode |
| `Trading_Crypto_Web3` | Analyse und Safe-Mode-Trading |
| `Trading_Analysis` | Backtesting und Marktanalyse |
| `Trading_Execution_Manual_Mode` | strikt manuelle Ausführung |

## Research

| Profil | Zweck |
|---|---|
| `OSINT_Research_Safe` | legale Recherche, Archivierung, Monitoring |
| `Research_Agent` | Quellen- und Repo-Recherche |
| `Education_Tutor` | Lernassistent mit RAG-Bausteinen |

## Strukturhinweise

- `Document_AI` und `Document_Intelligence` bleiben getrennt: ersteres ist der engere Produktionspfad, letzteres das breitere Analyseprofil.
- `Image_Generation` und `Image_Generation_Studio` sowie `Video_Generation` und `Video_Generation_Studio` sind bewusst als Basis- und Heavy-Variante getrennt.
- Historische Dubletten in `docs/Profil/` bleiben als Altbestand erhalten, die aktive Pflege findet in `docs/Profile/` statt.
