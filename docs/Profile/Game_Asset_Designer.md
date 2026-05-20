# Game Asset Designer

## Aufgabe

Der Game Asset Designer erzeugt spieloptimierte Assets mit LOD, sauberem Pivot, PBR-Texturen und Export fuer Unity, Unreal, Godot oder VRChat.

## Empfohlene Modelle

- Hunyuan3D 2.1 fuer finale Assets.
- TripoSR fuer schnelle Entwuerfe aus Konzeptbildern.
- Ollama fuer Namenskonventionen, Asset Sheets und QA.

## GPU und VRAM

- 12 GB VRAM fuer Prototypen.
- 16-24 GB VRAM fuer produktivere Workflows.
- Multi-GPU spaeter als parallele Asset-Farm, nicht als Pflicht.

## Beispielprompt

```text
Baue ein game-ready Sci-Fi-Werkzeug als GLB und FBX. Ziel: mid-poly, PBR, 2K Texturen, klarer Ursprung, keine losen Mesh-Inseln.
```

## Workflow

1. Prompt Planner erstellt Asset-Spec.
2. ComfyUI erzeugt Referenz und Mesh.
3. Blender decimated, erzeugt UVs und prueft Scale.
4. Export nach GLB/FBX/OBJ.
5. Optional Import-Test in Godot/Unity/Unreal.

## Speicherbedarf

50 GB fuer Basis, 200+ GB wenn viele Textur- und Modellvarianten gespeichert werden.

## Kubernetes

Game-Asset-Jobs lassen sich hervorragend job-basiert skalieren: jeder Worker rendert oder konvertiert ein Asset.

