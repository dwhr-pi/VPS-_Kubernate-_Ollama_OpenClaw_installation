# Setup Health Review

Stand: 2026-05-28

## Stable

- Basisstruktur: `install.sh`, `setup_ultimate.sh`, externe Userdaten unter `~/.openclaw_ultimate_user_data`.
- Leichte CLI-/Prueftools: Gitleaks, Trivy, ShellCheck, shfmt, Restic/Rclone, GitHub CLI.
- Lokale Kernpfade: Ollama, OpenClaw, Open WebUI, Qdrant/ChromaDB, Uptime Kuma, sichere Cleanup-Trockenlaeufe.

## Beta

- RAG-/Dokumentenprofile mit Paperless-ngx, Stirling PDF, Apache Tika, Docling und Pandoc.
- Monitoring mit Grafana, Prometheus, Loki, Netdata, Healthchecks.
- Model Gateway mit LiteLLM, Langfuse/OpenLIT und lokalen Ollama-Modellen.

## Experimental

- Airbyte via `abctl`/kind, Kubernetes/K3s, vLLM, AutoGPT, OpenHands.
- ComfyUI, Stable Diffusion Forge, Video-/Render-/GPU-Profile.
- Voice Clone/Coqui TTS, Multi-Agent-Router, Browser-Agenten, Robotik/Smart-Home-Aktionen.

## Documentation-first

- Neue Dachprofile wie `LLMOps_Control_Center`, `Storage_Cleanup_Manager`, `WSL2_Recovery_Doctor`, `ComfyUI_Workflow_Studio`.
- Android-/MobSF-/Frida-/Browserless-/Headscale-Pfade bleiben geplant oder dokumentiert, bis Installer, Healthchecks und Sicherheitsgates stabil sind.

## Ueberschneidungen

| Gruppe | Hauptprofil | Alias/Bausteine |
|---|---|---|
| Bild | `Image_Generation_Studio` | `Image_Generation`, `Visual_Creator` |
| Video | `Video_Generation_Studio` | `Video_Generation`, `Video_Generation_ComfyUI_Wan` als Spezialprofil |
| Security | `Security_DevSecOps`, `Cyber_Security_AI`, `Ethical_HackerGPT` | DevSecOps = Code/Container, Cyber = defensive Analyse, Ethical = controlled/autorisiert |
| Knowledge | `Personal_Memory_Knowledge_OS` | `Personal_Knowledge_Memory`, `Memory_Import_Export`, `Knowledge_Librarian` |
| Voice | `Voice_Clone_TTS_Studio` | `Voice_Clone_TTS_Lab`, `Voice_Command_Center`, `Voice_Transcription_Callcenter` |

## Nicht automatisch installieren

Airbyte, Activepieces, AutoGPT, OpenHands, n8n, Nextcloud, MobSF, Browserless, ComfyUI, Forge, vLLM, K3s/Kubernetes, Android-SDK/Gradle-Grosspfade und Coqui TTS. Diese Tools brauchen explizite Zustimmung, Speicher-/RAM-Pruefung und klare Rollback-Hinweise.
