# GPU_Render_Node

## Zweck
GPU-Knoten fuer Rendering, ComfyUI, Video und Modellinferenz planen.

## Typische Aufgaben
- VRAM/RAM/SSD-Bedarf abschaetzen.
- GPU-Tools von CPU-/MiniPC-Tools trennen.
- Monitoring und Temperaturhinweise definieren.

## Empfohlene Tools
ComfyUI, Blender, FFmpeg, Prometheus, Grafana, Node Exporter, NVIDIA/ROCm-Tools optional.

## Hardwarebedarf und Status
Hardware: GPU, schwer. Status: experimental. Installationsart: GPU-Workstation, Kubernetes spaeter.

## Datenschutz und Sicherheit
Remote-GPU-UIs nur ueber Tailnet/Auth. Modelle und Outputs nicht automatisch teilen.

## Beispiel-Prompt
`Plane einen GPU-Render-Node fuer ComfyUI und Blender mit Speicher- und Monitoring-Grenzen.`

## Modelle
Ollama: `llama3.1:8b` fuer Planung. Media-/LLM-Modelle nach VRAM.

## Grenzen
Nicht fuer kleine VPS oder knappen WSL2-Speicher geeignet.
