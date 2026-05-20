# AI 3D Workflow Templates

Diese Datei beschreibt die geplanten ComfyUI- und Blender-Workflows. Die echten ComfyUI-JSON-Dateien muessen nach Installation der lokalen Nodes aus ComfyUI exportiert und an Modellpfade angepasst werden.

## text_to_3d.json

- OpenClaw erstellt Asset-Briefing.
- Ollama erzeugt Prompt, Negativprompt und Stilregeln.
- ComfyUI generiert Referenzbild oder Multiview-Ansichten.
- Hunyuan3D erzeugt Mesh und PBR-Texturen.
- Blender prueft Normalen, UVs, Scale und Export.

## image_to_3d.json

- Eingabe: Produktfoto, Charakterbild oder Skizze.
- TripoSR erzeugt schnellen Mesh-Prototyp.
- Optional Hunyuan3D fuer hochwertigere Geometrie/Textur.
- Blender erzeugt GLB/STL/FBX.

## ai_character_pipeline.json

- Character Sheet oder Prompt.
- Consistency-Regeln in OpenClaw.
- Mesh, Textur, optional Rig und Turntable.
- Export fuer Blender, Unity, Unreal oder VRChat.

## game_asset_pipeline.json

- Low-/Mid-Poly-Ziel definieren.
- Mesh-Decimation und LOD-Stufen.
- PBR-Texturen backen.
- GLB/FBX/OBJ exportieren.

## cad_prototype_pipeline.json

- Klare geometrische Beschreibung.
- Mesh auf Massstab, Wandstaerke und Druckbarkeit pruefen.
- STL-Export und optional Screenshot/Turntable.

