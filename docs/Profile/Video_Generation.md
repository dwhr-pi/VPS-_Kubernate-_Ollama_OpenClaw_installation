# Profil: Video_Generation

## Zweck
Profil für lokale Video-KI, Musikvideo-Pipelines, Upscaling und Frame-Interpolation.

## Use Cases
- kurze KI-Videos
- Musikvideo-Experimente
- Rendering, Upscaling und Interpolation

## Enthaltene Tools
- ComfyUI
- Stable Diffusion WebUI Forge
- Stable Video Diffusion
- AnimateDiff
- RIFE
- Real-ESRGAN
- FFmpeg
- Blender
- ControlNet

## Installation
```bash
scripts/profiles/Video_Generation_install.sh
```

## Ports
- 8188 ComfyUI
- 7860 Stable Diffusion WebUI Forge

## Modelle
- SVD
- AnimateDiff-kompatible Modelle
- optional Wan/weitere Video-Modelle nur manuell

## Abhängigkeiten
- GPU dringend empfohlen
- ausreichend VRAM und SSD

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: hoch
- RAM: ab 16 GB
- Storage: ab 60 GB

## Sicherheitshinweise
- schwere Medien-Stacks nicht blind auf kleinen Systemen installieren
- Modelle und Assets nur aus vertrauenswürdigen Quellen laden

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '7860|8188' || true
```

## Test-Command
```bash
bash scripts/profiles/Video_Generation_install.sh
```

## Deinstallation
```bash
scripts/profiles/Video_Generation_uninstall.sh
```
