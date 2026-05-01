# Profile Matrix

Diese Matrix zeigt die wichtigsten Profilfamilien mit Fokus, Reifegrad und Sicherheitsbesonderheiten.

| Profil | Kategorie | Hauptzweck | Wichtige Tools | Reifegrad | Sicherheit |
|---|---|---|---|---|---|
| `Programmierer` | Kern | Coding + Agenten | Ollama, OpenClaw, Huginn, LangGraph | hoch | Shell-/Browser-Agenten nur bewusst nutzen |
| `LLM_Builder` | Kern | Fine-Tuning + GGUF + Ollama | Unsloth, LLaMA Factory, Axolotl | mittel | Trainingsdaten lokal halten |
| `RAG_Wissensdatenbank` | Betrieb | lokales RAG | Open WebUI, LightRAG, Qdrant, Chroma | mittel | sensible Dokumente nicht ungeprüft importieren |
| `Security_DevSecOps` | Betrieb | Container-, Secret- und Code-Scans | Trivy, Gitleaks, Semgrep, Syft, Grype | mittel | Findings vor Auto-Fixes prüfen |
| `Monitoring_Observability` | Betrieb | Dashboards, Logs, Metriken | Prometheus, Grafana, Loki, Uptime Kuma | mittel | öffentliche Dashboards absichern |
| `Backup_Recovery` | Betrieb | Backup und Restore | Restic, Borg, Rclone | mittel | Restore regelmäßig testen |
| `MCP_Agent_Tools` | Betrieb | MCP, Toolserver, sichere Agentenzugriffe | MCPO, Browser, Filesystem, GitHub | mittel | Shell-MCP nur mit Warnhinweis |
| `Image_Generation` | Betrieb | kompakte Bild-KI | ComfyUI, Forge, ControlNet | mittel | GPU/VRAM prüfen |
| `Video_Generation` | Betrieb | kompakte Video-KI | SVD, AnimateDiff, FFmpeg | niedrig bis mittel | sehr hoher Speicherbedarf |
| `Audio_Voice_Music` | Betrieb | TTS, STT, Audio-Workflows | Whisper.cpp, Piper, Coqui, FFmpeg | mittel | Stimmen und Modelle sauber lizenzieren |
| `Trading_Crypto_Web3` | Betrieb | Paper-Trading und Analyse | Zenbot, Web3 APIs, CCXT-nah | niedrig bis mittel | Live-Trading aus Prinzip nicht Default |
| `Smart_Home_Automation` | Betrieb | lokale Hausautomation | Home Assistant, Node-RED, Mosquitto | mittel | öffentliche Ports und Tunnel härten |
| `Office_Productivity` | Betrieb | OCR, PDF, DMS | Paperless, Stirling PDF, OCRmyPDF | mittel | Dokumentenschutz und DSGVO beachten |
| `Data_Engineering` | Betrieb | Datenplattform | PostgreSQL, Redis, MinIO, Metabase | mittel | Datenbanken nicht offen ins Netz hängen |
| `Developer_CI_CD` | Betrieb | DevOps, CI/CD, GitOps | Forgejo, Act, Helm, kubectl, Renovate | mittel | Secrets und Runner absichern |
| `Image_Generation_Studio` | Studio | tiefe Bild-Workflows | ComfyUI, Forge, GFPGAN, Rembg, RealESRGAN | mittel | GPU, Modelle und Speicher prüfen |
| `Video_Generation_Studio` | Studio | tiefe Video-Workflows | ComfyUI, SVD, AnimateDiff, FFmpeg | niedrig bis mittel | VRAM und Batch-Storage kritisch |
| `Voice_Clone_TTS_Studio` | Studio | Voiceover und Sprachklone | Piper, Coqui XTTS, faster-whisper | mittel | Stimmen nur mit Einwilligung nutzen |
| `Music_AI_Studio` | Studio | Musik, Stems, Analyse | Demucs, FFmpeg, librosa, MusicGen | mittel | keine geschützten Werke hochladen |
| `Web3_Crypto_Agent` | Studio | On-Chain-Checks, Wallet-Monitoring | Web3 APIs, Exchange APIs, Zenbot-Bausteine | niedrig bis mittel | niemals Seed/PK speichern |
| `Smart_Home_AI_Assistant` | Studio | HA + Voice + ESPHome | Node-RED, Mosquitto, Zigbee2MQTT, ESPHome | mittel | LAN-Segmentierung empfohlen |
| `Document_Intelligence` | Studio | OCR, PDF, Vertrags- und Rechnungsanalyse | Apache Tika, Docling, Paperless, Pandoc | mittel | sensible Unterlagen lokal halten |
| `Personal_Knowledge_Memory` | Studio | Memory und privates RAG | Qdrant, Chroma, LangChain, LlamaIndex | mittel | Export/Import und Löschkonzept nötig |
| `DevOps_SRE_Agent` | Studio | SRE- und Plattformbetrieb | Docker, K3s, Helm, Ansible, CrowdSec | mittel | produktive Systeme nicht blind automatisieren |
| `Data_Analytics_BI` | Studio | BI, Notebooks, Reports | DuckDB, JupyterLab, Metabase, Grafana | mittel | personenbezogene Daten anonymisieren |
| `Game_Dev_AI` | Studio | Assets, Blender, Pipeline-Hilfen | Blender, ComfyUI, Forge | niedrig bis mittel | Unity/Godot-Exporte projektabhängig |
| `Education_Tutor` | Studio | Lernassistent und RAG aus Lernmaterial | Open WebUI, Qdrant, JupyterLab, Docling | mittel | Lerninhalte und Prüfungsdaten lokal schützen |
