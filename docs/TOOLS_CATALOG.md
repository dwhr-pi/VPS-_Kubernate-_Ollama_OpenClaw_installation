# Tools Catalog

Dieser Katalog bewertet Tools fuer das Ultimate KI Setup. Statuswerte: `Pflicht`, `Optional`, `Experimentell`.

## KI / LLM

| Tool | Kurzbeschreibung | Nutzen | Installationsart | Bedarf | Risiko | Empfehlung |
|---|---|---|---|---|---|---|
| Ollama | lokaler Modellserver | lokaler Standard | binary/script | mittel | niedrig | Pflicht |
| Open WebUI | lokale Chat-/RAG-UI | Modellzugriff | docker/venv | mittel | mittel | Optional |
| LiteLLM | Gateway/Routing | APIs, Fallbacks, Kosten | venv/docker | mittel | mittel | Optional |
| LocalAI | OpenAI-kompatibel lokal | Alternative zu Ollama | binary/docker | mittel | mittel | Optional |
| llama.cpp | lokale Inferenz | kleine Modelle/CPU | source/binary | mittel | niedrig | Optional |
| vLLM | schneller GPU-Server | Server/GPU | venv/docker | hoch | hoch | Experimentell |
| AnythingLLM | lokale Knowledge UI | RAG/Docs | docker/source | mittel | mittel | Optional |
| Langfuse | LLM Observability | Traces/Kosten | docker | mittel | mittel | Optional |
| Phoenix/Arize | Evaluation/Tracing | LLMOps | venv/docker | mittel | mittel | Optional |
| RAGFlow | RAG Plattform | Dokumenten-RAG | docker | hoch | mittel | Experimentell |
| Haystack | RAG Framework | Pipelines | venv | mittel | niedrig | Optional |
| LlamaIndex | RAG Framework | Indexing | venv | mittel | niedrig | Optional |
| LangChain | Agent/RAG Framework | Integration | venv | mittel | mittel | Optional |

## Agenten / Automation

| Tool | Nutzen | Empfehlung |
|---|---|---|
| OpenClaw | lokale Agenten-Zentrale | Pflicht |
| n8n | Workflows | Optional |
| Flowise | visuelle LLM-Flows | Optional |
| Dify | App-/Agent-Plattform | Experimentell |
| CrewAI | Multi-Agenten | Optional |
| AutoGen | Multi-Agenten | Optional |
| SuperAGI | Agent-Plattform | Experimentell |
| OpenHands | Coding-Agent | Experimentell/heavy |
| Composio | Tool-Connectoren | Optional, externe Dienste beachten |

## Suche / Crawling / RAG

| Tool | Nutzen | Empfehlung |
|---|---|---|
| Firecrawl | Crawling/API | Optional |
| SearXNG | Meta-Suche | Optional |
| Meilisearch | lokale Suche | Optional |
| Qdrant | Vektordatenbank | Optional |
| ChromaDB | Vektorstore | Optional |
| Weaviate | Vektordatenbank | Optional/heavy |
| PostgreSQL + pgvector | RAG/SQL | Optional |

## Sprache / Audio / Musik

| Tool | Nutzen | Empfehlung |
|---|---|---|
| Whisper/faster-whisper | Transkription | Optional |
| Piper TTS | lokale TTS | Optional |
| Coqui TTS | TTS/Voice Experimente | Experimentell |
| MusicGen/AudioCraft | Musik lokal | Experimentell |
| Demucs | Stem Separation | Optional |
| RVC | Voice Conversion | Experimentell, Consent erforderlich |

## Bild / Video

| Tool | Nutzen | Empfehlung |
|---|---|---|
| ComfyUI | Node-basierte Generierung | Optional/GPU |
| Stable Diffusion WebUI Forge | Bildgenerierung | Optional/GPU |
| InvokeAI/Fooocus | Bild-UIs | Optional/GPU |
| OpenPose/ControlNet | Steuerung | Optional/GPU |
| Blender | 3D/Video | Optional/heavy |
| FFmpeg | Medienverarbeitung | Pflicht fuer Medienprofile |

## DevOps / Hosting

| Tool | Nutzen | Empfehlung |
|---|---|---|
| Kubernetes/k3s/Helm | Cluster | Experimentell/VPS |
| Traefik/Nginx Proxy Manager/Caddy | Reverse Proxy | Optional |
| Cloudflare Tunnel | sicherer Webzugriff | Optional |
| Tailscale/Headscale | privater Adminzugriff | Optional |
| Uptime Kuma/Grafana/Prometheus/Loki/Netdata | Monitoring | Optional |

## Sicherheit

| Tool | Nutzen | Empfehlung |
|---|---|---|
| Vaultwarden/Infisical | Secrets/Passwoerter | Optional |
| SOPS/Age | verschluesselte Config | Optional |
| Fail2ban/CrowdSec | Hostschutz | Optional |
| Trivy/Grype/Gitleaks/Semgrep | Scans | Optional |
| Pi-hole/AdGuard Home | DNS-Schutz | Optional |
## Next Improvements Tool-Kandidaten 2026

| Tool | GitHub-URL | Zweck | Profil | Installationsstatus | Ressourcenklasse | Risiko | Ports? | Secrets? | Doctor-Check | Uninstaller |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Stalwart | https://github.com/stalwartlabs/stalwart | Mailserver-Kern | Mail_AI_Operations | documentation-first | server | high | ja | ja | geplant | geplant |
| SOPS | https://github.com/getsops/sops | Secrets verschluesseln | Secrets_Vault_Local_First | planned | low | medium | nein | ja | geplant | geplant |
| age | https://github.com/FiloSottile/age | Key-Verschluesselung | Secrets_Vault_Local_First | planned | low | medium | nein | ja | geplant | geplant |
| OpenBao | https://github.com/openbao/openbao | Vault/Secrets | Secrets_Vault_Local_First | planned | server | high | ja | ja | geplant | geplant |
| Infisical | https://github.com/Infisical/infisical | Secrets Plattform | Secrets_Vault_Local_First | planned | server | high | ja | ja | geplant | geplant |
| restic | https://github.com/restic/restic | Backup | Backup_Disaster_Recovery | planned | low | medium | nein | ja | geplant | vorhanden/teilweise |
| BorgBackup | https://github.com/borgbackup/borg | Backup | Backup_Disaster_Recovery | planned | low | medium | nein | ja | geplant | vorhanden/teilweise |
| rclone | https://github.com/rclone/rclone | Remote Sync | Backup_Disaster_Recovery | planned | low | medium | optional | ja | geplant | vorhanden/teilweise |
| Grafana | https://github.com/grafana/grafana | Dashboard | Observability_AI_Control_Tower | planned | medium | medium | ja | optional | geplant | vorhanden/teilweise |
| Prometheus | https://github.com/prometheus/prometheus | Metriken | Observability_AI_Control_Tower | planned | medium | medium | ja | nein | geplant | vorhanden/teilweise |
| Loki | https://github.com/grafana/loki | Logs | Observability_AI_Control_Tower | planned | medium | medium | ja | nein | geplant | vorhanden/teilweise |
| cAdvisor | https://github.com/google/cadvisor | Container-Metriken | Observability_AI_Control_Tower | planned | medium | medium | ja | nein | geplant | geplant |
| Netdata | https://github.com/netdata/netdata | Low-Resource Monitoring | Observability_AI_Control_Tower | optional | low | medium | ja | optional | geplant | vorhanden/teilweise |
| Glances | https://github.com/nicolargo/glances | Low-Resource Monitoring | Observability_AI_Control_Tower | optional | low | low | optional | nein | geplant | geplant |
| CrowdSec | https://github.com/crowdsecurity/crowdsec | Angriffsabwehr | Network_DNS_DDoS_Hardening | planned | medium | medium | optional | optional | geplant | vorhanden/teilweise |
| Fail2ban | https://github.com/fail2ban/fail2ban | Brute-Force-Schutz | Network_DNS_DDoS_Hardening | planned | low | medium | nein | nein | geplant | vorhanden/teilweise |
| Caddy | https://github.com/caddyserver/caddy | Reverse Proxy | Network_DNS_DDoS_Hardening | planned | low | medium | ja | optional | geplant | vorhanden/teilweise |
| Traefik | https://github.com/traefik/traefik | Reverse Proxy | Network_DNS_DDoS_Hardening | planned | medium | medium | ja | optional | geplant | vorhanden/teilweise |
| Pi-hole | https://github.com/pi-hole/pi-hole | DNS-Blocking | Network_DNS_DDoS_Hardening | optional | medium | medium | ja | nein | geplant | vorhanden/teilweise |
| AdGuard Home | https://github.com/AdguardTeam/AdGuardHome | DNS-Blocking | Network_DNS_DDoS_Hardening | optional | medium | medium | ja | nein | geplant | vorhanden/teilweise |
| Blocky | https://github.com/0xERR0R/blocky | DNS-Proxy/Blocker | Network_DNS_DDoS_Hardening | planned | low | medium | ja | nein | geplant | geplant |
| Stirling PDF | https://github.com/stirling-tools/Stirling-PDF | PDF Werkzeuge | RAG_Document_Intelligence | planned | medium | medium | ja | optional | geplant | vorhanden/teilweise |
| Docling | https://github.com/docling-project/docling | Dokumenten-KI | RAG_Document_Intelligence | planned | medium | medium | nein | nein | geplant | vorhanden/teilweise |
| Unstructured | https://github.com/Unstructured-IO/unstructured | Dokumentenparser | RAG_Document_Intelligence | planned | medium | medium | nein | nein | geplant | vorhanden/teilweise |
| Apache Tika | https://github.com/apache/tika | Dokumentenparser | RAG_Document_Intelligence | planned | medium | medium | ja | nein | geplant | vorhanden/teilweise |
| Paperless-ngx | https://github.com/paperless-ngx/paperless-ngx | Dokumentenarchiv | RAG_Document_Intelligence | planned | medium | medium | ja | ja | geplant | vorhanden/teilweise |
| Meilisearch | https://github.com/meilisearch/meilisearch | Suche | RAG_Document_Intelligence | planned | medium | medium | ja | optional | geplant | vorhanden/teilweise |
| Open WebUI | https://github.com/open-webui/open-webui | LLM UI | Model_Router_Cost_Control | planned | medium | medium | ja | optional | geplant | vorhanden/teilweise |
| LiteLLM | https://github.com/BerriAI/litellm | Model Gateway | Model_Router_Cost_Control | planned | medium | medium | ja | ja | geplant | vorhanden/teilweise |
| Ollama | https://github.com/ollama/ollama | Lokale Modelle | Model_Router_Cost_Control | tested/optional | medium | medium | ja | nein | vorhanden | vorhanden/teilweise |
| llama.cpp | https://github.com/ggerganov/llama.cpp | Lokale Inferenz | Model_Router_Cost_Control | planned | medium | medium | optional | nein | geplant | geplant |
| vLLM | https://github.com/vllm-project/vllm | GPU Inferenz | Model_Router_Cost_Control | planned | gpu/server | high | ja | optional | geplant | geplant |
| LocalAI | https://github.com/mudler/LocalAI | Lokale API | Model_Router_Cost_Control | planned | medium | medium | ja | optional | geplant | geplant |
| MCP filesystem | https://github.com/modelcontextprotocol/server-filesystem | Datei-MCP | MCP_Server_Gateway | documentation-first | low | medium | nein | optional | geplant | geplant |
| MCP git | https://github.com/modelcontextprotocol/server-git | Git-MCP | MCP_Server_Gateway | documentation-first | low | medium | nein | optional | geplant | geplant |
| MCP sqlite | https://github.com/modelcontextprotocol/server-sqlite | SQLite-MCP | MCP_Server_Gateway | documentation-first | low | medium | nein | optional | geplant | geplant |
| MCP postgres | https://github.com/modelcontextprotocol/server-postgres | Postgres-MCP | MCP_Server_Gateway | documentation-first | low | medium | ja | ja | geplant | geplant |
| Browser MCP | https://github.com/browsermcp/mcp | Browser-MCP | MCP_Server_Gateway | documentation-first | medium | medium | optional | optional | geplant | geplant |
| Docker MCP Registry | https://github.com/docker/mcp-registry | MCP Registry | MCP_Server_Gateway | documentation-first | medium | high | optional | optional | geplant | geplant |
| Redis | https://github.com/redis/redis | Queue/Cache | Queue_Worker_Orchestrator | planned | low | medium | ja | optional | geplant | vorhanden/teilweise |
| RabbitMQ | https://github.com/rabbitmq/rabbitmq-server | Queue Broker | Queue_Worker_Orchestrator | planned | medium | medium | ja | optional | geplant | geplant |
| Celery | https://github.com/celery/celery | Python Queue | Queue_Worker_Orchestrator | planned | medium | medium | nein | optional | geplant | vorhanden/teilweise |
| RQ | https://github.com/rq/rq | Redis Queue | Queue_Worker_Orchestrator | planned | low | medium | nein | optional | geplant | vorhanden/teilweise |
| BullMQ | https://github.com/taskforcesh/bullmq | Node Queue | Queue_Worker_Orchestrator | planned | medium | medium | nein | optional | geplant | vorhanden/teilweise |
