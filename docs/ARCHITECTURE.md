# Architecture

Zielbild:

```text
Base System -> Runtime -> Model Gateway -> Agent Layer -> Memory/RAG -> Tool Layer -> UI -> Monitoring -> Security
```

## Komponenten

- Base System: Ubuntu/WSL2/VPS, Shell, Git, Logs
- Runtime: Node, Python, Go, Docker/Podman optional
- Model Gateway: Ollama, LiteLLM optional, LocalAI optional
- Agent Layer: OpenClaw, Aider/OpenCode optional, LangGraph/CrewAI/AutoGen planned
- Memory/RAG: Qdrant, Chroma, Postgres/pgvector, Open WebUI Knowledge
- Tool Layer: n8n, Huginn, Node-RED, scripts/tools
- UI: Open WebUI, Dashboards, optional Developer Portal
- Monitoring: Uptime Kuma, Prometheus, Grafana, Loki, Netdata
- Security: Gitleaks, Trivy, UFW, Fail2ban, Tailscale/Cloudflare Access

## Prinzipien

- local-first
- read-only by default
- heavy tools opt-in
- secrets outside repo
- rollback before automation
