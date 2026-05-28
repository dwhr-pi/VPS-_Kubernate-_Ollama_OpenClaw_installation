# bild_video_generation

Status: `documentation-first`

## Zweck
Lokale Bild- und Video-KI mit ComfyUI, Stable Diffusion, FFmpeg und Blender sicher vorbereiten.

## Modelle
- Lokal/Ollama: `llama3.2:1b` fuer Prompt-Assistenz
- Optional extern: nur mit Kostenwarnung

## Tools
ComfyUI, Stable Diffusion WebUI Forge, InvokeAI, FFmpeg, Blender, ControlNet/OpenPose optional.

## Beispielprompt
`Erstelle einen ComfyUI-Workflow-Plan fuer ein lokales Bildprojekt mit Speicherbedarf, Modellordnern und Lizenzhinweisen.`

## Sicherheitsregeln
Keine grossen Modelle automatisch laden. Keine Cloud-APIs ohne Freigabe. Rechte an Bildern/Assets pruefen.

## Speicher-/Kostenkontrolle
GPU/Video-Workflows sind schwer. Fehlende Messwerte als `--:--:--` und `--.- MB` anzeigen.

## Workflows
Prompt -> Workflow -> lokales Rendering -> Metadaten/Lizenznotiz -> Export.

## OpenClaw-Agent
`media-visual-agent`: read-only Planung, lokale Datei-Ausgaben nur nach Freigabe.
