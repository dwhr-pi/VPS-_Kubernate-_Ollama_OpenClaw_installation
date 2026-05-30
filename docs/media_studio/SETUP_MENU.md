# MEDIA STUDIO Setup-Menue

Vorgesehene Unterpunkte:

1. Voice Studio
2. AI Singer Studio
3. Choir Studio
4. Broadcasting Studio
5. Podcast Studio
6. Audiobook Studio
7. Avatar Studio
8. Film Studio
9. Dubbing Studio
10. Virtual Human Studio

Alle Punkte sind documentation-first. Schwere Installationen verlangen spaeter explizite Bestaetigung und Ressourcencheck.

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
