# Recommended Tools

Alle Eintraege sind `optional` oder `planned`, sofern sie nicht bereits stabil im Setup integriert sind. Keine Installation erfolgt automatisch.

| Kategorie | Tool | GitHub | Nutzen | Installationsart | Risiko | Ressourcen | VPS | Homelab | OpenClaw-Idee | Doctor-Check |
|---|---|---|---|---|---|---|---|---|---|---|
| Coding/Agenten | Aider | https://github.com/Aider-AI/aider | Pair-Programming | venv/pipx | mittel | mittel | ja | ja | Code-Agent mit Git-Gate | `aider --version` |
| Coding/Agenten | OpenCode | https://github.com/sst/opencode | Terminal Coding-Agent | binary/npm | mittel | mittel | ja | ja | lokaler Coding-Agent | Version/Config |
| Coding/Agenten | Continue.dev | https://github.com/continuedev/continue | IDE KI | source/npm | mittel | hoch | nein | ja | IDE-Kontext | Extension-Check |
| Coding/Agenten | OpenHands | https://github.com/All-Hands-AI/OpenHands | Coding-Agent-Plattform | docker/source | hoch | hoch | bedingt | ja | Agent-Sandbox | Containerstatus |
| Coding/Agenten | SWE-agent | https://github.com/SWE-agent/SWE-agent | Repo-Fixing-Agent | venv/source | hoch | hoch | bedingt | ja | controlled repair | Dry-run |
| Workflows | LangGraph | https://github.com/langchain-ai/langgraph | Agent Graphs | venv | mittel | mittel | ja | ja | Tool-Gates | Importtest |
| Workflows | CrewAI | https://github.com/crewAIInc/crewAI | Multi-Agenten | venv | mittel | mittel | ja | ja | Team-Agenten | Importtest |
| Workflows | AutoGen | https://github.com/microsoft/autogen | Multi-Agenten | venv | mittel | mittel | ja | ja | Agenten-Orchestrierung | Importtest |
| Workflows | Flowise | https://github.com/FlowiseAI/Flowise | visuelle LLM-Flows | npm/docker | mittel | mittel | ja | ja | Flow-Designer | Port/Version |
| Workflows | Dify | https://github.com/langgenius/dify | LLM-App-Plattform | docker | hoch | hoch | bedingt | ja | App-Backend | Compose status |
| Workflows | Haystack | https://github.com/deepset-ai/haystack | RAG Pipelines | venv | mittel | mittel | ja | ja | RAG Tools | Importtest |
| RAG/Suche | Qdrant | https://github.com/qdrant/qdrant | Vektordatenbank | binary/docker | mittel | mittel | ja | ja | Knowledge store | Port/collection |
| RAG/Suche | Chroma | https://github.com/chroma-core/chroma | Vektorstore | venv/docker | mittel | mittel | ja | ja | Memory store | Importtest |
| RAG/Suche | Weaviate | https://github.com/weaviate/weaviate | Vektordatenbank | docker | hoch | hoch | bedingt | ja | RAG backend | Port/health |
| RAG/Suche | Meilisearch | https://github.com/meilisearch/meilisearch | Suche | binary/docker | mittel | mittel | ja | ja | lokale Suche | Port/health |
| RAG/Suche | Firecrawl | https://github.com/mendableai/firecrawl | Crawling | docker/source | mittel | mittel | ja | ja | Web ingest | API health |
| Observability | Langfuse | https://github.com/langfuse/langfuse | LLM Tracing | docker | mittel | mittel | ja | ja | Agent traces | Port/health |
| Observability | OpenLIT | https://github.com/openlit/openlit | LLM Observability | venv/docker | mittel | mittel | ja | ja | Telemetry | Import/port |
| Observability | Prometheus | https://github.com/prometheus/prometheus | Metrics | binary/docker | mittel | mittel | ja | ja | Metrics scrape | Port/targets |
| Observability | Grafana | https://github.com/grafana/grafana | Dashboards | apt/docker | mittel | mittel | ja | ja | Dashboards | Port/login |
| Observability | Loki | https://github.com/grafana/loki | Logs | binary/docker | mittel | mittel | ja | ja | Log backend | Port/ready |
| Observability | Uptime Kuma | https://github.com/louislam/uptime-kuma | Statuschecks | docker/npm | niedrig | niedrig | ja | ja | service monitor | Port/health |
| Security/SSO | Authentik | https://github.com/goauthentik/authentik | SSO/OIDC | docker | hoch | hoch | ja | ja | OIDC gateway | Compose/port |
| Security/SSO | Authelia | https://github.com/authelia/authelia | SSO/2FA | binary/docker | mittel | mittel | ja | ja | Reverse proxy auth | Port/config |
| Security/SSO | CrowdSec | https://github.com/crowdsecurity/crowdsec | Hostschutz | apt/docker | mittel | mittel | ja | ja | Security alerts | Service status |
| Security/SSO | Fail2ban | https://github.com/fail2ban/fail2ban | SSH Schutz | apt | niedrig | niedrig | ja | ja | ban reports | Service status |
| Security/SSO | Caddy | https://github.com/caddyserver/caddy | Reverse Proxy | apt/binary | mittel | niedrig | ja | ja | safe proxy | Config validate |
| Security/SSO | Traefik | https://github.com/traefik/traefik | Reverse Proxy | binary/docker | mittel | mittel | ja | ja | ingress/proxy | Config validate |
| Security/SSO | Cloudflare Tunnel | https://github.com/cloudflare/cloudflared | sicherer Tunnel | binary | mittel | niedrig | ja | ja | public access gate | Version/status |
| Security/SSO | Tailscale | https://github.com/tailscale/tailscale | privates Mesh | apt | niedrig | niedrig | ja | ja | admin-only path | `tailscale status` |
| Security/SSO | Headscale | https://github.com/juanfont/headscale | selfhosted control | binary | mittel | mittel | ja | ja | private mesh | Service status |
| Automation | n8n | https://github.com/n8n-io/n8n | Workflows | npm/docker/source | mittel | mittel | ja | ja | workflow executor | Port/health |
| Automation | Node-RED | https://github.com/node-red/node-red | IoT flows | npm/docker | mittel | niedrig | ja | ja | HA/MQTT flows | Port/health |
| Automation | Huginn | https://github.com/huginn/huginn | Agent workflows | docker/source | mittel | mittel | ja | ja | event agents | Port/health |
| Container/K8s | Podman | https://github.com/containers/podman | rootless containers | apt | mittel | mittel | ja | ja | safer container path | `podman info` |
| Container/K8s | K3s | https://github.com/k3s-io/k3s | lightweight K8s | script/binary | hoch | hoch | ja | ja | cluster runtime | node status |
| Container/K8s | Helm | https://github.com/helm/helm | K8s packages | binary | mittel | niedrig | ja | ja | chart deploys | `helm version` |
| Container/K8s | Argo CD | https://github.com/argoproj/argo-cd | GitOps | k8s/helm | hoch | hoch | ja | ja | GitOps deploy | app status |
| Container/K8s | Renovate | https://github.com/renovatebot/renovate | dependency updates | npm/docker | mittel | mittel | ja | ja | PR updates | config check |
