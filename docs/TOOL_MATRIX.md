# Tool Matrix

Diese Matrix gruppiert die wichtigsten benutzerrelevanten Tools. Sie ist bewusst kompakter als `scripts/tools/` und dient als Orientierungs- und Planungsübersicht.

## LLM / RAG / Agenten

| Tools | Hinweis |
|---|---|
| Ollama, LiteLLM, Open WebUI | lokale und hybride Modellnutzung |
| OpenClaw, OpenManus, AutoGPT | Agenten- und Workflow-Ebene |
| LangGraph, CrewAI, AutoGen | orchestrierte Multi-Step-Agenten |
| Qdrant, ChromaDB, LightRAG, LlamaIndex, LangChain | RAG, Embeddings, Wissensspeicher |
| Langfuse, OpenLIT | Observability für LLM-Aufrufe |
| Aider, OpenHands, OpenCode, Continue.dev | Coding-Agenten und Pairing |
| MCPO, Browser-/Filesystem-/GitHub-MCP | Toolserver und sichere Integrationen |

## Security

| Tools | Hinweis |
|---|---|
| Trivy, Gitleaks, Semgrep | Container-, Secret- und Code-Scans |
| Syft, Grype | SBOM und Vulnerability-Korrelation |
| Nmap, Nikto | Netz- und Web-Oberflächentests |
| Fail2Ban, CrowdSec, UFW | Host-Härtung und Schutzschicht |
| Guardrails AI, Promptfoo | LLM-Sicherheit, Prompt-Evaluation |

## Monitoring / Betrieb

| Tools | Hinweis |
|---|---|
| Prometheus, Grafana, Loki, Promtail | Metriken, Logs, Dashboards |
| Uptime Kuma, Healthchecks, Netdata | Verfügbarkeit und Host-Blick |
| Node Exporter, OpenTelemetry | Host- und Telemetrie-Bausteine |
| Watchtower | Container-Update-Helfer, nur bewusst aktivieren |

## DevOps / Plattform

| Tools | Hinweis |
|---|---|
| Docker, Docker Compose, Podman | Container-Laufzeit und Dev-Sandbox |
| K3s, kubectl, Helm, Kustomize, k9s | optionale Kubernetes-Ebene |
| Forgejo, GitHub CLI, Act, Renovate | Repo-, PR- und CI/CD-Workflow |
| Ansible, OpenTofu, Terraform-nah | Infrastruktur-Automatisierung |

## Storage / Backup / Daten

| Tools | Hinweis |
|---|---|
| PostgreSQL, Redis, SQLite | klassische Datenhaltung |
| MinIO, Supabase, Nextcloud | Objekt-, App- und Datei-Storage |
| Restic, BorgBackup, Rclone | Backup und Wiederherstellung |
| Airbyte, Metabase, DuckDB, dbt, JupyterLab | Datenpipelines und BI |

## Automation / UI / DMS

| Tools | Hinweis |
|---|---|
| n8n, Activepieces, Huginn, Pipedream | Workflow-Automation |
| Node-RED, Mosquitto, Zigbee2MQTT, ESPHome | Home- und IoT-Automation |
| Appsmith, Budibase, NocoDB, Directus | No-/Low-Code-Oberflächen |
| Paperless-ngx, Stirling PDF, OCRmyPDF, Apache Tika, Docling, Pandoc | Dokumenten- und OCR-Schicht |

## Media / Bild / Video / Audio

| Tools | Hinweis |
|---|---|
| ComfyUI, Stable Diffusion WebUI Forge, ControlNet | Bild- und Node-Workflows |
| RealESRGAN, GFPGAN, Rembg | Upscaling, Gesichter, Freistellung |
| SVD, AnimateDiff | Video-Generierung |
| FFmpeg, yt-dlp | Medienkonvertierung und Pipelines |
| Whisper.cpp, faster-whisper | STT |
| Piper, Coqui TTS | TTS |
| Demucs, librosa, pydub | Musik, Stems und Audioanalyse |
| Blender | 3D- und Asset-Workflows |
