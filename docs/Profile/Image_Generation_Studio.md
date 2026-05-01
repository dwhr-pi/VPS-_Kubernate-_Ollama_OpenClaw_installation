# Profil: Image_Generation_Studio

## Zweck
Lokale Bild- und Asset-Generierung für SDXL, Flux-nahe Workflows, LoRAs und Upscaling.

## Use Cases
- Bildgenerierung
- LoRA-Verwaltung
- Upscaling
- Prompt-Bibliotheken

## Enthaltene Tools
- ComfyUI
- Stable Diffusion WebUI Forge
- ControlNet
- GFPGAN
- Rembg
- RealESRGAN

## Installation
```bash
scripts/profiles/Image_Generation_Studio_install.sh
```

## Ports
- 7860
- 8188

## Modelle
- SDXL
- Flux vorbereitet
- ControlNet

## Abhängigkeiten
- GPU empfohlen

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel bis hoch
- RAM: 16 GB+
- Storage: 40 GB+

## Sicherheitshinweise
- Modelldownloads nur aus vertrauenswürdigen Quellen

## Start / Stop / Status Befehle
```bash
nvidia-smi || true
```

## Test-Command
```bash
bash scripts/profiles/Image_Generation_Studio_install.sh
```

## Deinstallation
```bash
scripts/profiles/Image_Generation_Studio_uninstall.sh
```
