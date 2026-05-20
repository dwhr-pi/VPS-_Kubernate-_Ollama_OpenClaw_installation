# Blender AI Operator

## Aufgabe

Der Blender AI Operator automatisiert Blender Headless fuer Cleanup, Retopology, UV Unwrap, Texture Baking, Rigging, Animation und Export.

## Tools

- Blender Python API.
- OpenClaw fuer Jobsteuerung.
- ComfyUI fuer Vorstufen.
- FFmpeg fuer Preview-Render und Turntables.

## GPU und VRAM

- Blender-Konvertierung funktioniert oft CPU-only.
- GPU lohnt sich fuer Cycles, Baking und Preview-Rendering.
- RTX/OptiX bevorzugt, CUDA-Treiber aktuell halten.

## Beispielprompt

```text
Nimm das GLB aus dem letzten Hunyuan3D-Job, bereinige Normalen, reduziere auf 35k Tris, erstelle UVs und exportiere GLB plus FBX.
```

## Workflow

1. Asset aus `assets` oder `3d` laden.
2. Cleanup und Modifier anwenden.
3. UV/Texture-Bake durchfuehren.
4. In `exports` speichern.
5. Log und Preview erzeugen.

## Kubernetes

Blender laeuft gut als stateless Worker, solange Assets und Outputs auf gemeinsamem Storage liegen.

