# Fachprofil: Render_Farm_GPU_Workstation

## Zweck

Profil fuer GPU-Workstations, mehrere GPUs, Blender, ComfyUI, Stable Diffusion, Video-Rendering und optionales Offloading ueber K3s oder andere Scheduler.

## Typische Aufgaben

- NVIDIA-/CUDA-/Container-Runtime pruefen
- VRAM-, RAM-, SSD- und Strombedarf schaetzen
- ComfyUI/Forge/Blender/FFmpeg-Workflows trennen
- Render- und Modelldaten sauber auslagern
- GPU-Profile nur nach Hardware-Erkennung anbieten

## Empfohlene Tools

- `comfyui`
- `stable_diffusion_webui_forge`
- `blender`
- `realesrgan`
- `ffmpeg`
- optional NVIDIA Container Toolkit und K3s/Nomad

## Sicherheit und Betrieb

GPU-Stacks sind ressourcenintensiv. Keine Installation im Minimalpfad. Vorher Speicherplatz, Treiber, Temperatur, Netzteil und Backup pruefen.

## Status

`experimental`.
