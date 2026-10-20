# Tool Matrix

| Tool | Status | Lizenz | Source-Reserve | Ports/Keys | Doctor / Deaktivierung |
|---|---|---|---|---|---|
| [HF_Accelerate](memory/UNIFIED_MEMORY_AND_OFFLOADING.md) | experimental, source-only | Apache-2.0 | 1 GiB Disk | keine | vorhanden, Quellen/Logs bleiben |
| [DeepSpeed](memory/UNIFIED_MEMORY_AND_OFFLOADING.md) | experimental, source-only; heavy-runtime separat | Apache-2.0 | 1 GiB Disk | keine | vorhanden, Quellen/Logs bleiben |

| Tool | Quelle | Status | Ressourcen | Ports / Secrets | Umfang |
|---|---|---|---|---|---|
| [REA](tools/rea.md) | morluto/rea, 1629266e3c08c90fed6bba5383528af7986a12b7, MIT | experimental / optional | 1 GiB Source-Reserve; optionaler Build 8 GiB Disk / 2 GiB verfuegbarer RAM | keine bei Vorbereitung | GitHub-Checkout, optionaler Build; kein Docker, MCP/Analyse separat |

| Tool | Quelle | Status | Ressourcen | Ports / Secrets | Installation |
|---|---|---|---|---|---|
| [Find_Skills](tools/find-skills.md) | vercel-labs/skills, a80e4c9d12d607631249d4d7d059f835d4b2f13a, MIT | experimental / optional | low; 256 MiB Disk/RAM-Reserve, keine GPU | keine / keine fuer Kopie | GitHub-Skill nach Zustimmung; keine gebaute CLI, kein Docker |

Embedded_Debug_HIL: [private pygdbmi-Basis aus GitHub](tools/embedded-debug-hil.md),
experimental/light, ohne Docker. Hardware-/MCP-Adapter weiterhin planned;
keine Debuggerinstallation, USB-Verbindung oder Boardaktion.

MOSS_TTS: [gepinntes GitHub-Basispaket](tools/moss-tts.md), ohne Docker.
Experimental/gpu-heavy: Checkout und private Basis-venv, keine fertige
TTS-Laufzeit, Modelle oder Inferenz. Eigenstaendige Lifecycle-Skripte im Menue.

Claude_Code/Gemini_CLI: [getrennte Coding-Agenten-Profile und GitHub-Quellvorbereitung](agents/coding-agent-profiles.md).
Ohne Docker, keine CLI gebaut/gestartet. Claude-Code-Repository ist
proprietaeres Referenzmaterial, Gemini CLI ist Open Source. Quellstatus ist kein Runtime-Status.

YuE: [GitHub-Quellinstaller fuer YuE-v1](tools/yue.md), ohne Docker.
Experimental/gpu-heavy, keine Python-/GPU-Runtime oder Modellinstallation.
YuE2 auf main wird nicht ungefragt unter demselben Menuepunkt installiert.

ACE_Step_15: [GitHub-Basispaket ace-step 1.5.0](tools/ace-step-15.md),
ohne Docker, private venv. Experimental/gpu-heavy; Runtime, Modelle und
GUI/API bleiben separat, keine automatisch betriebsbereite Musikgenerierung.

WhisperX: [GitHub-Paket 3.8.6](tools/whisperx.md), private venv ohne Docker.
Experimental/heavy, Basis --no-deps. Runtime mit explizitem Opt-in und
vorhandenem Torch-Stack; keine automatische Transkription oder Diarisierung.

Aegisub: [GitHub-Quellen 3.5.1 und optionaler Meson-Build](tools/aegisub.md),
ohne Docker. Experimental; private Installation statt Systemeingriff,
vorhandene Build-Abhaengigkeiten erforderlich. Kein GUI-/Audiotest.

Basic_Pitch: [Basic Pitch 0.4.0 aus GitHub](tools/basic-pitch.md), private
venv ohne Docker. Experimental; Standard --no-deps, Runtime separat opt-in.
Paket-/Abhaengigkeitsstatus sind kein Audio-zu-MIDI-Qualitaetstest.

Sfizz: [GitHub-Engine 1.2.3 und optionaler Renderer-Build](tools/sfizz.md),
ohne Docker, experimental/archiviert. Quellenstatus und Buildstatus getrennt;
keine DAW-Plugin-Installation oder automatische Audioausgabe.

AIDA_X: [GitHub-Quellen 1.1.0](tools/aida-x.md), optional nativer
Standalone-CMake-Build ohne Docker, 1 Build-Job; kein Audio-/DAW-Test.

ProPainter: [GitHub-Quellinstaller](tools/propainter.md) ohne Docker/
Pakete/Modelle; S-Lab-Lizenzbestaetigung, keine fertige Inferenz-Laufzeit.

Kiwi_Edit: [GitHub-Basispaket diffsynth 2.0.4](tools/kiwi-edit.md),
private venv ohne Docker/Runtime/Modelle; Remote-Code und Lizenzen separat pruefen.

VOID_Model: [GitHub-Quellinstallation](tools/void-model.md) ohne Docker,
Pakete/Modelle oder Cloud-Aufrufe; nicht betriebsbereit. GPU-/Gemini-Grenzen beachten.

Just_Dub_It: [archivierte GitHub-Basispakete](tools/just-dub-it.md),
Python 3.12, LTX-2-Lizenz-Opt-in; kein Docker, Modelle oder Dubbing-Start.

Personnel_Documents_AI: [privater GitHub-Checkout-Starter](tools/personnel-documents.md),
Python 3.10+, ohne Docker/Paketdownload; kein fertiges HR-/Paperless-System.

Moshi: [GitHub-Python-Basispaket 0.2.13](tools/moshi.md), experimental,
Monorepo-Unterordner `moshi/`, private venv ohne Docker/Modelle/Server.

Stable Audio Open: [GitHub-Basispaket stable-audio-tools 0.0.20](tools/stable-audio-open.md),
experimental; private Python-3.10-venv, ohne Docker/GPU-Runtime/Modelle.

AudioGen: [AudioCraft 1.3.0 aus GitHub](tools/audiogen.md), experimental,
private Basis-venv ohne Docker; Runtime und Modelle nicht installiert.

AudioLDM2: [gepinntes GitHub-Basispaket ohne Docker](tools/audioldm2.md),
--no-deps, noch keine Audio-Laufzeit. Legacy-Pins, share=True und
widerspruechliche Lizenzangaben vor Vollbetrieb pruefen.

ChatTTS: [GitHub-Paket ohne Docker](tools/chattts.md), standardmaessig
ohne Runtime; Core-Abhaengigkeiten doppelt opt-in. Modell laut Upstream
nichtkommerziell, keine automatische WebUI oder Sprachgenerierung.

Qwen3_TTS: [GitHub-Paketinstallation ohne Docker](tools/qwen3-tts.md),
standardmaessig ohne Runtime-Abhaengigkeiten; Runtime doppelt opt-in,
keine Modell-/Demo-/Trainingsstarts.

Alexandria_Audiobook: [GitHub-Quellinstaller und private venv](tools/alexandria-audiobook.md)
ohne Docker, experimental. Keine GPU-/Modellinstallation oder Hoerbuchbereitschaft.

| Neuer Pfad | Status | Einstieg |
|---|---|---|
| Microsoft_Agent_Framework | experimental, optionaler GitHub-Python-Core-Installer ohne Docker | [Installation, Grenzen und Doctor](tools/microsoft-agent-framework.md) |
| Qwen_Desktop | planned / manual-windows | [Windows-GUI, Release und lokale Installerpruefung](tools/qwen-desktop-windows.md) |
| Cline | experimental, optionales GitHub-VSIX; Editor-Installation separat | [Paket bereitstellen und in VS Code installieren](tools/cline.md) |
| Qwen_Code | experimental, optionaler GitHub-CLI-Source-Build ohne Docker | [Installation, Ressourcen und sichere Nutzung](tools/qwen-code.md) |
| Wan21 | experimental / gpu-heavy, GitHub-Source; GPU-Pakete separat opt-in | [Installation und Modellgrenzen](tools/wan21.md) |
| ComfyUI_GGUF | experimental / gpu-heavy, GitHub-Custom-Node ohne Docker | [Einbindung in vorhandenes ComfyUI](tools/comfyui-gguf.md) |
| SUPIR | experimental / gpu-heavy, GitHub-Quellen; Runtime nicht freigegeben | [Lizenz, Paketkonflikt und Installation](tools/supir.md) |
| FILM | experimental / gpu-heavy, archivierter GitHub-Upstream; nur Quellen | [Installation und sichere Interpolationsplanung](tools/film.md) |
| ViDubb | experimental, GitHub-Sparse-Quellinstallation; Dubbing-Laufzeit NICHT betriebsbereit | [Quellinstaller und notwendiger Sicherheitsumbau](tools/vidubb.md) |
| WanVideoWrapper | planned / gpu-heavy | [Versionen/8K-/VRAM-Grenzen](media_studio/HYBRID_MODELS_AND_WAN.md) |

| Defensive Audio-Kandidaten | Stand | Grenze |
|---|---|---|
| Pyannote_Audio | experimental, GitHub-Quellen; CPU-Pakete doppelt opt-in | [Installation](tools/pyannote-audio.md); Diarisierung, keine Echtheits-/Identitaetsentscheidung |
| [DeepFilterNet](tools/deepfilternet.md) | experimental, GitHub Rust-CPU-Build | Rauschminderung, eingebettetes Modell; keine Deepfake-Entfernung |
| [AudioSeal](tools/audioseal.md) | experimental, GitHub CPU-Paketbuild | Private venv, keine automatischen Modelle/Audioaktionen; kein universeller Detektor |

[Quellen, vorhandene Audio-Tools und Workflow](media_studio/AUDIO_DEEPFAKE_REVIEW.md).

## Social-Avatar-Kandidaten

| Gruppe | Neue Eintraege | Status / Grenze |
|---|---|---|
| Video / WebUI | CogVideoX, LTX_Video | planned / gpu-heavy |
| WebUI | [SD_Next](tools/sdnext.md) | experimental: GitHub-Quelle + venv ohne Docker; Runtime separat |
| Desktop | [Pinokio](tools/pinokio.md) | planned/manual-desktop; GitHub v8.2.0, Browser und Wartepause, kein Docker |
| Workflows | [Windmill](tools/windmill.md) | experimental; GitHub-Quelle, optional Linux-amd64-Release mit Lizenz-Opt-in/SHA256, kein Docker/Dienststart |
| LLM-Inferenz | [TGI](tools/tgi.md) | experimental: GitHub-Quellen/optionaler nativer Launcher, kein kompletter Inferenzserver; Maintenance Mode |
| Externe API-Clients | [Fal_Client](tools/fal-client.md) | experimental; GitHub-Python-SDK ohne Docker, keine Cloudtests |
| Externe API-Clients | [Veo_API](tools/veo-api.md) | experimental; google-genai 2.31.0 aus GitHub ohne Docker; kein lokales Veo/API-Test |

[Quellen, Lizenzkorrekturen, vorhandene Alternativen und Workflow](media_studio/SOCIAL_AVATAR_AUTOMATION.md).

| Neue Dataset-Tools | Status | Integration |
|---|---|---|
| [HF_Datasets / hf_datasets](tools/hf-datasets.md) | experimental, GitHub-Basispaket | Private venv; keine Datensatz-/Modell-Downloads oder Decoder; kein Trainer |
| [HF_Hub / hf_hub](tools/hf-hub.md) | experimental, GitHub-Client/CLI | Private venv; keine automatischen Logins, Transfers oder Cloudjobs |
| Video2Dataset / video2dataset | planned / heavy | genehmigte URL-Listen; keine autonome Beschaffung |

[Details und Primaerquellen](media_studio/VIDEO_TRAINING_DATASETS.md).
Gemeinsame Guards liefern keine Installations-/Download-/Trainingsfreigabe.

## Audio-/Video-Erweiterung (Documentation First)

[20 Kandidaten mit GitHub-Quelle und Ressourcenklasse](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md)
sind als planned in Registry und Tool-Menue verdrahtet; gemeinsame Guards,
keine Downloads/Starts. [Karaoke_Formats](media_studio/KARAOKE_SUBTITLES_GUIDE.md)
ist eine eigene experimentelle Repository-CLI mit optionalem privatem
Installer aus dem GitHub-Checkout, ohne Docker; kein ASR-/TTS-Modell.

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

| Toolgruppe | Stand / Anleitung |
|---|---|
| Aider, Continue, OpenCode, OpenHands, LangGraph, CrewAI, AutoGen | [Agentic-Coding-Tools](tools/agentic-coding.md): vorhandene Eintraege dokumentiert, nicht pauschal neu installiert/getestet |
| Microsoft_Agent_Framework | neu `planned`, Registrierung/Plan ohne Runtime; AutoGen-Nachfolge nicht automatisch migrieren |
| Automaton | optionaler GitHub-Source-Build, `experimental/high-risk`; kein freier Coding-/Wallet-Loop |

| Tool | Status | Zweck | Schutz |
|---|---|---|---|
| [Personnel_Documents_AI](tools/personnel-documents.md) | experimental | Lokaler JSON-/Ollama-Vorschlag | keine automatischen Aktenaenderungen; menschliche Pruefung |
| Paperless_NGX | neuer Installer experimental | bestehendes DMS/OCR | localhost 8010, private ENV, Docker-Opt-in, Legacy-Migrationssperre |

| Tool | Status | Quelle | Sicherheitsgrenze |
|---|---|---|---|
| [Automaton](tools/automaton.md) | experimental / high-risk | Conway-Research/automaton, MIT, gepinnter Source-Build ohne Docker | Node/npm und pnpm 10.28.1 bei Bedarf privat bereitstellen; Reserve 4 GiB RAM/10 GiB Disk; kein Agentenstart, Wallet, Signaturen, Zahlungen oder Live-Trades |

| Tool | Status | Quelle / Funktionsumfang |
|---|---|---|
| [Embedded_Debug_HIL](tools/embedded-debug-hil.md) | Live-Adapter planned; Offline-Prototyp vorhanden | OpenOCD/pyOCD/pygdbmi als GitHub-Kandidaten, keine automatische Installation; Board-/Probe-Freigabe erforderlich |

| Tool | Status | Quelle / Installation | Ressourcen / Sicherheit |
|---|---|---|---|
| [FreeLLMAPI](tools/freellmapi.md) | experimental, optional | GitHub `tashfeenahmed/freellmapi`, Source-Build `v0.14.2`, ohne Docker | Buildreserve 2 GiB RAM/4 GiB Disk; fehlendes Node/npm privat via GitHub-nvm, System-Node erhalten. Start separat, nur localhost:3011; kein Gratis-/Offline-Versprechen |

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
| Coqui TTS / XTTS v2 | https://github.com/coqui-ai/TTS | experimental | gpu-heavy | venv/source | Benoetigt Python `>=3.9,<3.12`; Ubuntu 24.04/Python 3.12 wird bewusst abgebrochen. Piper ist der stabile Fallback. |
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
## dbt Installationshinweis

`dbt-core` wird aus der GitHub-Quelle `https://github.com/dbt-labs/dbt-core.git` geklont, aber aus dem Unterordner `core` installiert. Der Repository-Root ist ein Monorepo/Flat-Layout und darf nicht direkt per `pip install -e` installiert werden. Details: [DBT_INSTALLATION_NOTES.md](DBT_INSTALLATION_NOTES.md).

## Next-Level-Ergaenzungen 2026-05-31

| Tool | Kategorie | Status | Ressourcen | Installationsrisiko | Auto-Install |
| --- | --- | --- | --- | --- | --- |
| PaddleOCR | RAG / OCR | planned/manual | medium | medium | nein |
| LiveKit | Voice / Realtime | planned/manual | high | medium | nein |
| Asterisk | Voice / Telefonie | planned/manual | high | medium | nein |
| Beszel | Monitoring | planned/manual | low | low | nein |
| Zeek | Security | planned/manual | high | high | nein |
| Falco | Security | planned/manual | high | high | nein |
| Stalwart | Mail | planned/manual | medium | high | nein |
| Sieve | Mail | planned/manual | low | medium | nein |

Diese Ergaenzungen sind bewusst dokumentations- und registry-first. Sie duerfen erst installierbar werden, wenn `check`, `install`, `uninstall`, `doctor`, Ressourcenpruefung und Port-/Secret-Hinweise vorhanden sind.

