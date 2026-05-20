# AI 3D Studio Dashboard

Das Dashboard ist als spaetere React/Tailwind/WebGL/Three.js-Oberflaeche geplant. Es soll keine Pflicht fuer das Basissetup sein, sondern eine Bedienebene fuer Render Queue, Asset Browser und Monitoring.

## Module

- Live GPU Monitoring mit VRAM, Temperatur und Auslastung.
- Render Queue mit Status, Dauer, Fehlerlog und Wiederaufnahme.
- Prompt History fuer Bild-, 3D- und Texturjobs.
- Asset Browser fuer STL, OBJ, FBX, GLB, USDZ und Blend.
- GLB Viewer via Three.js.
- STL Vorschau und 3D-Druck-Hinweise.
- Node Status fuer Ollama, OpenClaw, ComfyUI, Blender und Worker.
- Workflow Editor fuer ComfyUI- und Blender-Presets.

## API-Idee

```text
GET  /api/status
GET  /api/gpu
GET  /api/jobs
POST /api/jobs
GET  /api/assets
GET  /api/assets/:id/preview
POST /api/workflows/:id/run
```

## Umsetzungshinweise

- Frontend: React, Tailwind, Three.js.
- Backend: FastAPI oder Node.js, je nachdem was im Setup stabiler ist.
- Keine Secrets im Browser.
- Export-Downloads nur mit lokaler Auth oder internem Netz.

