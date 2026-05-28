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
