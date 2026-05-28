# Tool Index

Die technische Quelle ist `config/tools.yml`. Diese Seite fasst die wichtigsten Tool-Familien zusammen.

Primaerquellen und GitHub-Referenzen sind gesammelt in `docs/GITHUB_TOOL_SOURCES.md`. `apt` bleibt fuer Basis-/Build-Abhaengigkeiten erlaubt, aber Tools sollen nach Moeglichkeit aus GitHub-Quellen oder offiziellen GitHub-Releases nachvollziehbar sein.

## Runtime und Gateway

- `ollama`
- `openclaw`
- `litellm`
- `open_webui`

## RAG und Dokumente

- `qdrant`
- `chromadb`
- `lightrag`
- `docling`
- `apache_tika`
- `paperless_ngx`
- `meilisearch`

## LLMOps und Evaluation

- `langfuse`
- `openlit`
- `promptfoo`

## Automation und Apps

- `n8n`
- `activepieces`
- `node_red`
- `flowise`
- `langflow`
- `appsmith`
- `budibase`
- `nocodb`
- `ai_content_multiplier` - optionaler OpenClaw/n8n Workflow, siehe [AI-ContentMultiplier](tools/ai-content-multiplier/README.md)

## Mail und Domains

- `stalwart_mail` - optionaler selbst gehosteter Mailserver-Kern mit KI-faehiger Integrationsschicht, siehe [Stalwart Mail](../tools/mail/README.md)

## Security

- `trivy`
- `gitleaks`
- `semgrep`
- `syft`
- `grype`
- `ufw`
- `crowdsec`
- `fail2ban`
- `clamav`
- `yara`

## Monitoring und Betrieb

- `prometheus`
- `grafana`
- `loki`
- `uptime_kuma`
- `healthchecks`
- `netdata`

## Media und GPU

- `comfyui`
- `stable_diffusion_webui_forge`
- `blender`
- `realesrgan`
- `rembg`
- `whisper_cpp`
- `faster_whisper`
- `piper`
- `coqui_tts`
# Tool-Kandidaten fuer planned Profile ab 11.17

| Tool | GitHub/Quelle | Zweck | Bewertung |
|---|---|---|---|
| promptfoo | `github.com/promptfoo/promptfoo` | Prompt-Regressionen und LLM-Tests | empfohlen |
| Aider | `github.com/Aider-AI/aider` | Coding-Agent im Terminal | empfohlen |
| OpenHands | `github.com/All-Hands-AI/OpenHands` | Coding-Agent-Plattform | optional, schwerer Stack |
| Continue.dev | `github.com/continuedev/continue` | IDE-KI-Ergaenzung | optional |
| LlamaIndex | `github.com/run-llama/llama_index` | RAG-Framework | empfohlen |
| Haystack | `github.com/deepset-ai/haystack` | RAG-/Search-Pipelines | optional |
| Qdrant | `github.com/qdrant/qdrant` | Vektordatenbank | empfohlen |
| Paperless-ngx | `github.com/paperless-ngx/paperless-ngx` | Dokumentenarchiv | empfohlen, Docker-lastig |
| Stirling PDF | `github.com/Stirling-Tools/Stirling-PDF` | lokale PDF-Werkzeuge | empfohlen |
| Syncthing | `github.com/syncthing/syncthing` | Dateisynchronisation | empfohlen |
| Rclone | `github.com/rclone/rclone` | Cloud-/WebDAV-Sync | empfohlen |
| Nextcloud | `github.com/nextcloud/server` | Self-hosted Cloud | optional, schwer |
| Uptime Kuma | `github.com/louislam/uptime-kuma` | Uptime-Monitoring | empfohlen |
| Netdata | `github.com/netdata/netdata` | Systemmonitoring | empfohlen |
| Headscale | `github.com/juanfont/headscale` | Self-hosted Tailscale-Controlplane | optional |
| AdGuard Home | `github.com/AdguardTeam/AdGuardHome` | DNS-Schutz | optional |
| OpenTelemetry Collector | `github.com/open-telemetry/opentelemetry-collector` | Observability-Pipeline | optional |
| AI-ContentMultiplier | `C:\Users\danie\Documents\GitHub\content-multiplier` | URL/PDF/Web/YouTube/LinkedIn zu Content-Entwuerfen via OpenClaw/n8n | optional, workflow-first |
| Stalwart Mail | `github.com/stalwartlabs/stalwart` | Selbst gehosteter Mailserver fuer eigene Domains mit OpenClaw/Ollama-Admin-Agent | optional, sicherheitskritisch |

Neue Tools werden nur dann als installierbar markiert, wenn Installer, Healthcheck und sichere Defaults vorhanden sind.
