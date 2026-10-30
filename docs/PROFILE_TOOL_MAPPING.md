# Profile Tool Mapping

## Getrennte Coding-Agenten

`Claude_Code_Agent` -> `claude_code`. `Gemini_Code_Agent` -> `gemini_cli`. `Jarvis_Core` -> keine
eigene Coding-CLI; Offline-Routingplan. `Ollama_Coder` -> `ollama`, `aider`. `OpenClaw_Runtime` ->
`openclaw`. `Kubernetes_Agent_Scaling` -> `k3s`. `MCP_Tool_Layer` -> `mcp_filesystem`, `mcp_git`.
[GitHub-Quellpfade und Runtime-Grenzen](agents/coding-agent-profiles.md).

`Agentic_Coding_Local_First` -> optional `qwen_desktop` (Windows-GUI), `qwen_code` (CLI), `cline`;
jeweils eigene Freigabe, keine Sammelinstallation.
[Qwen-Windows-Anleitung](tools/qwen-desktop-windows.md). `AI_Influencer` -> optional `wan21`,
`comfyui_gguf`, `wanvideo_wrapper`, `supir`, `film`;
[Kompatibilitaetsgrenzen](media_studio/HYBRID_MODELS_AND_WAN.md).

`Audio_Postproduction_Local_First` -> optional `pyannote_audio`, `deepfilternet`, `audioseal` fuer
getrennte defensive Analyse-/Redaktionsschritte.
[Audio-Review](media_studio/AUDIO_DEEPFAKE_REVIEW.md); keine automatische Installation.

`AI_Influencer` -> vorhandene TTS/Avatar/FFmpeg-Bausteine; optional `cogvideox`, `ltx_video`,
`comfyui`, ein Orchestrator aus `n8n`/`activepieces`/`huginn`/`windmill`. `fal_client` und `veo_api`
nur gesperrte Cloud-Kandidaten. [Social-Workflow](media_studio/SOCIAL_AVATAR_AUTOMATION.md), kein
Autopublishing.

`Dataset_Curator` -> bestehende Dokumenttools plus optional `hf_datasets`, `hf_hub`, `video2dataset`
(planned). [Video-Datenpfad](media_studio/VIDEO_TRAINING_DATASETS.md); keine automatische
Installation.

`Audio_Postproduction_Local_First` -> `ffmpeg`, `faster_whisper`, `demucs`, `subtitleedit`,
`karaoke_formats`; Erweiterungen und Ressourcen im
[Profil](Profile/Audio_Postproduction_Local_First.md). Keine automatische Toolinstallation.

## Next-Level Mapping

`Agentic_Coding_Local_First` -> ein Coding-Client (`aider` als Beispiel), optional `ollama`;
Alternativen `continue_dev`, `opencode`, `openhands`. Orchestrierung
`langgraph`/`crewai`/`agent_framework` separat pruefen. `autogen` im Maintenance Mode, `automaton`
nur Forschungsreferenz. Keine Sammelinstallation dieser Tools.

`Personalakten_Local_First` -> `personnel_documents`, optional `paperless_ngx`, `ollama`,
`tesseract`; Profil geplant, keine automatische Abhaengigkeitsinstallation. Paperless-Container
bringt OCR mit; keine doppelte Tesseract-Installation notwendig.

`Web3_Crypto_Agent` -> `automaton` nur als optionale Forschungsreferenz (Source-Build
`experimental`), kein Eintrag als automatisch installierte Profilabhaengigkeit. Runtime/Signer
gesperrt.

`Embedded_Debug_HIL` -> `embedded_debug_hil`: Offline-Register-Snapshots, GitHub-Kandidaten
OpenOCD/pyOCD/pygdbmi; Live-Hardware-Adapter weiterhin `planned`.

| Profil                    | Zweck                                | Tools                          | Risiko | Ressourcen | Status  | Zielhost        |
| ------------------------- | ------------------------------------ | ------------------------------ | ------ | ---------- | ------- | --------------- |
| Job_Queue_Orchestrator    | Jobs seriell/limitiert ausfuehren    | job_queue, Redis/RQ optional   | medium | low        | planned | WSL2/MiniPC/VPS |
| Resource_Governor         | RAM/CPU/Disk/GPU schuetzen           | check_resource_budget          | low    | low        | planned | alle            |
| Secrets_Audit             | Secrets finden ohne Werte auszugeben | gitleaks, trufflehog           | medium | low        | planned | alle            |
| DDoS_Protection_HE_Oracle | HE/Oracle/Firewall absichern         | CrowdSec, Fail2ban, UFW        | high   | medium     | planned | Oracle VPS      |
| K3s_HomeCluster_Manager   | K3s Homecluster planen               | k3s, helm, kubectl             | high   | heavy      | planned | Home Server/K8s |
| Voice_Studio_Whisper_TTS  | lokale STT/TTS                       | Piper, Whisper, Coqui optional | medium | medium     | planned | MiniPC/GPU      |

Hinweis: Diese Datei ist eine kompakte Uebersicht. Die maschinenlesbare Quelle bleibt
`config/profiles.yml`.
