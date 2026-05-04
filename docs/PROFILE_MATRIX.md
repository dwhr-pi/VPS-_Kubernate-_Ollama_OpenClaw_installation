# Profile Matrix

Die Matrix priorisiert die produktionsnaeheren und aktuell strategisch wichtigsten Profile.

| Profil | Taxonomie | Hauptzweck | Wichtige Tools | Reifegrad | Sicherheit |
|---|---|---|---|---|---|
| `Security_DevSecOps` | Security | Secret-, SBOM- und Container-Scans | Trivy, Gitleaks, TruffleHog, Syft, Grype | mittel | Findings und Reports vertraulich behandeln |
| `Local_Codex_IDE_Agent` | Coding | lokaler Coding-Agent und Sandbox | Aider, OpenHands, Continue.dev, act, Ruff | mittel | Agenten nur mit Review und ohne Secrets |
| `Browser_Agent_Web_Automation` | Automation | Browser-Tasks, Tests, Research | Playwright, Browser Use, ArchiveBox, SearXNG | mittel | keine Credentials oder fremden Konten als Default |
| `Model_Evaluation_Benchmark` | LLMOps | Evaluations- und Benchmarking-Schicht | Promptfoo, LM Harness, Ragas, Langfuse | mittel | Prompt-/Eval-Daten schuetzen |
| `Knowledge_Graph_RAG` | RAG / Knowledge | Graph-RAG und strukturierte Suche | Neo4j, Qdrant, LightRAG, Haystack | niedrig bis mittel | Wissensgraphen besonders absichern |
| `Dataset_Curation_Labeling` | Data | Daten sammeln und annotieren | DVC, Label Studio, Argilla, DuckDB | mittel | Datenquellen, Lizenzen, PII sauber trennen |
| `Synthetic_Data_Generator` | Data | synthetische Test- und Trainingsdaten | Distilabel, Argilla, LangChain | niedrig bis mittel | Bias und Halluzinationen pruefen |
| `Privacy_Anonymization_Redaction` | Security | Redaction und DSGVO-nahe Vorverarbeitung | Presidio, OCRmyPDF, Tesseract | mittel | Zwischenartefakte und Logs schuetzen |
| `Email_Calendar_Office_Agent` | Office | Kalender, Aufgaben, DMS | Radicale, Vikunja, Paperless, Nextcloud | niedrig bis mittel | nur lokal oder hinter Auth freigeben |
| `Self_Hosted_Cloud_Sync` | Office | Sync-, Cloud- und Backup-Schicht | Nextcloud, Syncthing, MinIO, Restic | mittel | Public Exposure strikt vermeiden |
| `AI_App_Builder` | Data | lokale KI-Webapps und Dashboards | FastAPI, Streamlit, Gradio, Appsmith | mittel | UIs nur auf localhost oder mit Auth |
| `Robotics_IoT_Edge_AI` | Smart Home / IoT | Edge-AI und Firmware-Workflows | PlatformIO, OpenCV, ESPHome, MQTT | niedrig bis mittel | keine ungetesteten Flows auf reale Aktoren |
| `OSINT_Research_Safe` | Research | legale Recherche und Archivierung | SearXNG, ArchiveBox, changedetection.io | mittel | klare Safety-Grenzen, kein Doxxing |

## Duplikat- und Strukturhinweise

- `Document_AI` ist jetzt der engere Produktionspfad; `Document_Intelligence` bleibt das breitere Analyseprofil.
- `Data_Engineering` existiert nur einmal in der Registry und ist als Data-Profil verankert.
- `Image_`/`Video_` Basis und `*_Studio` Heavy-Varianten bleiben nebeneinander bestehen, weil Ressourcen- und Bedienpfade unterschiedlich sind.
