# Beispiel: Blender Render Queue

Ziel: Renderjobs lokal sammeln und spaeter optional auf GPU-Worker verteilen.

```text
architecture/renders/queue/
architecture/renders/active/
architecture/renders/done/
architecture/renders/failed/
```

Jobfelder:

- Projektname
- Blender-Datei
- Kamera
- Aufloesung
- Samples
- Ausgabeformat
- Prioritaet
- GPU-Anforderung

