# FotoScan_Panorama_360_3D

Lokales Profil fuer Foto-zu-Panorama, 360-Grad-Ansichten, einfache Photogrammetrie und optionale Gaussian-Splatting-Workflows im Ultimate KI Setup.

## Kurzbeschreibung

Dieses Profil beschreibt, wie mehrere Fotos lokal mit Open-Source-Werkzeugen zu Panoramen, 360-Grad-Ansichten und einfachen 3D-Rekonstruktionen verarbeitet werden koennen. Es ist als realistische Erweiterung fuer Ollama, OpenClaw, n8n und lokale Medien-/3D-Workflows gedacht.

## Wichtige Tool-Basis

Hugin ist ein Open-Source-Panorama-Stitcher mit CLI-Werkzeugen. COLMAP, OpenMVG, OpenMVS und Meshroom sind typische Open-Source-Photogrammetrie-Bausteine. Gaussian Splatting kann optional ueber COLMAP-basierte Datensaetze laufen.

## Typische Workflows

| Workflow | Tool-Basis | Ausgabe |
|---|---|---|
| Mehrere Fotos zu Panorama | Hugin / PanoTools | JPG, PNG, TIFF |
| Fotoserie zu 360-Grad-Panorama | Hugin, Panorama-Viewer | equirectangular JPG/PNG, HTML-Viewer |
| Fotos zu 3D-Modell | COLMAP, Meshroom, OpenMVG/OpenMVS | OBJ, PLY, GLB/glTF, textured mesh |
| Fotos/Videos zu Gaussian Splatting | COLMAP als Pose-Vorstufe, optionale Splatting-Pipeline | PLY / Viewer-Datensatz |

## OpenClaw-Jobparameter

```env
FOTOSCAN_INPUT_DIR=$HOME/KI-Media/input/photos
FOTOSCAN_OUTPUT_DIR=$HOME/KI-Media/output
FOTOSCAN_WORKFLOW=panorama
FOTOSCAN_QUALITY=medium
FOTOSCAN_GPU=auto
```

Erlaubte Workflows:

- `panorama`
- `360`
- `3d`
- `splat`

Erlaubte Qualitaetsstufen:

- `low`
- `medium`
- `high`
- `ultra`

## Ollama- und OpenClaw-Aufgaben

- Fotoqualitaet bewerten
- fehlende Blickwinkel erkennen
- Aufnahme-Anleitung fuer bessere Ueberlappung erzeugen
- Fehler aus Hugin, COLMAP oder Meshroom erklaeren
- n8n-Jobs fuer Upload-Ordner, ZIP-Export und Statusmeldungen vorbereiten

## Qualitaetsregeln

- Fotos brauchen etwa 60 bis 80 Prozent Ueberlappung.
- Gute, gleichmaessige Beleuchtung verbessert Stitching und Rekonstruktion.
- Stark spiegelnde oder transparente Flaechen sind schwierig.
- Bilder sollten scharf und moeglichst nicht verwackelt sein.
- Gleiche Brennweite und konstante Kameraeinstellungen helfen.
- Fuer 3D ein Objekt komplett umrunden.
- Fuer Raeume mehrere Blickwinkel und Hoehen verwenden.

## Grenzen

Photogrammetrie und Gaussian Splatting sind daten- und GPU-lastig. COLMAP, Meshroom und Gaussian-Splatting-Pipelines koennen je nach GPU, CUDA-Version, Bildanzahl und Aufloesung deutlich variieren. Dieses Profil behauptet daher keine vollautomatische Erfolgsgarantie, sondern dokumentiert einen lokalen, pruefbaren Workflow.

