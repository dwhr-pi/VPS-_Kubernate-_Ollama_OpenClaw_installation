# Architektur 3D BIM Guide

Dieser Guide ergaenzt das Profil `Architektur_3D_BIM` um Installation, Projektstruktur, Hardwareklassen und Betriebsregeln.

## Hardwareklassen

| Klasse | Einsatz |
| --- | --- |
| CPU-only MiniPC | CAD, IFC-Analyse, kleine FreeCAD/IfcOpenShell-Skripte, Doku |
| 16-32 GB RAM Workstation | FreeCAD, QGIS, Blender Preview, kleinere Photogrammetrie |
| 8-12 GB VRAM GPU | ComfyUI Konzeptbilder, einfache Blender GPU-Renders |
| 16-24 GB VRAM GPU | ernsthafte Renderjobs, SDXL/Flux, groessere Szenen |
| Multi-GPU / Kubernetes | parallele Renderfarm, Batchjobs, verteilte Texture Libraries |

## Speicher und Netzwerk

- Basisinstallation: 10-30 GB je nach apt-Paketen.
- Projekte: 5-200 GB je nach IFC, Texturen, Photogrammetrie und Renderoutputs.
- Rendercache: getrennt unter `architecture/cache` halten.
- Netzwerk: Remote WebUI nur ueber Cloudflare Tunnel/Tailscale und Auth.

## Native Linux Installation

Der Installer bevorzugt apt/Python und erzwingt kein Docker:

```bash
bash scripts/tools/architecture_bim_install.sh
```

Optionale schwere Pakete oder manuelle Schritte:

- Bonsai als Blender Add-on aus dem IfcOpenShell/Bonsai-Umfeld.
- Speckle Connectoren je nach Zielplattform.
- OpenStudio/EnergyPlus je nach Distribution.
- Meshroom kann je nach Ubuntu-Version nicht direkt per apt verfuegbar sein.

## Beispielprojekte

- Einfamilienhaus mit IFC-Struktur und Materialliste.
- Innenraum-Render mit Blender + ComfyUI.
- Scan-to-BIM Test mit COLMAP/Meshroom und manuellem Cleanup.
- Smart-Home-Zonenplan mit Home Assistant/MQTT.
- OpenSCAD/FreeCAD Bauteil fuer 3D-Druck.

## Backupstrategie

- `projects`, `bim`, `ifc`, `cad`, `freecad` und `reports` versionieren oder sichern.
- `cache`, `renders` und grosse Texturen getrennt sichern oder aus Git ausschliessen.
- Vor Batch-Konvertierung automatisch Projekt-Snapshot erzeugen.
- Nightly Backup mit Restic/Borg/Rclone optional.

## Lizenzhinweise

- Texturen, LoRAs, HDRIs, 3D-Modelle und Stadt-/GIS-Daten koennen eigene Lizenzen haben.
- IFC-/BIM-Modelle von Kundenprojekten sind vertraulich.
- AI-Renderings fuer echte Bauvorhaben immer als Konzept oder Visualisierung kennzeichnen.

