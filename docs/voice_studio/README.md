# Voice Studio

Strukturierter Einstieg fuer TTS, Voice-Cloning, Training, Dataset-Management und mehrsprachige Stimmen. Nur eigene oder freigegebene Stimmen verwenden.

## Startempfehlung: erst Piper, Coqui nur optional

Piper ist der stabile lokale Standardpfad fuer Text-to-Speech. Es ist schnell, CPU-tauglich und deutlich unproblematischer auf Ubuntu 24.04/WSL2.

Coqui TTS / XTTS bleibt `experimental`, weil das PyPI-Paket `TTS==0.22.0` Python `>=3.9,<3.12` benoetigt. Ubuntu 24.04 liefert standardmaessig Python 3.12; damit bricht die Installation korrekt vor dem `pip install` ab.

Der Installer prueft vor Installationsbeginn:

- kompatibles Python: `python3.9`, `python3.10` oder `python3.11` mit `venv`
- Linux-/WSL-Speicher
- Windows-Host-Speicher auf `C:` bei WSL
- vorhandene inkompatible Coqui-venv

Wenn kein kompatibles Python gefunden wird, ist das kein kaputtes Setup. Es bedeutet: Coqui ist fuer dieses System nicht freigegeben; nutze Piper oder installiere bewusst ein kompatibles Python ausserhalb des Standard-`python3`.

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
