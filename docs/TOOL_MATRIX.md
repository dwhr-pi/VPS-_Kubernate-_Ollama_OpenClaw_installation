# Tool Matrix

Diese Matrix zeigt die derzeit sinnvoll verdrahteten Toolgruppen. Sie ist bewusst kompakter als `scripts/tools/` und unterscheidet zwischen `Core`, `Optional`, `Experimental` und `High-Risk`.

Die bevorzugten Primaerquellen sind in `docs/GITHUB_TOOL_SOURCES.md` dokumentiert. Ein Tool gilt erst dann als installierbar, wenn Quelle, Installer, Uninstaller, Healthcheck, Ressourcenhinweis und sichere Defaults vorhanden sind.

Wichtig zur Zaehlung:

- die automatische Live-Zaehlung erfolgt im Setup unter `Tool-Management`
- dort werden `Gesamtzahl` und `bereits installierte Tools` direkt aus der Tool-Liste und der Statusdatei berechnet
- diese Markdown-Datei bleibt bewusst eine thematische Uebersicht und nicht die laufende Statusanzeige

## Core

| Gruppe | Tools | Einsatz |
|---|---|---|
| Runtime | `ollama`, `docker`, `docker_compose_plugin`, `k3s` | lokale und serverseitige Laufzeit |
| Gateway / UI | `litellm`, `open_webui`, `langfuse` | Modellzugang, Telemetrie, UI |
| Coding / Agenten | `openclaw`, `aider`, `openhands`, `continue_dev`, `langgraph`, `crewai`, `autogen` | Coding, Orchestrierung, Agenten |
| RAG / Dokumente | `qdrant`, `chromadb`, `lightrag`, `llamaindex`, `haystack`, `docling`, `apache_tika`, `paperless_ngx` | Wissensspeicher und Dokument-Pipelines |
| Monitoring | `prometheus`, `grafana`, `loki`, `healthchecks`, `uptime_kuma`, `netdata`, `node_exporter`, `cadvisor` | Metriken, Logs, Hostzustand |
| Security | `trivy`, `gitleaks`, `semgrep`, `syft`, `grype`, `fail2ban`, `crowdsec`, `tailscale`, `cloudflared` | defensives Hardening, privater Remote-Zugriff, veröffentlichte Tunnel und Scans |

## Optional

| Gruppe | Tools | Einsatz |
|---|---|---|
| No-Code / Low-Code | `n8n`, `activepieces`, `node_red`, `flowise`, `langflow`, `appsmith`, `budibase`, `nocodb`, `directus` | interne Apps, Automatisierung, Daten-Frontends |
| Office / Knowledge | `nextcloud`, `stirling_pdf`, `pandoc`, `meilisearch`, `searxng`, `jupyterlab`, `duckdb`, `metabase`, `minio` | DMS, Berichte, Suche, Notiz-/Dateischicht |
| DevOps | `github_cli`, `act`, `pre_commit`, `release_please`, `ansible`, `opentofu`, `argocd_cli`, `grafana_alloy`, `restic`, `rclone`, `borgbackup` | Repo-, Release- und Plattformpflege |
| Browser / Research | `playwright`, `puppeteer`, `gbox` | kontrollierte Browser-/Desktop-/Android-Tests und Web-Analysen |
| Web-Automation | `huginn`, `firecrawl` | Event-Automation, Agentenketten, Webhook-Routing und Webquellen-Connectoren |
| Smart Home / Edge | `home_assistant`, `mosquitto`, `zigbee2mqtt`, `esphome` | lokale IoT- und Sensor-Workflows |

## Experimental

| Tools | Grund |
|---|---|
| `openmanus`, `clawhub`, `clawhub_cli` | mehrere GitHub-Quellen, Build-/Netzwerkfragilitaet moeglich |
| `video`- und `voice-clone`-nahe Toolketten | hoher Ressourcenbedarf, heterogene Upstreams |
| `flowise` und `langflow` parallel | funktional sinnvoll, aber Port- und Bedienkonzept noch nicht vereinheitlicht |
| `gbox` | vielversprechende Android-/Browser-/Desktop-/MCP-Agentenumgebung, aber Login-/Cloud-/Device-Zugriffe muessen sauber begrenzt werden |

## High-Risk

| Tools / Bereiche | Risiko |
|---|---|
| `Web3_Crypto_Agent`, Trading-Stacks | keine Live-Orders, Seeds oder echten Exchange-Keys als Default |
| Voice-/Clone-/Face-/Video-Workflows | Rechte, Einwilligung, Missbrauchsrisiko |
| Browser-/Scraping-/OSINT-Automation | Rechts- und Datenschutzgrenzen klar einhalten |
| Security-Scanner und Infra-Automation | nur defensiv und mit Review in produktionsnahen Umgebungen |

## Wichtige Luecken

Diese Kandidaten sind fachlich sinnvoll, aber in diesem Repo noch nicht sauber als installierbare Standardmodule hinterlegt:

- `browser-use`
- `SWE-agent`
- `Tabby`
- `Typesense`
- `detect-secrets`
- `OpenBao`
- `SOPS`
- `age`
- `Taskfile`
- `just`
- `Kopia`
- `Superset`
- `Evidence.dev`
- `DVC`
- `Label Studio`

Sie sind gute Kandidaten fuer die naechste Ausbaustufe, sollten aber erst mit klarer Install-/Uninstall-/Status-Logik nachgezogen werden.

`Tailscale` ist bewusst bereits integriert, weil es direkt zur Sicherheitsgrundregel des Repos passt: Admin-Zugriffe nach Moeglichkeit privat statt ueber offene Web-Panels oder rohe Host-Ports.
# Zusatz: Job Queue und planned Tools 2026

| Tool | Status | Risiko | Quelle |
|---|---|---|---|
| job_queue | beta | niedrig | lokale Bash/JSONL-Implementierung |
| queue_manager | planned | niedrig | `https://github.com/rq/rq` als moeglicher Startpunkt |
| bullmq | planned | mittel | `https://github.com/taskforcesh/bullmq` |
| celery | planned | mittel | `https://github.com/celery/celery` |
| rq | planned | niedrig | `https://github.com/rq/rq` |
| modelcontextprotocol_servers | planned | mittel | `https://github.com/modelcontextprotocol/servers` |
## Voice Studio Tool-Erweiterung 2026

| Tool | Quelle | Status | Ressourcen | Installationsart | Hinweis |
| --- | --- | --- | --- | --- | --- |
| Piper | https://github.com/rhasspy/piper | optional/stable | light | binary/manual | Standard fuer lokale schnelle TTS und Home Assistant. |
| Coqui TTS / XTTS v2 | https://github.com/coqui-ai/TTS | optional/experimental | gpu-heavy | venv/source | Hochwertige Stimmen und Voice-Cloning; Python-Kompatibilitaet pruefen. |
| StyleTTS2 | https://github.com/yl4579/StyleTTS2 | planned | gpu-heavy | source | Emotionale Stimmen, keine Auto-Installation. |
| OpenVoice | https://github.com/myshell-ai/OpenVoice | planned | gpu-heavy | source | Voice Transfer und Voice-Cloning nur mit Einwilligung. |
| RVC | https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI | planned | gpu-heavy | source | Gesangsstimmen und Voice Conversion. |
| Seed-VC | https://github.com/Plachtaa/seed-vc | planned | gpu-heavy | source | Moderne Voice Conversion, experimentell. |
| DiffSinger | https://github.com/openvpi/DiffSinger | planned | gpu-heavy | source | KI-Gesang und virtuelle Saenger. |
| OpenUtau | https://github.com/stakira/OpenUtau | planned | medium | manual | Gesangsproduktion und virtuelle Saenger. |
| NNSVS | https://github.com/nnsvs/nnsvs | planned | gpu-heavy | source | Eigenes Singer-Training, fortgeschritten. |
| UVR5 | https://github.com/Anjok07/ultimatevocalremovergui | planned | gpu-heavy | source | Stimm-/Instrumententrennung fuer Datenvorbereitung. |
| Audacity | https://github.com/audacity/audacity | optional | medium | manual | Schnitt, Reinigung und Dataset-Vorbereitung. |
| FFmpeg | https://github.com/FFmpeg/FFmpeg | stable | light | apt/binary | Export, Mixdown, Normalisierung und Formatwandlung. |

Rechtsregel: Nur eigene Stimmen oder Stimmen mit dokumentierter Einwilligung verwenden. KI-Stimmen und KI-Gesang muessen bei Veroeffentlichung gekennzeichnet werden.
## AI Media Production Tool-Erweiterung 2026

| Tool | Quelle | Status | Ressourcen | Zweck |
| --- | --- | --- | --- | --- |
| Fish Speech | https://github.com/fishaudio/fish-speech | planned | gpu-heavy | Multilinguales TTS und Voice-Experimente. |
| MeloTTS | https://github.com/myshell-ai/MeloTTS | planned | medium | Mehrsprachiges TTS fuer Moderation und Broadcast. |
| Kokoro TTS | https://github.com/hexgrad/kokoro | planned | light | Leichtes lokales TTS. |
| Spark-TTS | https://github.com/SparkAudio/Spark-TTS | planned | gpu-heavy | Kontrollierte Stimmerzeugung. |
| Hallo2 | https://github.com/fudan-generative-vision/hallo2 | planned | gpu-heavy | Lange hochaufloesende Portraitanimation. |
| MuseTalk | https://github.com/TMElyralab/MuseTalk | planned | gpu-heavy | Hochwertige Lip-Synchronisation. |
| LivePortrait | https://github.com/KlingAIResearch/LivePortrait | planned | gpu-heavy | Portraitanimation und Motion-Retargeting. |
| SadTalker | https://github.com/OpenTalker/SadTalker | planned | gpu-heavy | Talking-Head-Video aus Bild und Audio. |
| EMO | https://github.com/HumanAIGC/EMO | planned/research | gpu-heavy | Expressive Audio-to-Video-Portraits. |
| SkyReels-A1 | https://github.com/SkyworkAI/SkyReels-A1 | planned | gpu-heavy | Expressive Portraitanimation mit Video-Diffusion. |
| Wav2Lip | https://github.com/Rudrabha/Wav2Lip | planned | medium | Klassisches LipSync-Toolkit. |

Diese Tools werden nicht automatisch installiert. Vor Tests sind Lizenz, Modellgewichte, VRAM, Einwilligung echter Personen und Kennzeichnungspflichten zu pruefen.
## Strukturierte Media-Tool-Kategorien

Die Registry `config/tools.yml` enthaelt jetzt zusaetzliche Kategorien fuer das Media Studio:

- `voice_tools`: Piper, XTTS/CoquiTTS, OpenVoice, StyleTTS2, MeloTTS, FishSpeech, KokoroTTS.
- `singing_tools`: RVC, SeedVC, DiffSinger, OpenUtau, NNSVS.
- `avatar_tools`: Hallo2, MuseTalk, SadTalker, LivePortrait, Wav2Lip, EMO, SkyReels.
- `audio_tools`: FFmpeg, Audacity, UVR5, ClearerVoice Studio.
- `broadcast_tools`: OBS, Whisper, FasterWhisper, SubtitleEdit.

Alle Kategorien sind als Katalog-/Menuevorbereitung gedacht. Schwere Tools bleiben `planned` oder `optional` und werden nicht automatisch installiert.
