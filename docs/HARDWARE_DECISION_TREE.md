# Hardware Decision Tree

## 1. WSL2 oder nativer Linux-Host?

- WSL2: Windows-C:-Speicher immer mitpruefen, Docker/kind/Airbyte/ComfyUI vorsichtig.
- Nativer Linux-PC: systemd/Docker meist stabiler, trotzdem Speicherwache nutzen.
- VPS: keine privaten Admin-UIs offen, Tailscale/cloudflared bevorzugen.
- Raspberry Pi: nur leichte Dienste, keine GPU-/Airbyte-/vLLM-Pfade.

## 2. RAM

- Unter 8 GB: nur Minimalsetup, Doku, kleine Tools, keine schweren Docker-Stacks.
- 8-16 GB: lokale LLMs klein, RAG leicht, Monitoring moderat.
- 16-32 GB: fortgeschrittene lokale Profile, aber schwere Tools einzeln.
- Ab 32 GB: Airbyte/K3s/mehrere Dienste moeglich, trotzdem nicht parallel installieren.

## 3. Speicher

- Unter 20 GB frei: keine neuen schweren Installationen.
- 20-50 GB frei: nur einzelne mittlere Tools, Cleanup zuerst.
- 50-100 GB frei: RAG, Monitoring, Office und kleine Modelle gut moeglich.
- Ab 100 GB frei: Medien/GPU/Containerpfade realistischer.

## 4. GPU

- Keine GPU: keine ComfyUI-/Forge-/vLLM-/Video-Stacks als Default.
- Kleine GPU: Bild/Audio testen, Video vorsichtig.
- Grosse GPU: GPU_Render_Node oder Render_Farm erst mit Monitoring und Modellordner-Plan.

## 5. Empfohlener naechster Befehl

```bash
bash scripts/system_profile_detect.sh
```
