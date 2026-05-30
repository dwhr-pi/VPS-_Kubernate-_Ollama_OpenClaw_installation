# PIPER GUIDE

Leitfaden fuer piper guide. Enthalten: Zweck, Setup-Hinweise, Sicherheitsregeln, Speicherorte unter `~/.openclaw_ultimate_user_data/voice_studio/` und keine Rohdaten im Repo.

## Warum Piper der Standard ist

Piper ist der empfohlene Start fuer lokale Sprachausgabe:

- CPU-tauglich
- schnell
- gut fuer Home Assistant
- weniger Python-/CUDA-Abhaengigkeiten
- geeignet fuer MiniPC, WSL2 und VPS

Wenn Coqui TTS unter Ubuntu 24.04 wegen Python 3.12 abbricht, ist Piper der richtige Fallback. Coqui/XTTS sollte erst getestet werden, wenn Python 3.9, 3.10 oder 3.11 mit `venv` verfuegbar ist.

## Ressourcenklassen

| Klasse | CPU | RAM | VRAM | Speicherplatz | Nutzung |
| --- | --- | --- | --- | --- | --- |
| MiniPC | 4-8 Kerne | 8-16 GB | keine | 20-100 GB | Planung, Piper, FFmpeg klein |
| RPi5 | ARM | 4-8 GB | keine | 10-50 GB | Orchestrierung, leichte TTS-Tests |
| Oracle VPS | 1-4 OCPU | 2-24 GB | keine | 50-200 GB | Control Node, Queue, n8n, Monitoring |
| Gaming PC | 6-16 Kerne | 16-64 GB | 8-24 GB | 200 GB+ | TTS, LipSync, Avatarvideo |
| RTX 5080 | stark | 32-128 GB | hoch | 500 GB+ | High-End Avatar, RVC, Render |
| Dual Xeon | viele Kerne | 64 GB+ | optional | 500 GB+ | Batch, FFmpeg, CPU-Rendering |
| Kubernetes Cluster | verteilt | verteilt | optional | verteilt | Worker-Queue und GPU-Nodes |
