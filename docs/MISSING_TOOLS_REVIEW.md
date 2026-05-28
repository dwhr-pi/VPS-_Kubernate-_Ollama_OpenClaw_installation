# Missing Tools Review

Stand: 2026-05-28

## Bereits gut abgedeckt

- LLM Gateway: Ollama, LiteLLM, Open WebUI, llama.cpp, vLLM.
- RAG: Qdrant, ChromaDB, Weaviate, Meilisearch, Apache Tika, Docling, OCRmyPDF, Tesseract.
- Agenten: LangGraph, CrewAI, AutoGen, Flowise, Langflow, n8n, Activepieces, Huginn, Playwright, Browser-use/GBOX-nahe Pfade.
- Monitoring: Grafana, Prometheus, Loki, Uptime Kuma, Netdata, Healthchecks.
- Security: Trivy, Gitleaks, Semgrep, Grype, Syft, Fail2Ban, UFW, CrowdSec, Pi-hole, AdGuard Home.
- Media: ComfyUI, Forge, InvokeAI, Blender, FFmpeg, Whisper.cpp, Piper, Coqui TTS.
- Dev: GitHub CLI, Aider, OpenCode, Continue.dev, pre-commit, shellcheck, shfmt.

## Sinnvoll zu ergaenzen oder nur dokumentieren

| Tool | Statusvorschlag | Grund |
|---|---|---|
| OSV-Scanner | optional | Leichter Dependency-Vulnerability-Check. |
| Lynis | optional | Host-Hardening-Audit fuer VPS/Linux. |
| Glances | optional | Leichtes Systemmonitoring fuer MiniPC/WSL2. |
| Kopia | optional | Moderne Backup-Alternative zu Restic/Borg. |
| LocalAI | optional | OpenAI-kompatibler lokaler Server, aber Ressourcenbedarf pruefen. |
| Cline/Roo Code | documentation-only | IDE-Erweiterungen, nicht serverseitig installieren. |
| Devcontainer-Vorlage | documentation-only | Projektstruktur statt globales Tool. |
| bats-core | optional | Shell-Tests fuer Setup-Skripte. |

## Schwere Tools

Airbyte, AutoGPT, ComfyUI, Stable Diffusion Forge, vLLM, Kubernetes/K3s, Nextcloud und Activepieces bleiben optional/experimental oder GPU-/server-lastig. Sie sollten nie Teil einer automatischen Minimalinstallation sein.
