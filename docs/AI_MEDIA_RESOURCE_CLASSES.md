# AI Media Production Ressourcenklassen

| Klasse | Unterstuetzte Funktionen | Modelle/Tools | Speicher/GPU | Geschwindigkeit |
| --- | --- | --- | --- | --- |
| MiniPC | Planung, Skripte, Piper, kleine FFmpeg-Jobs | Piper, Kokoro optional | 8-16 GB RAM, keine GPU | langsam bis mittel |
| RPi5 | Orchestrierung, leichte TTS-Tests | Piper leicht | 4-8 GB RAM, keine GPU | langsam |
| Oracle VPS | Control Node, Queue, n8n, Newsroom-Planung | LLM remote/lokal klein | 2-16 GB RAM, keine GPU | gut fuer Steuerung |
| Gaming PC | TTS, LipSync, Avatarvideo | MuseTalk, LivePortrait, RVC | NVIDIA GPU empfohlen | gut |
| RTX 5080 | High-End Avatar, Singer, Render | SkyReels-A1, Hallo2, DiffSinger | viel VRAM | schnell |
| Dual Xeon | Batch-CPU, Schnitt, Transcoding | FFmpeg, Piper, Queue | viel RAM, CPU | gut fuer CPU-Batches |
| Kubernetes Cluster | Worker-Verteilung | Queue, GPU Nodes | je Node unterschiedlich | skalierbar |

## Installationsreihenfolge
1. Minimal: Piper, FFmpeg, Character Library, VoiceStudioAgent.
2. Empfohlen: Coqui/XTTS, Fish Speech oder MeloTTS optional, Job Queue, n8n-Workflows.
3. High-End: RVC, MuseTalk, LivePortrait, Hallo2, SkyReels-A1, DiffSinger nur auf GPU-Systemen.

