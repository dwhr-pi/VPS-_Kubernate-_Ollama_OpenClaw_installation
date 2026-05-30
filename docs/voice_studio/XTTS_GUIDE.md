# XTTS GUIDE

Leitfaden fuer xtts guide. Enthalten: Zweck, Setup-Hinweise, Sicherheitsregeln, Speicherorte unter `~/.openclaw_ultimate_user_data/voice_studio/` und keine Rohdaten im Repo.

## Python-Kompatibilitaet

XTTS ueber Coqui TTS ist aktuell kein guter Default fuer frisches Ubuntu 24.04, weil Ubuntu 24.04 `python3` als Python 3.12 bereitstellt. Das Coqui-PyPI-Paket `TTS==0.22.0` akzeptiert aber nur Python `>=3.9,<3.12`.

Vor jedem Installationsversuch muss ein kompatibles Python vorhanden sein:

```bash
python3.11 --version
python3.11 -m venv --help
```

Erlaubt sind Python 3.9, 3.10 oder 3.11 mit `venv`. Wenn nur Python 3.12 vorhanden ist, soll die Installation abbrechen. Stabiler Startpfad fuer lokale TTS bleibt Piper.

## Erwartetes Verhalten des Installers

Der Installer `scripts/tools/coqui_tts_install.sh` fuehrt eine Preflight-Pruefung aus und stoppt, bevor pip versucht, ein inkompatibles Paket zu installieren. Die Meldung `Kein kompatibles Python fuer Coqui_TTS gefunden` ist deshalb ein Schutz, kein Folgefehler.

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
