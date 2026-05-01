# Profil: Video_Generation_Studio

## Zweck
Lokale KI-Videopipeline für ComfyUI Video Nodes, AnimateDiff, SVD und FFmpeg-gestützte Render-Workflows.

## Use Cases
- kurze KI-Videos
- Render-Queue
- Batch-Rendering
- Upscaling

## Enthaltene Tools
- ComfyUI
- AnimateDiff
- SVD
- FFmpeg
- RealESRGAN

## Installation
```bash
scripts/profiles/Video_Generation_Studio_install.sh
```

## Ports
- 8188
- 7860 optional

## Modelle
- SVD
- AnimateDiff
- SDXL-nahe Videoflows

## Abhängigkeiten
- starke GPU empfohlen

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: hoch
- RAM: 24 GB+
- Storage: 60 GB+

## Sicherheitshinweise
- hohe VRAM-Last
- lange Renderjobs nur mit genügend freiem Speicher

## Start / Stop / Status Befehle
```bash
nvidia-smi || true
```

## Test-Command
```bash
bash scripts/profiles/Video_Generation_Studio_install.sh
```

## Deinstallation
```bash
scripts/profiles/Video_Generation_Studio_uninstall.sh
```
