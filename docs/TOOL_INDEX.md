# Tool Index

**[Unified Memory, VRAM und Offloading](memory/UNIFIED_MEMORY_AND_OFFLOADING.md)**:
NVIDIA/AMD/Apple sauber unterscheiden, Offline-Speicherrechner sowie optionale
GitHub-Quellinstaller fuer HF_Accelerate und DeepSpeed. Kein Docker/Treiberumbau.

**[REA: eigene lokale App statt Abo](tools/rea.md)**:
gepinnt aus GitHub ohne Docker, Source-Build nur mit Opt-in und keine
automatische MCP-Einrichtung. [Tutorial mit Analyse-/Bau-Prompts](tutorials/own-app-with-rea.md).

**[Find_Skills: Skill-Suche fuer Claude Code und Qwen Code](tools/find-skills.md)**:
gepinnt aus GitHub ohne Docker/npm-Build, Zustimmung vor Aktivierung,
Doctor und Deinstallation. Drei Promptvorlagen und Windows-Anleitung.

**[Alle API-Schluessel](_API-Keys/README.md)** und
**[OnlineOnKeyServices](_API-Keys/OnlineOnKeyServices/README.md): externe API-Dienste ohne Setup-Installation.**
[token8341 / TokenWorks](_API-Keys/OnlineOnKeyServices/token8341.md) und
[OpenRouter](_API-Keys/OnlineOnKeyServices/openrouter.md): ein API-Schluessel fuer mehrere
Modelle; Konfiguration, Kosten und Datenschutzgrenzen. Kein Installer und kein
automatisch aktivierter Cloud-Fallback.

**[Qwen_Desktop fuer Windows](tools/qwen-desktop-windows.md)**:
offizielle Qwen-Code-GUI, getrennt von Qwen_Code CLI und Qwen Chat/Studio.
Manueller Installationspfad, lokaler PowerShell-Pruefhelfer, keine WSL-Pflicht.

[Hybrider Modell-/Medienpfad](media_studio/HYBRID_MODELS_AND_WAN.md):
Cline, Wan21, ComfyUI_GGUF, WanVideoWrapper, SUPIR und FILM planned.
[Qwen_Code CLI](tools/qwen-code.md) hat einen optionalen GitHub-Source-Build
ohne Docker; kein automatischer Agentenstart oder Login.

[Audio-Review und Redaktion](media_studio/AUDIO_DEEPFAKE_REVIEW.md):
pyannote_audio, deepfilternet, audioseal planned; getrennte Aufgaben,
kein universeller Deepfake-Detektor.

[Social-Avatar-Stack](media_studio/SOCIAL_AVATAR_AUTOMATION.md): CogVideoX,
LTX_Video, TGI, Pinokio, SD_Next, Windmill sowie optionale Fal_Client/Veo_API
als planned registriert. Bestehende Bausteine nicht dupliziert.

[HF_Datasets, HF_Hub und Video2Dataset](media_studio/VIDEO_TRAINING_DATASETS.md):
planned, Quellen/Datensaetze/Streaminggrenzen und private Cacheplanung.

[Audio-/Video-Erweiterung](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md):
20 neue planned-Kandidaten und die eigene experimentelle Offline-CLI
[Karaoke_Formats](media_studio/KARAOKE_SUBTITLES_GUIDE.md).

Die technische Quelle ist `config/tools.yml`. Diese Seite fasst die wichtigsten Tool-Familien zusammen.

[Agentic Coding: Clients, Frameworks und Automaton richtig einordnen](tools/agentic-coding.md).

Primaerquellen und GitHub-Referenzen sind gesammelt in `docs/GITHUB_TOOL_SOURCES.md`. `apt` bleibt fuer Basis-/Build-Abhaengigkeiten erlaubt, aber Tools sollen nach Moeglichkeit aus GitHub-Quellen oder offiziellen GitHub-Releases nachvollziehbar sein.

## Runtime und Gateway

- [Automaton: Conway-Agenten, Wallet-Risiken und Zenbot-Integrationsplan](tools/automaton.md) (`planned`, keine Runtime-Installation)

Embedded/IoT: [Embedded Debug HIL: GDB, OpenOCD, pyOCD und Agenten](tools/embedded-debug-hil.md).

- [FreeLLMAPI: optionaler Router und Claude-Code-Tutorial](tools/freellmapi.md)

- `ollama`
- `openclaw`
- `litellm`
- `open_webui`

## RAG und Dokumente

- [Lokale Personalakten: Paperless + Personnel_Documents_AI](tools/personnel-documents.md), ohne globale RAG-Freigabe

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
- `websitefactory` - optionaler Website-/Landingpage-Workflow mit Ollama-Default, siehe [WebsiteFactory](tools/websitefactory.md)

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
| AutoGPT | `github.com/significant-gravitas/autogpt` | Agentenplattform; schwere Docker-Compose-Builds | experimental/heavy, siehe [AutoGPT Build Troubleshooting](AUTOGPT_BUILD_TROUBLESHOOTING.md) |

Neue Tools werden nur dann als installierbar markiert, wenn Installer, Healthcheck und sichere Defaults vorhanden sind.
