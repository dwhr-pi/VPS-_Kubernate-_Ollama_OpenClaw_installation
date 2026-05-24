# GitHub Tool Sources

Diese Datei dokumentiert die bevorzugten Primaerquellen. Systempakete aus `apt` bleiben fuer Compiler, Libraries, Python-venv, Git, curl, Docker-Basis oder vergleichbare Build-Abhaengigkeiten erlaubt.

## Grundregel

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
| Airbyte | `github.com/airbytehq/airbyte` und `github.com/airbytehq/abctl` | `abctl local install` nutzt Container/Kubernetes-Komponenten und kann Images nachladen. | GitHub-basiert, aber Container-orchestriert. |
| Apache Tika | `github.com/apache/tika` | Je nach Installer kann der Betrieb ueber Docker/Java-Artefakte laufen. | GitHub-basiert mit Laufzeit-Abhaengigkeiten. |
| Blender | `github.com/blender/blender` | Der Installer klont Blender aus GitHub und baut lokal. Blender-Upstream kann beim `make update` zusaetzliche Build-Abhaengigkeiten nachladen. | GitHub-Source-Build, sehr schwer. |
| FFmpeg | `github.com/FFmpeg/FFmpeg` | Der Installer klont FFmpeg aus GitHub und baut lokal nach `/opt/ffmpeg-github`. | GitHub-Source-Build. |
| n8n | `github.com/n8n-io/n8n` | Der aktuelle Installer klont das GitHub-Monorepo und baut mit `pnpm`; npm/pnpm laden dabei Paketmanager-Abhaengigkeiten nach. | Direkter GitHub-Source-Pfad mit Paketmanager-Abhaengigkeiten. |
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
