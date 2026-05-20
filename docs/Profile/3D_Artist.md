# 3D Artist

## Aufgabe

Der 3D Artist erzeugt aus Prompts, Skizzen oder Referenzbildern stimmige 3D-Assets und bereitet sie fuer Blender, WebGL oder Game Engines vor.

## Empfohlene Modelle

- Ollama: `llama3.2:1b` fuer schnelle lokale Planung, groessere Modelle fuer Style Guides.
- 3D: Hunyuan3D 2.1 fuer hochwertige PBR-Assets, TripoSR fuer schnelle Bild-zu-Mesh-Entwuerfe.
- Bild/Textur: FLUX oder Stable Diffusion lokal ueber ComfyUI.

## GPU und Speicher

- Minimum: 8-12 GB VRAM fuer kleine Tests.
- Empfohlen: 16-24 GB VRAM.
- Hunyuan3D Shape+Texture kann Richtung 29 GB VRAM gehen.
- Speicherbedarf: 50-200 GB je nach Modell- und Asset-Sammlung.

## Beispielprompt

```text
Erstelle ein stilisiertes Cyberpunk-Marktstand-Asset als GLB, low-poly-tauglich, mit PBR-Materialien, klaren Neon-Akzenten und sauberem Pivot fuer Game Engine Import.
```

## Workflow

1. OpenClaw erstellt Briefing und Stilregeln.
2. ComfyUI generiert Referenzbilder.
3. Hunyuan3D oder TripoSR erzeugt Mesh.
4. Blender bereinigt, unwrappt und exportiert.
5. Ergebnis wird in `~/Ultimate_KI_Setup/exports` abgelegt.

## Kubernetes Skalierung

Mehrere 3D-Artist-Jobs koennen als Queue parallel auf ComfyUI- und Blender-Worker-Nodes verteilt werden.

