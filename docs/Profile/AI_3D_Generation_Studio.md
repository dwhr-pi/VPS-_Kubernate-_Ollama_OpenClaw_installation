# AI 3D Generation Studio

Dieses Profil erweitert das Ultimate-KI-Setup zu einem lokalen Open-Source AI-3D-Studio fuer Game Assets, CAD-Prototypen, Charaktere, Produktvisualisierung und spaetere Render-Farmen. Es verbindet Ollama, OpenClaw, ComfyUI, Blender, Hunyuan3D, TripoSR und FFmpeg zu einer modularen Pipeline.

## Zweck

- Text oder Bild in 3D-Assets umwandeln.
- Meshes bereinigen, optimieren, texturieren und exportieren.
- Blender headless fuer Batch-Rendering und Asset-Konvertierung nutzen.
- ComfyUI als visuelle Workflow-Schicht fuer 3D-Pipelines verwenden.
- OpenClaw-Agenten fuer Planung, Qualitaetskontrolle und Automatisierung einsetzen.
- Kubernetes- und Multi-GPU-Skalierung vorbereiten, ohne Docker-Zwang im lokalen Setup.

## Bausteine

| Komponente | Aufgabe |
| --- | --- |
| Ollama | Lokale Promptplanung, Asset-Briefings, QA-Checklisten |
| OpenClaw | Agent-Orchestrierung, Batch-Jobs, Toolsteuerung |
| ComfyUI | Visuelle 3D-/Bild-/Textur-Workflows |
| Hunyuan3D 2.1 | Image/Text zu hochwertigem Mesh mit PBR-Texturen |
| TripoSR | Schnelle Single-Image-Rekonstruktion und Mesh-Prototyping |
| Blender | Cleanup, UV, Retopo, Baking, Rigging, Export |
| FFmpeg | Turntables, Preview-Videos, Social-Media-Clips |
| n8n optional | Queue, Benachrichtigung, Export-Automation |

## Hardware

- CPU-only: nur Setup, Prompting, kleine Tests und Doku-Workflows.
- 8-12 GB VRAM: einfache TripoSR-/kleine ComfyUI-Workflows.
- 16-24 GB VRAM: realistische lokale 3D-Workflows, kleinere Hunyuan3D-Pipelines.
- 24-32+ GB VRAM: Hunyuan3D Shape + Texture, groessere Texturen, Batchjobs.
- Multi-GPU/Kubernetes: spaeter fuer Render Queue, Asset Farm und parallele Blender-Jobs.

Hunyuan3D 2.1 nennt als Orientierung ca. 10 GB VRAM fuer Shape, 21 GB fuer Textur und 29 GB fuer Shape+Textur. Das ist ein wichtiger Planungswert fuer RTX-Workstations und VPS-GPU-Nodes.

## Architektur

```mermaid
flowchart LR
  A["User Prompt / Bild / Referenz"] --> B["OpenClaw Agent"]
  B --> C["Prompt Planner"]
  C --> D["Asset Brief / Style Bible"]
  D --> E["ComfyUI 3D Pipeline"]
  E --> F["Hunyuan3D / TripoSR"]
  F --> G["Blender Cleanup"]
  G --> H["UV / Retopo / Texture Baking"]
  H --> I["Rigging / Animation optional"]
  I --> J["Export: STL / OBJ / FBX / GLB / USDZ / Blend"]
  J --> K["n8n Queue / Asset Browser / Archiv"]
```

## Einsatzgebiete

- Text-to-3D und Image-to-3D.
- AI NPC Generator und VRM-/Character-Prototypen.
- Game Assets fuer Unity, Unreal, Godot und VRChat.
- CAD-nahe Prototypen, STL-Export und 3D-Druck-Vorbereitung.
- Produktvisualisierung, Packshots und WebGL-Modelle.
- Musikvideo- und Cyberpunk-Szenengenerator.
- Terrain-/City-Generator als spaetere Erweiterung.
- AI Voice zu Lippenanimation als spaetere Erweiterung.

## ComfyUI 3D Pipelines

Empfohlene Node-Quellen:

- Hunyuan3D 2.1 Community Nodes: `visualbruno/ComfyUI-Hunyuan3d-2-1`
- TripoSR Nodes: `flowtyone/ComfyUI-Flowty-TripoSR`
- Tripo API/Comfy Nodes: `VAST-AI-Research/ComfyUI-Tripo`

Geplante Beispiel-Workflows:

- `text_to_3d.json`
- `image_to_3d.json`
- `ai_character_pipeline.json`
- `game_asset_pipeline.json`
- `cad_prototype_pipeline.json`

Die JSON-Dateien sind bewusst als Startvorlagen gedacht. Echte Modellpfade muessen lokal an die eigene ComfyUI-Installation angepasst werden.

## Blender Automation

Blender wird als Headless-Worker fuer wiederholbare Schritte genutzt:

- Mesh Cleanup und Normalen-Korrektur.
- Decimation/Retopology fuer Game Assets.
- UV Unwrap und Texture Baking.
- Export nach STL, OBJ, FBX, GLB, USDZ und Blend.
- Batch-Verarbeitung aus einer Render Queue.
- GPU Rendering ueber Cycles, wenn CUDA/OptiX verfuegbar ist.

## Kubernetes Skalierung

Ein spaeteres Cluster kann so geschnitten werden:

- Node 1: Ollama und Promptplanung.
- Node 2: ComfyUI 3D Workflows.
- Node 3: Blender Headless Worker.
- Node 4: Video Renderer und FFmpeg.
- Gemeinsamer Speicher: MinIO/NFS fuer Assets, Renders, Texturen und Exporte.

## Manuelle Modell-Downloads

Keine grossen Modelle werden automatisch geladen. Manuell einplanen:

- Hunyuan3D-Shape-v2-1 und Hunyuan3D-Paint-v2-1 von Hugging Face/Tencent.
- TripoSR Checkpoints.
- Stable Diffusion/FLUX Basismodelle fuer Referenzbilder und Texturen.
- Optionale Control-/Depth-/Normal-Modelle fuer ComfyUI.

## Erster Test

```bash
bash scripts/tools/ai_3d_studio_install.sh
bash scripts/tools/hunyuan3d_install.sh
bash scripts/tools/triposr_install.sh
cp config/ai3d.env.example .env.ai3d
```

Danach ComfyUI starten, Node-Installation bewusst aktivieren und ein kleines Image-to-3D-Experiment mit einem lokal gespeicherten Referenzbild ausfuehren.
