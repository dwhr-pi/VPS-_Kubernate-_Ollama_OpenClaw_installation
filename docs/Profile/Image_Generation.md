# Profil: Image_Generation

## Zweck
Profil für Bildgenerierung, UI-Assets, Icons, LoRA-Workflows und Upscaling.

## Use Cases
- Bilder und Assets
- SDXL-/Flux-nahe Workflows
- Upscaling und Freistellung

## Enthaltene Tools
- ComfyUI
- Stable Diffusion WebUI Forge
- Fooocus
- InvokeAI
- Real-ESRGAN
- ControlNet

## Installation
```bash
scripts/profiles/Image_Generation_install.sh
```

## Ports
- 8188 ComfyUI
- 7860 Stable Diffusion WebUI Forge

## Modelle
- SDXL
- Flux-nahe Workflows
- optionale LoRAs

## Abhängigkeiten
- GPU empfohlen
- Python

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel bis hoch
- RAM: ab 12 GB
- Storage: ab 40 GB

## Sicherheitshinweise
- große Modellordner können SSD schnell füllen
- optionale Heavy-Tools wie Fooocus/InvokeAI bewusst wählen

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '7860|8188' || true
```

## Test-Command
```bash
bash scripts/profiles/Image_Generation_install.sh
```

## Deinstallation
```bash
scripts/profiles/Image_Generation_uninstall.sh
```
