# GitHub Tool Sources

Qwen_Desktop und Qwen_Code: [offizieller Code](https://github.com/QwenLM/qwen-code),
[Desktop-Releases](https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest).
[Windows-Einstieg](tools/qwen-desktop-windows.md), kein Community-Web-Wrapper.
[Cline/Wan/GGUF/Wrapper/SUPIR/FILM-Quellen](media_studio/HYBRID_MODELS_AND_WAN.md).

Defensiver Audio-Pfad: [pyannote/pyannote-audio](https://github.com/pyannote/pyannote-audio),
[Rikorose/DeepFilterNet](https://github.com/Rikorose/DeepFilterNet),
[facebookresearch/audioseal](https://github.com/facebookresearch/audioseal), alle planned.
[Fachliche Grenzen und bestehende Tools](media_studio/AUDIO_DEEPFAKE_REVIEW.md);
Demucs-Meta-Repo archiviert, keine automatische Fork-Migration.

[Social-Avatar-Quellen](media_studio/SOCIAL_AVATAR_AUTOMATION.md): CogVideoX,
LTX-Video, SD.Next, Pinokio, Windmill, TGI, fal-SDK und Google-GenAI-SDK.
SDK auf GitHub bedeutet nicht, dass Veo/fal lokal selbsthostbar sind.

Dataset-Werkzeuge, nur planned:
[huggingface/datasets](https://github.com/huggingface/datasets),
[huggingface/huggingface_hub](https://github.com/huggingface/huggingface_hub),
[iejMac/video2dataset](https://github.com/iejMac/video2dataset).
[Quellen-/Rechte-/Budgetleitfaden](media_studio/VIDEO_TRAINING_DATASETS.md).

[Audio-/Video-Quellen](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md):
20 Kandidaten mit direkten Upstream-Links, alle planned/documentation-first.
Karaoke_Formats ist eigene Repository-Logik, keine fremde Paketinstallation.

Diese Datei dokumentiert die bevorzugten Primaerquellen. Systempakete aus `apt` bleiben fuer Compiler, Libraries, Python-venv, Git, curl, Docker-Basis oder vergleichbare Build-Abhaengigkeiten erlaubt.

## Grundregel

Agentic-Coding-Quellen und konkrete Installationsgrenzen:
[Tool-Leitfaden](tools/agentic-coding.md). Aider, Continue, OpenHands, LangGraph,
CrewAI und AutoGen behalten ihre vorhandenen Installer. OpenCode wird unter
der aktuellen Quelle [anomalyco/opencode](https://github.com/anomalyco/opencode)
gefuehrt, bleibt aber planned; kein automatisches Aktivieren des alten Scaffolds.
[microsoft/agent-framework](https://github.com/microsoft/agent-framework) ist neu
als planned/MIT registriert, ohne Download oder Provideraktivierung.

Personalakten-Workflow: [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx)
(GPL-3.0), [ollama/ollama](https://github.com/ollama/ollama),
[tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract).
`Personnel_Documents_AI` ist eigener Integrationscode, kein fingiertes Upstream-Projekt.
Der neue Paperless-Installer verwendet offizielle GHCR-Images mit expliziter Version,
keinen apt-App-Download; keine automatische Docker-Engine-/Modellinstallation.
Siehe [Tutorial](tools/personnel-documents.md).

Automaton: [Conway-Research/automaton](https://github.com/Conway-Research/automaton), MIT,
gepruefter Commit `d8f816881fd24b6f5e3d616e59edec387a447667`.
Nur documentation-first registriert; die Installationsskripte sperren Runtime-Aktionen.
Kein apt-/npm-/Docker-Download. Spaeterer Source-Build gesondert zu auditieren.
Siehe [Automaton und Zenbot](tools/automaton.md).

Embedded Debug HIL nutzt eigene Offline-Integrationsdateien. Fuer spaetere
Debugger-Installationen sind [OpenOCD (offizieller Read-only-Mirror)](https://github.com/openocd-org/openocd),
[pyOCD](https://github.com/pyocd/pyOCD) und [pygdbmi](https://github.com/cs01/pygdbmi)
die Kandidaten. Kein Clone/Build/Paketdownload erfolgt automatisch. Architektur,
Commit-/Release-Pin, Lizenz und Hardwaretest bleiben vor Freigabe zu pruefen.
Siehe [HIL-Anleitung](tools/embedded-debug-hil.md).

FreeLLMAPI: [tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi), MIT.
Der optionale Installer klont Tag `v0.14.2` und prueft Commit
`57c0669233bbe0c70a0f9f9927613192be948773`; npm ci/build statt Container.
Keine Engine, apt-App oder `curl|bash`; echte Plattform-/Provider-Tests bleiben TODO.
Siehe [Tutorial und Sicherheitsgrenzen](tools/freellmapi.md).

- Primaerquelle fuer Tools: GitHub-Repository oder offizielles GitHub-Release.
- `apt` ist Basisversorgung, nicht bevorzugter App-Kanal.
- Docker-Images duerfen nur genutzt werden, wenn Source-Repository, Compose-Datei und Security-Hinweise dokumentiert sind.
- Installer muessen vor grossen Downloads Speicherplatz, RAM, OS/WSL und vorhandene Versionen anzeigen.

## Wo ist notiert, wenn ein Tool nicht direkt nur ueber GitHub installiert wird?

Die Information steht an mehreren Stellen, weil Policy, Registry und echte Installationslogik unterschiedliche Aufgaben haben:

| Ort | Bedeutung |
|---|---|
| `docs/GITHUB_TOOL_SOURCES.md` | Zentrale Policy und bekannte Ausnahmen fuer Primaerquellen. |
| `config/tools.yml` | Maschinenlesbare Tool-Registry fuer Menues, Checks und Installer-Zuordnung. |
| `scripts/tools/<tool>_install.sh` | Verbindliche technische Wahrheit, welche Quellen der Installer wirklich nutzt. |
| `bash scripts/check_tools.sh --strict-sources` | Zeigt Tools ohne maschinenlesbare Primaerquellen-Zuordnung. |
| `docs/CUSTOM_SOURCES_AND_BUILDS.md` | Dokumentiert lokale Overrides, eigene Forks und bewusst abweichende Quellen. |

Wichtig: Ein Tool kann trotzdem GitHub als Primaerquelle haben, aber beim Build indirekt weitere Quellen nutzen. Das ist besonders bei Docker-Compose-, Container- und Sprach-Toolchain-Projekten normal. Solche Faelle muessen im Installer klar angesagt werden.

## Bekannte indirekte oder nicht rein direkte GitHub-Pfade

| Tool / Bereich | Primaerquelle | Indirekte Quellen | Einordnung |
|---|---|---|---|
| AutoGPT | `github.com/significant-gravitas/autogpt` oder konfigurierter Fork | Upstream-Docker-Build zieht Docker-Basisimages, Container-Pakete und Debian/Alpine-Abhaengigkeiten. BuildKit ist erforderlich. | GitHub-basiert, aber nicht rein direkter GitHub-Build. |
| Airbyte | `github.com/airbytehq/airbyte` und `github.com/airbytehq/abctl` | `abctl local install` erstellt einen eigenen lokalen `kind`/Kubernetes-Cluster und laedt viele Container-Images nach. Details: [AIRBYTE_ABCTL_KUBERNETES_NOTES.md](AIRBYTE_ABCTL_KUBERNETES_NOTES.md). | GitHub-basiert, aber Container-orchestriert und sehr speicherintensiv. |
| Apache Tika | `github.com/apache/tika` | Je nach Installer kann der Betrieb ueber Docker/Java-Artefakte laufen. | GitHub-basiert mit Laufzeit-Abhaengigkeiten. |
| Blender | `github.com/blender/blender` | Der Installer klont Blender aus GitHub und baut lokal. Blender-Upstream kann beim `make update` zusaetzliche Build-Abhaengigkeiten nachladen. | GitHub-Source-Build, sehr schwer. |
| FFmpeg | `github.com/FFmpeg/FFmpeg` | Der Installer klont FFmpeg aus GitHub und baut lokal nach `/opt/ffmpeg-github`. | GitHub-Source-Build. |
| n8n | `github.com/n8n-io/n8n` | Der aktuelle Installer klont das GitHub-Monorepo und baut mit `pnpm`; npm/pnpm laden dabei Paketmanager-Abhaengigkeiten nach. | Direkter GitHub-Source-Pfad mit Paketmanager-Abhaengigkeiten. |
| AI-ContentMultiplier | `github.com/dwhr-pi/content-multiplier` | Der Installer behandelt das Tool als Workflow-Repository und bereitet nur lokale Konfiguration/Ausgaben vor; Firecrawl und Cloud-Modelle bleiben optionale externe Dienste. | GitHub-basierter Workflow, keine schwere Autoinstallation. |
| Stalwart Mail | `github.com/stalwartlabs/stalwart` | Stalwart bleibt unveraenderter Upstream; dieses Setup liefert nur Doku, Compose-Vorlage und eigene Agent-/Control-Panel-Integrationsschicht. | GitHub-basierter Mailserver-Kern, sicherheitskritischer Betrieb. |
| Docker / Container-Basis | Offizielle Paketquelle oder GitHub-Release, je nach System | Docker Hub/Base-Images, OS-Pakete im Container. | System-/Runtime-Abhaengigkeit, keine App-Quelle. |
| Go, Python, Node, Bun, Java | Offizielle Sprach-/Runtime-Quellen oder Systempakete | Paketmanager-Abhaengigkeiten wie npm, pip, cargo, apt. | Build-Werkzeug, nicht Ziel-App. |
| `apt`-Pakete | Ubuntu/Debian-Repositories | Systembibliotheken, Compiler, `python3-venv`, `git`, `curl`, `build-essential`, `docker.io`. | Erlaubte Basisversorgung. |

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
| AI-ContentMultiplier | `github.com/dwhr-pi/content-multiplier` | optional/workflow | URL/PDF/Web/YouTube/LinkedIn zu Content-Entwuerfen via OpenClaw/n8n; lokal-first mit Ollama. |
| Stalwart Mail | `github.com/stalwartlabs/stalwart` | optional/sicherheitskritisch | Mailserver fuer eigene Domains; DNS, PTR/rDNS, DKIM/SPF/DMARC und Hardening zwingend pruefen. |
| Activepieces | `github.com/activepieces/activepieces` | optional | Upstream nutzt Bun; kein pnpm erzwingen. |
| Airbyte | `github.com/airbytehq/airbyte`, `github.com/airbytehq/abctl` | optional/sehr schwer | Aktueller lokaler Installationspfad laeuft ueber `abctl local install`; alter Docker-Compose-Pfad mit `airbyte/webapp:latest` ist nicht mehr geeignet. `abctl` erzeugt lokal einen eigenen `kind`-Cluster, nicht automatisch den spaeteren Setup-K3s-Cluster. Vor dem Image-Pull sollten unter WSL mindestens ca. 32 GB Linux-/WSL-Speicher und ca. 20 GB Windows-Host-Speicher frei sein, besser deutlich mehr. |
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

## 2026-05-31: Next-Level Tool-Kandidaten

| Tool | GitHub-Quelle | Zweck | Status | Risiko |
| --- | --- | --- | --- | --- |
| PaddleOCR | https://github.com/PaddlePaddle/PaddleOCR | OCR fuer Bilder, Scans und Dokumentenpipelines | planned/manual | medium |
| LiveKit | https://github.com/livekit/livekit | Realtime Audio/Video fuer Voice-Agenten und Callcenter | planned/manual | medium |
| Asterisk | https://github.com/asterisk/asterisk | SIP/Telefonie-Kern fuer IVR und Callcenter | planned/manual | medium |
| Beszel | https://github.com/henrygd/beszel | Leichtes Server-Monitoring | planned/manual | low |
| Zeek | https://github.com/zeek/zeek | Netzwerk-Monitoring und Protokollanalyse | planned/manual | high |
| Falco | https://github.com/falcosecurity/falco | Runtime-Security fuer Container, Linux und Kubernetes | planned/manual | high |
| Stalwart | https://github.com/stalwartlabs/stalwart | Mailserver-Kern fuer eigene Domains | planned/manual | high |
| Sieve | https://github.com/stalwartlabs/stalwart | Mailfilter-Regeln und Agenten-Workflows | planned/manual | medium |

Sicherheitsregel: Diese Tools werden nicht automatisch installiert. Vor produktiver Nutzung muessen Lizenz, Release-Quelle, Ports, Secrets, Ressourcenbedarf und Update-/Rollback-Pfad geprueft werden.

