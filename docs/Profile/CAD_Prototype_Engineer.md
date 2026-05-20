# CAD Prototype Engineer

## Aufgabe

Dieses Profil erzeugt CAD-nahe Prototypen und STL-Dateien fuer Designstudien, 3D-Drucktests und technische Visualisierung. Es ersetzt kein echtes CAD-System, hilft aber beim schnellen Konzepten.

## Empfohlene Modelle

- Ollama fuer technische Spezifikation und Plausibilitaetscheck.
- TripoSR fuer schnelle Objekt-Rekonstruktion.
- Blender fuer Massstab, Mesh-Reparatur und STL-Export.

## GPU und VRAM

- CPU-only reicht fuer einfache Blender-Konvertierungen.
- 8-12 GB VRAM fuer einfache Bild-zu-3D-Versuche.
- 16 GB+ empfohlen fuer komfortable lokale Workflows.

## Beispielprompt

```text
Erstelle einen einfachen Gehaeuse-Prototyp fuer einen Sensor, 80 x 45 x 25 mm, abgerundete Kanten, zwei Schraubdome, STL-Export, druckbar orientieren.
```

## Workflow

1. OpenClaw wandelt die Idee in messbare Anforderungen.
2. Blender erstellt oder korrigiert Basismesh.
3. Mesh wird auf Non-Manifold, Scale und Wandstaerke geprueft.
4. Export als STL und Blend.

## Sicherheitsregel

Nicht fuer sicherheitskritische Bauteile ohne echte CAD-Pruefung, Simulation und Materialvalidierung verwenden.

## Kubernetes

CAD-Prototypen sind meist kleine Jobs; Queue und Versionsarchiv sind wichtiger als GPU-Autoscaling.

