# Tool Matrix

Diese Matrix gruppiert die wichtigsten benutzerrelevanten Tools. Sie ist bewusst kompakter als `scripts/tools/`.

## LLM / RAG / Agenten

| Tools | Hinweis |
|---|---|
| Ollama, LiteLLM, Open WebUI | lokale und hybride Modellnutzung |
| OpenClaw, OpenManus, AutoGPT | Agenten- und Workflow-Ebene |
| LangGraph, CrewAI, AutoGen | orchestrierte Multi-Step-Agenten |
| Qdrant, ChromaDB, LightRAG, LlamaIndex, LangChain | RAG, Embeddings, Wissensspeicher |
| Langfuse, OpenLIT | Observability für LLM-Aufrufe |
| Aider, OpenHands, OpenCode, Continue.dev | Coding-Agenten und Pairing |

## Security / Compliance

| Tools | Hinweis |
|---|---|
| Trivy, Gitleaks, TruffleHog, Semgrep | Secret-, Container- und Code-Scans |
| Syft, Grype | SBOM und Vulnerability-Korrelation |
| Nmap, Nikto | Netz- und Web-Oberflächentests |
| Fail2Ban, CrowdSec, UFW | Host-Härtung und Schutzschicht |
| OPA, Guardrails AI, Promptfoo | Policies und LLM-Sicherheit |

## DevOps / Betrieb

| Tools | Hinweis |
|---|---|
| Docker, Docker Compose Plugin, Podman | Container-Laufzeit und Sandbox |
| K3s, kubectl, Helm, Kustomize, k9s | optionale Kubernetes-Ebene |
| Ansible, OpenTofu, Velero | Infrastruktur, Rollout, Backup |
| Argo CD, Flux, kubectx/kubens | GitOps und Clusterbedienung |
| GitHub CLI, Act, Pre-Commit, Actionlint, ShellCheck, Shfmt, Hadolint | Repo- und CI-Pflege |

## Monitoring / Health

| Tools | Hinweis |
|---|---|
| Prometheus, Grafana, Loki, Promtail | Metriken, Logs, Dashboards |
| Uptime Kuma, Healthchecks, Netdata | Verfügbarkeit und Host-Blick |
| Grafana Alloy, cAdvisor, Node Exporter | Container- und Host-Telemetrie |

## Data / Dokumente

| Tools | Hinweis |
|---|---|
| PostgreSQL, pgvector, DuckDB, SQLite, sqlite-vec | Daten- und Vektorspeicher |
| MinIO, Supabase, Nextcloud | Objekt- und App-Storage |
| Prefect, Airbyte, dbt, Metabase, JupyterLab | ETL, BI und Reports |
| Apache Tika, Docling, OCRmyPDF, Tesseract, Marker, Pandoc | Dokument- und OCR-Schicht |
| Paperless-ngx, Stirling PDF, LibreOffice headless | DMS und Konvertierung |

## Media / Voice / Smart Home / Web3

| Tools | Hinweis |
|---|---|
| ComfyUI, Stable Diffusion WebUI Forge, Fooocus, InvokeAI | Bild- und Video-Workflows |
| RealESRGAN, GFPGAN, Rembg, RIFE, Blender | Upscaling, Cleanup, 3D und Video |
| Whisper.cpp, faster-whisper, Piper, Coqui TTS, openWakeWord, Rhasspy, Wyoming | STT/TTS/Wakeword |
| Node-RED, Mosquitto, Zigbee2MQTT, ESPHome, Home Assistant | Smart-Home- und IoT-Automation |
| Foundry, Hardhat, Ethers.js, Web3.py | Web3- und Contract-Werkzeuge |
