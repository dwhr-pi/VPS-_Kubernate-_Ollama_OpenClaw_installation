# n8n Workflows fuer Architektur 3D BIM

## Automatischer Renderjob

- Trigger: neues Blender/IFC/CAD-Artefakt.
- OpenClaw erstellt Renderbriefing.
- Blender rendert Preview oder finalen Frame.
- ComfyUI erzeugt Stilvariante.
- Ergebnis wird in `renders/` und `reports/` abgelegt.

## IFC Analyse

- IFC-Datei wird hochgeladen.
- IfcOpenShell extrahiert Bauteile, Geschosse, Raeume und Mengen.
- OpenClaw erstellt Markdown/PDF-Report.
- GitHub PR oder Projektordner bekommt den Report.

## Materialliste

- IFC/CSV/BOM wird eingelesen.
- Materialplaner prueft Mengen, Kategorien und Risiken.
- n8n exportiert CSV/PDF.

## Bild-zu-3D Pipeline

- Foto/Render wird angenommen.
- ComfyUI erzeugt Depth/ControlNet-Hilfen.
- Blender/FreeCAD bekommt Referenz und Masse.
- Ergebnis wird als Konzeptmodell markiert.

## Backup und Projektverwaltung

- Nach jedem Meilenstein Snapshot.
- Rendercache nach Alter/Groesse bereinigen.
- Kritische Projektdateien extern sichern.

