# Profil: Visual_Creator

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Visual_Creator.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Visual_Creator.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Kreativprofil für Bild- und Video-Generierung, Prompting und Asset-Produktion.

## Installierter Stack

- Basis: `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - FFmpeg systemweit

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- stable-diffusion-webui
- comfyui
- AnimateDiff
- SVD
- Runway API
- RealESRGAN oder andere Upscaler

## Verantwortlichkeiten

- Bildprompts und Szenenbeschreibungen erzeugen
- Video- und Animationspipelines vorbereiten
- Style-Transfer und Upscaling planen
- Thumbnails und Content-Assets produzieren

## Verfügbare Kommandos

```bash
scripts/tools/ffmpeg_install.sh
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
- `FFmpeg` ist der aktuell einzige direkt vorhandene Medienbaustein aus der Quelle.
- Die eigentlichen Bild- und Video-Generatoren fehlen im Setup derzeit noch.

## Vergleich

### ✅ In Sync

- `ffmpeg` aus der Quelle ist bereits als Tool vorhanden.

### ⚠ Missing in Setup

- `stable-diffusion-webui`, `comfyui`, `AnimateDiff`, `SVD`, `Runway API` und `RealESRGAN` fehlen noch als installierbare Module.
- Es gibt noch kein dediziertes Visual-Profilskript.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Das Profil ist aktuell eher planerisch und prompt-orientiert als produktionsfertig für lokale Bild-/Video-Generierung.
