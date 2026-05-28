# Recommended GPU Setup

Ziel: Medien-KI, lokale Inferenz und Render-Workflows auf GPU-Hardware.

## Empfohlen

- GPU_Render_Node als Planungsprofil
- ComfyUI nur nach VRAM-/Modellordner-Plan
- FFmpeg, Whisper.cpp, Piper zuerst
- Blender/Forge/vLLM nur einzeln installieren
- Prometheus/Grafana/Netdata fuer Last und Temperatur

## Nicht empfohlen

- GPU-Stacks in knapper WSL2 ohne ausreichend Windows-C:-Speicher.
- Mehrere grosse Modellfamilien parallel ohne Cleanup-Plan.
- Remote-GPU-UIs ohne Tailscale/Auth.

## Mindestcheck

```bash
bash scripts/system_profile_detect.sh
nvidia-smi || true
df -h
```
