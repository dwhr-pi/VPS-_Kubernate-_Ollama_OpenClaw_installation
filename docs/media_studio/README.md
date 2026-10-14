# AI Media Production Studio

[Audio-Deepfakes: Original sichern, isolieren und Redaktion pruefen](AUDIO_DEEPFAKE_REVIEW.md).
Keine Herkunftsverschleierung oder automatische Echtheitsentscheidung.

[Social-Media-Avatare: lokaler Stack, optionale Cloud, Freigaben](SOCIAL_AVATAR_AUTOMATION.md).

## Einstieg: Hoerbuch, Dubbing und Karaoke

[Video-Trainingsdaten und Hugging Face](VIDEO_TRAINING_DATASETS.md):
vor Download zuerst Inferenz/Fine-Tuning unterscheiden, Rechte und Speicherbudget pruefen.

1. [Tools und reale Installationsgrenzen](AUDIO_VIDEO_TOOL_CATALOG.md)
2. [Hoerbuch, Synchronisation, SFX und Video-Bearbeitung](AUDIO_DUBBING_PRODUCTION_GUIDE.md)
3. [Karaoke, Untertitel und SRT/LRC-Konverter](KARAOKE_SUBTITLES_GUIDE.md)
4. [MIDI, Sampling und Audio-Plugins](MIDI_SAMPLING_GUIDE.md)

Die neuen KI-Kandidaten sind planned, keine fertig installierte Produktionssuite.

Zentrale Uebersicht fuer Audio, Video, Podcast, Hoerbuch, TV-Studio, YouTube- und Streaming-Pipelines. Schwere Tools bleiben planned und starten nie automatisch.

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
