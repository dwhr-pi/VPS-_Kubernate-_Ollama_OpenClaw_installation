# GitHub Tool Sources

Agentic_OS: [modimihir07/agentic-os](https://github.com/modimihir07/agentic-os/tree/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6),
MIT, Pin 9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6.
[Evaluationsvermerk und Source-only-Installer](tools/agentic-os.md), keine Runtime.

YouTube_Agent_Skill: [Jakeschincariol/youtube-agent-skill](https://github.com/Jakeschincariol/youtube-agent-skill/tree/a2feb2104981a375ffd4f87ee04f4f5344ac43c6),
MIT, Pin `a2feb2104981a375ffd4f87ee04f4f5344ac43c6`.
[Installation und Tutorial](tools/youtube-agent-skill.md): elf Skills inklusive
sechs Python-Helfern unveraendert nach Zustimmung kopieren; kein MCP-Server,
Docker, YouTube-Login, Agentenstart oder Upload.

Anthropic_CLI / ant: [anthropics/anthropic-cli](https://github.com/anthropics/anthropic-cli/tree/78ab237474e7c34983d77f6f41fcd1152f32a7ce),
MIT, Pin `78ab237474e7c34983d77f6f41fcd1152f32a7ce`.
[Build und API-Grenzen](tools/anthropic-cli.md): Go >=1.25 am Pin,
fehlende Toolchain als offizielles SHA256-geprueftes Go 1.27.3 privat bereitstellen.
Anthropic-Quellen bleiben auf GitHub; kein Docker, keine Anmeldung/API-/Agentenausfuehrung.

Colibri: [JustVugg/colibri](https://github.com/JustVugg/colibri/tree/e0db083cdc9e563e0766cc6fc661ef23c32298e0),
Commit `e0db083cdc9e563e0766cc6fc661ef23c32298e0`, Apache-2.0.
[MiniPC-/RTX-Anleitung](tools/colibri.md): nur Quellcheckout, kein Docker,
Upstream-Bootstrap, Modell-Download oder Serverstart durch den Installer.

Hyperfine: [sharkdp/hyperfine](https://github.com/sharkdp/hyperfine/tree/c5161524980522320c7d3425e714cc0965a869a5),
Commit `c5161524980522320c7d3425e714cc0965a869a5`, MIT OR Apache-2.0.
[Messanleitung](tools/local-ai-benchmarks.md): nur GitHub-Quellen im Installer,
keine Rust-/Dockerinstallation oder automatisch ausgefuehrten Lasttests.

HF_Accelerate: [huggingface/accelerate](https://github.com/huggingface/accelerate/tree/abe3749c6274b2ffc9a99cc57ca72ff8bca72ab8),
Commit `abe3749c6274b2ffc9a99cc57ca72ff8bca72ab8`, Apache-2.0, Entwicklungsstand.
DeepSpeed: [deepspeedai/DeepSpeed](https://github.com/deepspeedai/DeepSpeed/tree/3133d9d689a67ab1d4feebf8166f19ee28cace6a),
Commit `3133d9d689a67ab1d4feebf8166f19ee28cace6a`, Apache-2.0.
[Umfang](memory/UNIFIED_MEMORY_AND_OFFLOADING.md): nur Quellcheckout,
keine Modelle, Treiber, Torch- oder GPU-Runtime, kein Docker.

REA: [morluto/rea](https://github.com/morluto/rea/tree/1629266e3c08c90fed6bba5383528af7986a12b7),
Commit `1629266e3c08c90fed6bba5383528af7986a12b7`, Quellversion 6.7.0, MIT.
[Installationsumfang](tools/rea.md): GitHub-Quellen, optionaler Source-Build;
keine automatische MCP-Registrierung, Engine-Installation oder Zielanalyse.

Find_Skills: [vercel-labs/skills](https://github.com/vercel-labs/skills/tree/a80e4c9d12d607631249d4d7d059f835d4b2f13a),
Commit `a80e4c9d12d607631249d4d7d059f835d4b2f13a`, MIT.
[Installationsumfang](tools/find-skills.md): SKILL.md und Lizenz nach Zustimmung;
keine Docker-/npm-/Agentenausfuehrung. Vercel Skills CLI und skills.sh werden
separat erklaert, nicht als bereits installierte CLI gemeldet.

Embedded_Debug_HIL: [cs01/pygdbmi v0.11.0.0](https://github.com/cs01/pygdbmi/tree/52a17f1d8651e941b8551a44a03d181d605e1e56),
Commit `52a17f1d8651e941b8551a44a03d181d605e1e56`, MIT.
[Basisinstaller](tools/embedded-debug-hil.md) ohne Docker, keine GDB-Prozesse
oder Hardware-/USB-/MCP-Aktionen. OpenOCD/pyOCD sind separate geplante Komponenten.

MOSS_TTS: [OpenMOSS/MOSS-TTS](https://github.com/OpenMOSS/MOSS-TTS/tree/934d6826b084c46a0d033402174d5f8ac4ed2519),
Commit `934d6826b084c46a0d033402174d5f8ac4ed2519`, Basis-Metadatenpaket 0.1.0,
Code Apache-2.0. [Installationsumfang](tools/moss-tts.md): kein Docker,
keine Runtime-/Modellinstallation, Modelllizenzen separat pruefen.

Getrennte Coding-Agenten: [Quellpins und Lizenzgrenzen](agents/coding-agent-profiles.md).
Claude Code: anthropics/claude-code `dd6bee38458cc3e6dc5f2b16eca1f0f364619ad8`,
proprietaeres Referenzmaterial, keine CLI-Source-Installation.
Gemini CLI: google-gemini/gemini-cli `ed96faedfd5571f055c44f2c9509d62321d1138d`,
Apache-2.0-Quellen, separater Build erforderlich. Keine Docker-Nutzung.

YuE: [multimodal-art-projection/YuE, YuE-v1](https://github.com/multimodal-art-projection/YuE/tree/6d4f0b1f8ce6a55fb2392e959394c46e07ee334d),
Commit `6d4f0b1f8ce6a55fb2392e959394c46e07ee334d`, Apache-2.0.
main enthaelt YuE2, nicht die hier registrierte Generation. [Quellinstallation
und Runtime-Grenzen](tools/yue.md); kein automatischer xcodec-/Modell-Download.

ACE_Step_15: [ace-step/ACE-Step-1.5, Tag v0.1.8](https://github.com/ace-step/ACE-Step-1.5/tree/v0.1.8),
Commit `dce621408bee8c31b4fcf4811682eb9359e1bc94`, Python-Paket ace-step
1.5.0, MIT. [Installer ohne Docker und Runtime-Grenzen](tools/ace-step-15.md).
Hatchling als Build-Abhaengigkeit kommt von PyPI; GPU-Pakete werden nicht aufgeloest.

WhisperX: [m-bain/whisperX v3.8.6](https://github.com/m-bain/whisperX/tree/v3.8.6),
Commit `3ccc17b8de34f305300f8a3fd3c9f76ba820c0d0`, BSD-2-Clause.
Das GitHub-Repo enthaelt ein VAD-Gewicht. Build-/optionale Runtime-Pakete
kommen aus PyPI; Torch/Audio/Vision werden vorher bewusst eingerichtet.
[Installation und Modellgrenzen](tools/whisperx.md).

Aegisub: [TypesettingTools/Aegisub v3.5.1](https://github.com/TypesettingTools/Aegisub/releases/tag/v3.5.1),
Commit `088ca6caa878209e279871f8897273f49342372b`, BSD-3-Clause plus
Komponentenlizenzen in LICENCE. [Installation ohne Docker](tools/aegisub.md).
Meson nutzt im optionalen Build vorhandene Systembibliotheken, keine Wrap-Downloads.

Basic_Pitch: [spotify/basic-pitch v0.4.0](https://github.com/spotify/basic-pitch/tree/v0.4.0),
Commit `9991303bba609a3b93089d13ec80d1d495083596`, Apache-2.0.
GitHub-Quellpaket inklusive kleiner Inferenzmodelle; Python-Build-/optionale
Runtime-Abhaengigkeiten von PyPI. [Installer und Grenzen](tools/basic-pitch.md).

Sfizz: [sfztools/sfizz, Release 1.2.3](https://github.com/sfztools/sfizz/releases/tag/1.2.3),
Commit `4e70dc0bef53b41f2853ed46e26f5911114c92d0`, BSD-2-Clause,
archivierte Engine. Sechs GitHub-Unterprojekte mit festen Pins im
[Installer-Manifest](../scripts/tools/helpers/sfizz_common.sh); kein Docker.
[Installation und Grenzen](tools/sfizz.md).

AIDA-X: [AidaDSP/AIDA-X 1.1.0](https://github.com/AidaDSP/AIDA-X/tree/1.1.0),
Pin `1027cdd1756505fd2ab1a4adb91a394a3af9df57`, GPL-3.0-or-later.
[Nativer GitHub-Installer](tools/aida-x.md), acht gepinnte GitHub-Unterprojekte,
Standalone-Build optional; kein Docker oder Audio-Start.

ProPainter: [sczhou/ProPainter](https://github.com/sczhou/ProPainter/tree/e870e79321c31b733e2031af5aa2fb1fe3ac7eec),
Pin `e870e79321c31b733e2031af5aa2fb1fe3ac7eec`.
[Sparse-Quellinstaller ohne Docker](tools/propainter.md), S-Lab License 1.0
nichtkommerziell; keine Modelle oder Inferenz installiert/gestartet.

Kiwi Edit: [showlab/Kiwi-Edit](https://github.com/showlab/Kiwi-Edit/tree/178f3f4f8221d7598fcc21875c847d6cf6323c4e),
Pin `178f3f4f8221d7598fcc21875c847d6cf6323c4e`, Paket diffsynth 2.0.4.
[GitHub-Installer ohne Docker](tools/kiwi-edit.md); Root MIT,
Paketmetadaten Apache-2.0 und Modellbedingungen getrennt pruefen.

VOID: [Netflix/void-model](https://github.com/Netflix/void-model/tree/e3914f8f551dd4b880661991fd6b28cd1699a97a),
Pin `e3914f8f551dd4b880661991fd6b28cd1699a97a`, Code Apache-2.0.
[GitHub-Sparse-Quellinstaller](tools/void-model.md), ohne Docker/Paket-/Modell-
Download oder Gemini-Aufruf; Modellbedingungen und GPU-Stack separat pruefen.

Just Dub It: [justdubit/just-dub-it](https://github.com/justdubit/just-dub-it/tree/fa4d8f8911036ba79a62f97e7e62581e39441d56),
archiviert, Pin `fa4d8f8911036ba79a62f97e7e62581e39441d56`.
[GitHub-Installer ohne Docker](tools/just-dub-it.md) fuer ltx-core/ltx-pipelines
0.1.0; LTX-2 Community License und Modellbedingungen separat pruefen.

Personnel_Documents_AI stammt aus dem [Setup-Repository](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation),
nicht aus Paperless selbst. Der [private CLI-Starter](tools/personnel-documents.md)
nutzt den vorhandenen GitHub-Checkout mit SHA-256-Pruefung, ohne Docker oder
erneuten Download. Paperless und Ollama sind separate optionale Bausteine.

Moshi: [kyutai-labs/moshi](https://github.com/kyutai-labs/moshi/tree/e6a55d2722a65870ef52a6c9f6ecfc0e90f38362),
Pin `e6a55d2722a65870ef52a6c9f6ecfc0e90f38362`, Python-Paket 0.2.13
aus Unterordner `moshi/`. [Installer ohne Docker](tools/moshi.md);
Python MIT, Rust Apache-2.0, Modellkarten/CC-BY 4.0 separat pruefen.

Stable Audio Open: [Stability-AI/stable-audio-tools](https://github.com/Stability-AI/stable-audio-tools/tree/3241adba4fc2a85cf5b29d9eb68d42f40a28e820),
Paket 0.0.20, Pin `3241adba4fc2a85cf5b29d9eb68d42f40a28e820`.
MIT-Code; Modelllizenz separat. [GitHub-Installer](tools/stable-audio-open.md)
ohne Docker; Python 3.10 ist erforderlich.

AudioGen: [facebookresearch/audiocraft](https://github.com/facebookresearch/audiocraft/tree/v1.3.0),
Commit `72cb16f9fb239e9cf03f7bd997198c7d7a67a01c`; MIT-Code,
CC-BY-NC-4.0-Gewichte. [Nativer Basispaket-Installer](tools/audiogen.md), keine Docker-/Modellinstallation.

[AudioLDM2](tools/audioldm2.md): haoheliu/AudioLDM2,
b5786c5dc0ae8f766337fdc1b67ab6046586d14d / Paket 0.1.0. GitHub --no-deps
in privater venv, keine Docker-/Legacy-Runtime-/Modell-/WebUI-Aktion.
LICENSE nennt CC BY-NC-SA 4.0, setup.py MIT: nicht pauschal kommerziell freigeben.

[ChatTTS](tools/chattts.md): 2noise/ChatTTS,
77b89ee281cd479f5b1a787ada330dc975ca1f2a. Code AGPLv3+, Modell CC BY-NC 4.0.
Setup.py-Default 0.0.0 explizit statt geerbtem CHTTS_VER, massgeblich Commit.
GitHub-Paket in privater venv ohne Docker, keine Gewichte/WebUI.

[Qwen3_TTS](tools/qwen3-tts.md): QwenLM/Qwen3-TTS,
022e286b98fbec7e1e916cb940cdf532cd9f488e / qwen-tts 0.1.1.
Private venv, standardmaessig --no-deps; Runtime separat mit Torch-Constraints
und doppeltem Opt-in. Keine Modelle/Flash-Attention/Demo oder Docker.

[Alexandria_Audiobook](tools/alexandria-audiobook.md): Finrandojin/alexandria-audiobook,
Pin be6343d95d94db5f88973aa25575a390f3ce46aa. GitHub-Quellen und private venv
ohne Docker; Qwen-/GPU-Laufzeit und Modelle separat. Keine Pinokio-Install-/Reset-Aktion.

[Pyannote_Audio](tools/pyannote-audio.md): GitHub-Release 4.0.4,
Commit `78c0d16a5f558adb1024d112e6857b3204b450b3`, MIT-Code. Ohne Docker;
CPU-Pakete privat aus PyTorch/PyPI nur mit doppeltem Opt-in. Keine Modelle,
Tokens, Pipeline-Imports oder Audio-/Echtheitsbewertung bei der Installation.

[FILM](tools/film.md): google-research/frame-interpolation, Commit
`69f8708f08e62c2edf46a27616a4bfcf083e2076`, Apache-2.0 Code. Archivierter
Upstream; nur Quellen ohne Docker, keine Legacy-TensorFlow-/Modellinstallation.

[SUPIR](tools/supir.md): Fanghua-Yu/SUPIR, Commit
`bda91af2000042f8bedfec8897d92917e67c1d88` (master), nur Quellen ohne Docker.
Eigener Lizenzvertrag mit kommerziellen Einschraenkungen. Automatische
Legacy-Paketinstallation wegen FastAPI-/Gradio-Pydantic-Konflikt gesperrt.

[ComfyUI-GGUF](tools/comfyui-gguf.md): city96/ComfyUI-GGUF,
Commit `6ea2651e7df66d7585f6ffee804b20e92fb38b8a`, privater Checkout mit
verwaltetem custom_nodes-Link. Ohne Docker; fehlendes gguf kommt aus PyPI
in die vorhandene ComfyUI-venv, bestehende Paketversionen bleiben fixiert.

[Wan21](tools/wan21.md): GitHub Wan-Video/Wan2.1, Commit
`9737cba9c1c3c4d04b33fcad41c111989865d315`, ohne Docker. Standard nur Quellen;
GPU-Pakete doppelt opt-in aus PyPI/PyTorch, Modellgewichte separat. Keine
automatische Inferenz oder Treiberinstallation.

Qwen_Desktop und Qwen_Code: [offizieller Code](https://github.com/QwenLM/qwen-code),
[Desktop-Releases](https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest).
[Windows-Einstieg](tools/qwen-desktop-windows.md), kein Community-Web-Wrapper.
[Qwen_Code CLI Source-Build](tools/qwen-code.md): v0.25.1, Commit
`c1a8218f38203e272e6e965778ed6a2795cfeed7`, pnpm 11.24.0/Corepack,
Node 22.x; keine Container-, Login- oder Agenteninitialisierung.
[Cline/Wan/GGUF/Wrapper/SUPIR/FILM-Quellen](media_studio/HYBRID_MODELS_AND_WAN.md).

[Cline-VSIX](tools/cline.md): offizielles GitHub-Release v4.1.25,
fester SHA-256-Hash und Extension-Metadatenpruefung. Kein Docker/Marketplace-
Download; Paketbereitstellung ist getrennt von der manuellen Editorinstallation.

Defensiver Audio-Pfad: [pyannote/pyannote-audio](https://github.com/pyannote/pyannote-audio),
[Rikorose/DeepFilterNet](https://github.com/Rikorose/DeepFilterNet),
[facebookresearch/audioseal](https://github.com/facebookresearch/audioseal).
[AudioSeal](tools/audioseal.md) hat einen gepinnten GitHub-Paketbuild mit
privatem PyTorch-CPU-Pfad, ohne Modelle/Audioaktionen. [DeepFilterNet](tools/deepfilternet.md) hat einen
gepinnten nativen GitHub-Rust-CPU-Build mit eingebettetem Modell und ohne Docker.
Pyannote_Audio hat inzwischen den
oben verlinkten optionalen GitHub-Source-/CPU-Paketpfad ohne Modelle/Audioaktionen.
[Fachliche Grenzen und bestehende Tools](media_studio/AUDIO_DEEPFAKE_REVIEW.md);
Demucs-Meta-Repo archiviert, keine automatische Fork-Migration.

[Social-Avatar-Quellen](media_studio/SOCIAL_AVATAR_AUTOMATION.md): CogVideoX,
LTX-Video, SD.Next, Pinokio, Windmill, TGI, fal-SDK und Google-GenAI-SDK.

[TGI](tools/tgi.md) besitzt inzwischen einen gepinnten GitHub-Quellinstaller
und optionalen nativen Launcher-Build ohne Docker. Das ist noch keine
vollstaendige Inferenzlaufzeit. [Pinokio](tools/pinokio.md) hat einen nativen
GitHub-Release-Assistenten v8.2.0 mit manueller Desktop-Installation, ohne Docker.
Die anderen Social-Kandidaten bleiben documentation-first.
Ausnahme [SD.Next](tools/sdnext.md): gepinnter GitHub-Checkout und private
Python-venv ohne Docker, noch keine betriebsbereite Inferenzlaufzeit.
[Windmill](tools/windmill.md): GitHub v1.837.0, gepinnte Quellen, optional
hashgepruefte Linux-amd64-Datei. Release-CE-Bedingungen von AGPL-Source trennen;
kein Docker und kein automatischer Datenbank-/Server-/Workerstart.
[Fal_Client](tools/fal-client.md): fal-ai/fal, Tag fal_client_v1.0.3,
Installation nur aus projects/fal_client in privater venv; PyPI nur fuer
Build-/Runtime-Abhaengigkeiten. Kein Docker, kein fal-Deployment-SDK/Cloudtest.
[Veo_API](tools/veo-api.md): googleapis/python-genai v2.31.0 aus GitHub in
privater venv, Abhaengigkeiten als PyPI-Wheels. Kein Docker/SDK-Import/ADC-
Login/Cloudtest; Veo selbst bleibt externes Modell.
SDK auf GitHub bedeutet nicht, dass Veo/fal lokal selbsthostbar sind.

Dataset-Werkzeuge: HF_Datasets hat einen [gepinnten GitHub-Basispaketinstaller](tools/hf-datasets.md),
[HF_Hub](tools/hf-hub.md) hat ebenfalls einen eigenen GitHub-Installer ohne
Docker/Transfers; nur Video2Dataset bleibt planned:
[huggingface/datasets](https://github.com/huggingface/datasets),
[huggingface/huggingface_hub](https://github.com/huggingface/huggingface_hub),
[iejMac/video2dataset](https://github.com/iejMac/video2dataset).
[Quellen-/Rechte-/Budgetleitfaden](media_studio/VIDEO_TRAINING_DATASETS.md).

[Audio-/Video-Quellen](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md):
20 Kandidaten mit direkten Upstream-Links. [ViDubb](tools/vidubb.md) besitzt
einen gepinnten GitHub-Sparse-Quellinstaller ohne Docker; Laufzeit noch offen.
Die anderen 19 Kandidaten bleiben planned/documentation-first.
Karaoke_Formats ist eigene Repository-Logik: optionaler privater CLI-Starter
aus dem vorhandenen GitHub-Setup-Checkout mit SHA-256-Pruefung, kein weiterer
Clone, Docker oder fremdes Paket. Nach Setup-Updates den Tool-Starter aktualisieren.

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
Optionaler experimental Source-Build ohne Docker: gepinnter GitHub-Checkout,
pnpm 10.28.1 mit Frozen-Lockfile, Node 22.x. Paket-/native Build-Abhaengigkeiten
werden bei expliziter Installation zusaetzlich geladen. Kein Agentenstart,
Wallet-Zugriff oder apt-Installer; vollstaendiger Supply-Chain-Audit bleibt offen.
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

