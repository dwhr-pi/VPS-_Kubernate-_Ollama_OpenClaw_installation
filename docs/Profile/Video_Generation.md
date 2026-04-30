# Profil: Video_Generation

## Zweck
Videogenerierung und Render-Pipelines mit ComfyUI-Video-Nodes, AnimateDiff und FFmpeg.

## Use Cases
- kurze KI-Videos
- AnimateDiff-Workflows
- Render-Queue und Frames

## Enthaltene Tools
- ComfyUI
- AnimateDiff
- Stable Diffusion WebUI Forge
- FFmpeg

## Installation
```bash
scripts/profiles/Video_Generation_install.sh
```

## Ports
- 7860
- 8188

## Modelle
- Stable Video Diffusion vorbereitet
- AnimateDiff optional

## Abhängigkeiten
- GPU
- hoher Speicherplatz

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: hoch
- RAM: ab 24 GB
- Storage: ab 60 GB

## Sicherheitshinweise
- VRAM und Disk vor Start prüfen
- Render-Ausgaben getrennt halten

## Start / Stop / Status Befehle
```bash
nvidia-smi || true
```

## Test-Command
```bash
bash scripts/profiles/Video_Generation_install.sh
```

## Deinstallation
```bash
scripts/profiles/Video_Generation_uninstall.sh
```
