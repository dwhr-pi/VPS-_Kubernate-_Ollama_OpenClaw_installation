# Profil: Visual_Creator

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Visual_Creator.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Visual_Creator.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Kreativprofil für Bild- und Video-Generierung, Prompting und Asset-Produktion.

## Installierter Stack

- Basis: `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - FFmpeg systemweit
  - Stable_Diffusion_WebUI unter `/opt/stable-diffusion-webui`
  - ComfyUI unter `/opt/comfyui`
  - RealESRGAN unter `/opt/realesrgan`

## Dokumentierte zusätzliche Tools

Die zuvor zusätzlich beschriebenen Visual-Bausteine sind jetzt als Setup-Module vorhanden:

- `AnimateDiff`
- `SVD`
- `Runway_API`
- `Image_Upscaler_Pipeline`

## Verantwortlichkeiten

- Bildprompts und Szenenbeschreibungen erzeugen
- Video- und Animationspipelines vorbereiten
- Style-Transfer und Upscaling planen
- Thumbnails und Content-Assets produzieren

## Verfügbare Kommandos

```bash
scripts/tools/ffmpeg_install.sh
scripts/tools/stable_diffusion_webui_install.sh
scripts/tools/comfyui_install.sh
scripts/tools/realesrgan_install.sh
```

## Beispielprompts

### Bildgenerierung

```txt
Erstelle einen Bildprompt für ein cineastisches Thumbnail mit klarer Lichtstimmung,
starker Motivtrennung und hohem Kontrast. Gib zusätzlich Varianten für Social Media aus.
```

### Video-/Asset-Pipeline

```txt
Plane eine Pipeline für Bild -> Animation -> Export.
Nutze FFmpeg für Post-Processing und beschreibe, wo Stable Diffusion, ComfyUI oder Upscaling eingebunden werden sollten.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw für kreative Asset-Pipelines und Workflow-Orchestrierung.
- `FFmpeg` ist bereits vorhanden.
- `Stable_Diffusion_WebUI`, `ComfyUI` und `RealESRGAN` sind jetzt als installierbare Bausteine ergänzt.

## Vergleich

### ✅ In Sync

- `ffmpeg` aus der Quelle ist bereits als Tool vorhanden.
- `stable-diffusion-webui`, `comfyui` und `RealESRGAN` sind jetzt als installierbare Module vorhanden.

### ⚠ Missing in Setup

- Die zuvor fehlenden Visual- und Upscaling-Bausteine sind jetzt im Setup vorhanden.
- Offen bleibt nur Feintuning für vollständige Produktionspipelines mit echten Ziel-Renderwegen.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Das Profil ist aktuell eher planerisch und prompt-orientiert als produktionsfertig für lokale Bild-/Video-Generierung.
