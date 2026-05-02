# Profile Matrix

Diese Matrix gruppiert die wichtigsten Profilfamilien mit Fokus, Reifegrad und Sicherheitsbesonderheiten.

| Profil | Kategorie | Hauptzweck | Wichtige Tools | Reifegrad | Sicherheit |
|---|---|---|---|---|---|
| `Programmierer` | Core | Coding + Agenten | Ollama, OpenClaw, Huginn, LangGraph | hoch | Shell-/Browser-Agenten nur bewusst nutzen |
| `LLM_Builder` | Core | Fine-Tuning + GGUF + Ollama | Unsloth, LLaMA Factory, Axolotl | mittel | Trainingsdaten lokal halten |
| `RAG_Wissensdatenbank` | LLMOps | lokales RAG | Open WebUI, LightRAG, Qdrant, Chroma | mittel | sensible Dokumente nicht ungeprüft importieren |
| `Security_DevSecOps` | Security | Container-, Secret- und Code-Scans | Trivy, Gitleaks, Semgrep, Syft, Grype | mittel | Findings vor Auto-Fixes prüfen |
| `Monitoring_Observability` | LLMOps | Dashboards, Logs, Metriken | Prometheus, Grafana, Loki, Uptime Kuma | mittel | öffentliche Dashboards absichern |
| `Backup_Recovery` | LLMOps | Backup und Restore | Restic, Borg, Rclone | mittel | Restore regelmäßig testen |
| `MCP_Agent_Tools` | LLMOps | MCP, Toolserver, sichere Agentenzugriffe | MCPO, Browser, Filesystem, GitHub | mittel | Shell-MCP nur mit Warnhinweis |
| `DevOps_SRE` | DevOps | GitOps, Rollback, Clusterpflege | Ansible, OpenTofu, Helm, Argo CD, Velero | mittel | produktive Cluster nicht blind verändern |
| `Repo_Maintainer` | DevOps | Repo-Pflege, Releases, lokale CI | GitHub CLI, act, shellcheck, actionlint | mittel | Release- und GitHub-Tokens schützen |
| `Data_Engineering` | Data | ETL, RAG-Vorbereitung, Pipelines | DuckDB, Prefect, MinIO, PostgreSQL, pgvector | mittel | Datenquellen und Rechte sauber trennen |
| `Document_AI` | Data | OCR, PDF, Verträge, Akten | OCRmyPDF, Tesseract, Paperless, Tika, Docling | mittel | sensible Dokumente lokal schützen |
| `Data_Analytics_BI` | Data | BI, Jupyter, Reports | DuckDB, JupyterLab, Metabase, Grafana | mittel | personenbezogene Daten anonymisieren |
| `Image_Generation` | Media | Bild-KI, Asset-Workflows | ComfyUI, Forge, Fooocus, InvokeAI | mittel | große Modellcaches einkalkulieren |
| `Video_Generation` | Media | Video-KI, Interpolation, Upscaling | ComfyUI, Forge, SVD, RIFE, Blender | niedrig bis mittel | sehr hoher VRAM-/SSD-Bedarf |
| `Voice_Assistant` | Smart Home | STT, TTS, Wakeword, Voice-Automation | Whisper.cpp, faster-whisper, Piper, openWakeWord | mittel | Mikrofon- und Rauminformationen schützen |
| `Smart_Home_Automation` | Smart Home | Home Assistant + MQTT | Node-RED, Mosquitto, HA | mittel | öffentliche Ports und Tunnel härten |
| `Web3_Crypto_Tools` | Web3 | Contract- und RPC-Tooling | Foundry, Hardhat, Ethers.js, Web3.py | niedrig bis mittel | keine Seeds oder Private Keys speichern |
| `Compliance_Privacy` | Compliance | DSGVO, Policies, Secret-/SBOM-Checks | OPA, Gitleaks, TruffleHog, Trivy | mittel | Findings vertraulich behandeln |
| `Personal_Knowledge_OS` | Knowledge | Notizen, Suche, Sync, Memory | Joplin, Meilisearch, Qdrant, Syncthing | mittel | Wissensdaten lokal und verschlüsselt halten |
| `Education_Tutor` | Knowledge | Lernassistent und RAG aus Lernmaterial | Open WebUI, Qdrant, JupyterLab, Docling | mittel | Lerninhalte und Prüfungsdaten lokal schützen |
