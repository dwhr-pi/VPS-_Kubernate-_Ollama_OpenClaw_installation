# Profil: Image_Generation

## Zweck
Lokale Bildgenerierung mit GPU-Prüfung, Modellordnern und vorbereiteten Flux/SDXL/ControlNet-Pfaden.

## Use Cases
- ComfyUI-Workflows
- Stable Diffusion Forge
- ControlNet
- lokale Asset-Erstellung

## Enthaltene Tools
- ComfyUI
- Stable Diffusion WebUI Forge
- ControlNet
- FFmpeg

## Installation
```bash
scripts/profiles/Image_Generation_install.sh
```

## Ports
- 7860 typisch für SD-WebUI
- 8188 typisch für ComfyUI

## Modelle
- SDXL
- Flux vorbereitbar
- ControlNet-Modelle optional

## Abhängigkeiten
- GPU empfohlen

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 16 GB
- Storage: ab 40 GB

## Sicherheitshinweise
- Modelldownloads prüfen
- WebUIs nur mit Auth oder lokal betreiben

## Start / Stop / Status Befehle
```bash
nvidia-smi || true
```

## Test-Command
```bash
bash scripts/profiles/Image_Generation_install.sh
```

## Deinstallation
```bash
scripts/profiles/Image_Generation_uninstall.sh
```
