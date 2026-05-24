# GitHub Tool Sources

Diese Datei dokumentiert die bevorzugten Primaerquellen. Systempakete aus `apt` bleiben fuer Compiler, Libraries, Python-venv, Git, curl, Docker-Basis oder vergleichbare Build-Abhaengigkeiten erlaubt.

## Grundregel

- Primaerquelle fuer Tools: GitHub-Repository oder offizielles GitHub-Release.
- `apt` ist Basisversorgung, nicht bevorzugter App-Kanal.
- Docker-Images duerfen nur genutzt werden, wenn Source-Repository, Compose-Datei und Security-Hinweise dokumentiert sind.
- Installer muessen vor grossen Downloads Speicherplatz, RAM, OS/WSL und vorhandene Versionen anzeigen.

## Empfohlene Quellen

| Tool | GitHub / Quelle | Status | Hinweise |
|---|---|---|---|
| Ollama | `github.com/ollama/ollama` | empfohlen | Lokale Modelle bevorzugen. |
| Open WebUI | `github.com/open-webui/open-webui` | empfohlen | Nur localhost/Tailnet. |
| LiteLLM | `github.com/BerriAI/litellm` | empfohlen | Kosten-/Routing-Logging aktivieren. |
| LangGraph | `github.com/langchain-ai/langgraph` | empfohlen | Python-venv, agentische Workflows. |
| CrewAI | `github.com/crewAIInc/crewAI` | optional | Agenten-Framework, Ressourcen beachten. |
| AutoGen | `github.com/microsoft/autogen` | optional | Experimentelle Agenten-Workflows. |
| Aider | `github.com/Aider-AI/aider` | empfohlen | Coding-Agent, API-Kostenwarnung. |
| OpenHands | `github.com/All-Hands-AI/OpenHands` | optional/schwer | Ressourcen- und Container-Hinweis. |
| Continue.dev | `github.com/continuedev/continue` | empfohlen | IDE-Ergaenzung, nicht als Daemon erzwingen. |
| Qdrant | `github.com/qdrant/qdrant` | empfohlen | Lokale Vektor-DB, Ports schuetzen. |
| ChromaDB | `github.com/chroma-core/chroma` | empfohlen | Leichte lokale RAG-DB. |
| LlamaIndex | `github.com/run-llama/llama_index` | empfohlen | RAG-Pipelines. |
| Haystack | `github.com/deepset-ai/haystack` | optional | Advanced-RAG. |
| Docling | `github.com/docling-project/docling` | empfohlen | Dokumentenextraktion. |
| Paperless-ngx | `github.com/paperless-ngx/paperless-ngx` | optional/schwer | Dokumentenarchiv, meist service-lastig. |
| Stirling PDF | `github.com/Stirling-Tools/Stirling-PDF` | empfohlen | Lokale PDF-Werkzeuge. |
| n8n | `github.com/n8n-io/n8n` | empfohlen | Build aus Source ist speicherintensiv. |
| Activepieces | `github.com/activepieces/activepieces` | optional | Upstream nutzt Bun; kein pnpm erzwingen. |
| Airbyte | `github.com/airbytehq/airbyte`, `github.com/airbytehq/abctl` | optional/schwer | Aktueller lokaler Installationspfad laeuft ueber `abctl local install`; alter Docker-Compose-Pfad mit `airbyte/webapp:latest` ist nicht mehr geeignet. |
| Node-RED | `github.com/node-red/node-red` | empfohlen | Lokale Automation. |
| ComfyUI | `github.com/comfyanonymous/ComfyUI` | empfohlen/GPU | Modellcache gross. |
| Blender | `github.com/blender/blender` | empfohlen | Build sehr schwer; Binary/apt nur bewusst dokumentieren. |
| FFmpeg | `github.com/FFmpeg/FFmpeg` | empfohlen | Build aus Source optional; apt als Systemtool ok. |
| Whisper.cpp | `github.com/ggerganov/whisper.cpp` | empfohlen | Lokale STT. |
| Piper | `github.com/rhasspy/piper` | empfohlen | Lokale TTS. |
| Trivy | `github.com/aquasecurity/trivy` | empfohlen | Security-Scan. |
| Gitleaks | `github.com/gitleaks/gitleaks` | empfohlen | Secret-Scan. |
| Semgrep | `github.com/semgrep/semgrep` | empfohlen | Codeanalyse. |
| Syft | `github.com/anchore/syft` | empfohlen | SBOM. |
| Grype | `github.com/anchore/grype` | empfohlen | Vulnerability-Scan. |
| Uptime Kuma | `github.com/louislam/uptime-kuma` | empfohlen | Monitoring-UI absichern. |
| Netdata | `github.com/netdata/netdata` | empfohlen | Lokales Monitoring. |
| Tailscale | `github.com/tailscale/tailscale` | empfohlen | Sicherer Remote-Zugriff. |
| cloudflared | `github.com/cloudflare/cloudflared` | empfohlen | Nur mit Access/Auth. |
| Headscale | `github.com/juanfont/headscale` | advanced | Self-hosted Controlplane. |
| Rclone | `github.com/rclone/rclone` | empfohlen | Sync/Backup, Secrets schuetzen. |
| Syncthing | `github.com/syncthing/syncthing` | empfohlen | Lokaler Sync. |
| Restic | `github.com/restic/restic` | empfohlen | Backup. |
| MinIO | `github.com/minio/minio` | optional | S3-kompatibler Storage. |

## Nicht automatisch als stabil markieren

- Tools ohne getesteten Installer, Healthcheck und Uninstaller.
- Tools mit offensiver Security-Automation.
- Tools mit unklarer Lizenzlage.
- Tools, die Admin-Ports oeffnen oder Cloudkosten erzeugen, ohne ausdrueckliche Konfiguration.
