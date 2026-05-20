# CAD Konstrukteur / 3D-Druck / Technische Modellierung

Dieses Profil erweitert das Ultimate KI Setup um einen lokalen CAD-Konstrukteur fuer technische Bauteile, 3D-Druck, parametrische Modellierung und KI-gestuetzte CAD-Code-Erzeugung. Es nutzt bevorzugt lokale Open-Source-Komponenten und bleibt bewusst modular: stabile CAD-Werkzeuge werden getrennt von experimentellen Text-to-CAD-Agenten betrachtet.

## Zweck

Der CAD-Konstrukteur soll aus natuerlicher Sprache technische CAD-Aufgaben ableiten, fehlende Masse erkennen, Rueckfragen stellen, parametrischen Code erzeugen und daraus Modelle fuer Prototyping, 3D-Druck, Robotik und Gehaeusebau vorbereiten.

Typische Aufgaben:

- Text zu CAD-Modell
- technische Bauteile konstruieren
- parametrische Gehaeuse erstellen
- 3D-Druck-Modelle erzeugen
- STL, STEP, DXF, SVG, OpenSCAD und FreeCAD-Dateien erzeugen
- einfache technische Zeichnungen vorbereiten
- Bauteile anhand von Beschreibung verbessern
- Varianten eines Gehaeuses generieren
- Masse, Bohrungen, Schraubloecher, Lueftungsschlitze, Halterungen und Toleranzen pruefen
- Raspberry-Pi-, Mini-PC-, ESP32- und Sensorgehaeuse entwerfen
- Robotik-Teile, Adapter, Montageplatten und Halterungen erzeugen
- CAD-Code ueber Ollama generieren und ueber FreeCAD, CadQuery oder OpenSCAD ausfuehren

## Architektur

```text
User / ChatGPT / OpenWebUI
        |
OpenClaw CAD-Agent
        |
Ollama Modell
        |
Prompt zu CAD-Code
        |
FreeCAD / CadQuery / OpenSCAD
        |
Export: STL / STEP / DXF / SVG
        |
Blender Preview / Slicer / 3D-Druck
        |
Review / Verbesserung / neue Variante
```

## Gepruefte Open-Source-Projekte

| Projekt | Status | Einschaetzung |
|---|---|---|
| [FreeCAD](https://github.com/FreeCAD/FreeCAD) | stabiler Kern | Open-Source parametrischer 3D-Modeller mit Python-API, Linux/Windows/macOS, gute Basis fuer FreeCAD-Python und STEP/STL-Export. |
| [CadQuery](https://github.com/CadQuery/cadquery) | stabiler Script-CAD-Baustein | Python-basiertes parametrisches CAD-Framework auf OCCT, gut fuer wiederholbare technische Bauteile, STEP/STL/DXF-nahe Workflows. |
| [OpenSCAD](https://github.com/openscad/openscad) | stabil fuer 3D-Druck-Code | Programmierer-orientierter Solid-3D-CAD-Modeller, ideal fuer einfache parametrische Gehaeuse, Adapter und 3D-Druckteile. |
| [Blender](https://github.com/blender/blender) | stabil als Preview/Render/Asset-Tool | Nicht primaeres CAD, aber nuetzlich fuer Vorschau, Mesh-Checks, Renderings, Animation und Asset-Konvertierung. |
| [CADAM](https://github.com/Adam-CAD/CADAM) | experimentell | Open-Source Text-to-CAD Web-App mit OpenSCAD/WASM-Bezug. Interessant als Inspiration, aber nicht als Pflichtinstallation. |
| [text-to-cad / CAD Skills](https://github.com/earthtojake/text-to-cad) | experimentell, aber relevant | Agent Skills fuer CAD, Robotik und Hardwaredesign, MIT-lizenziert, mit STEP/STL/URDF/SDF-Bezug. Gut als spaeterer Agentenpfad. |
| [openAI-to-FreeCAD workflow](https://github.com/giuliano-t/openAI-to-freeCAD-workflow) | Forschungs-/Beispielprojekt | Zeigt eine RAG-/Few-Shot-Pipeline von Sprache zu FreeCAD-Python. Klein und prototypisch, daher nur als Referenz, nicht als Produktionsbasis. |

## Lokale Modell-Empfehlungen

| Modell | Staerke | Einsatz |
|---|---|---|
| `qwen2.5-coder:1.5b` / `qwen2.5-coder:3b` | klein, schnell | schwache Hardware, einfache OpenSCAD-/Python-Snippets, Rueckfragen |
| `qwen2.5-coder:7b` | guter Allround-Code | FreeCAD-Python, CadQuery, Varianten, Fehlersuche |
| `deepseek-coder:6.7b` | Code-Generierung | saubere Script-Erzeugung, Refactoring, Erklaerungen |
| `deepseek-r1` | reasoning-stark | technische Abwaegungen, Mass-/Toleranzanalyse, Fehlerhypothesen |
| `llama3.2:1b` / `llama3.2:3b` | leichtgewichtig | einfache Assistentenlogik, Auftragserfassung, Checklisten |
| `llama3.1:8b` oder aehnlich | solide Sprache + Planung | CAD-Briefings, N8n-Workflows, Dokumentation |
| `codestral` / Mistral-Code-Modelle | stark, falls lokal verfuegbar | komplexere Python-/CAD-Code-Erzeugung auf staerkerer GPU |

## Faehigkeiten des CAD-Agenten

Der CAD-Agent kann:

- Anforderungen aus natuerlicher Sprache aufnehmen
- Zweck, Bauraum, Material, Fertigung und Toleranzen erfassen
- fehlende Masse erkennen und Rueckfragen formulieren
- realistische Standardwerte vorschlagen und klar markieren
- FreeCAD-Python-Code erzeugen
- CadQuery-Code erzeugen
- OpenSCAD-Code erzeugen
- Dateien speichern und versionieren
- STL, STEP, DXF und SVG vorbereiten
- Preview-Bilder ueber FreeCAD, OpenSCAD oder Blender erzeugen
- Varianten vergleichen
- einfache Fehler wie fehlende Wandstaerke, zu kleine Bohrungen oder unklare Toleranzen erkennen
- Modelle mit neuen Massen regenerieren

## Beispielanfragen

```text
Erstelle ein Raspberry Pi 5 Gehaeuse mit Lueftungsschlitzen.
Erstelle eine Wandhalterung fuer einen Mini-PC.
Erstelle einen Adapter von 40-mm-Luefter auf 60-mm-Gehaeuseoeffnung.
Erstelle eine Motorhalterung fuer ein kleines Roboterfahrzeug.
Erzeuge ein Gehaeuse fuer ESP32 mit USB-C-Ausschnitt.
Erstelle eine Montageplatte mit vier Schraubloechern.
```

## Lokale Ordnerstruktur

```text
profiles/cad_konstrukteur/
profiles/cad_konstrukteur/README.md
profiles/cad_konstrukteur/prompts/cad_system_prompt.md
profiles/cad_konstrukteur/examples/freecad_box_example.py
profiles/cad_konstrukteur/examples/cadquery_mount_example.py
profiles/cad_konstrukteur/examples/openscad_case_example.scad
scripts/install/install_cad_tools.sh
scripts/check/check_cad_tools.sh
```

## Installation

```bash
bash scripts/install/install_cad_tools.sh
bash scripts/check/check_cad_tools.sh
```

Das Installationsskript prueft vorhandene Programme, installiert unter Ubuntu/WSL2 nach Moeglichkeit FreeCAD, OpenSCAD und Basis-Python, legt eine venv unter `~/.openclaw_ultimate_user_data/cad_konstrukteur/venv` an und versucht dort CadQuery, NumPy, Trimesh und MeshIO zu installieren. Blender bleibt optional und wird nur mit `CAD_INSTALL_BLENDER=1` installiert.

## N8n-Automation

Ein sinnvoller Workflow:

1. Formular nimmt CAD-Auftrag entgegen.
2. N8n sendet Prompt an OpenClaw/Ollama.
3. CAD-Agent erzeugt FreeCAD-, CadQuery- oder OpenSCAD-Code.
4. Code wird in einem Projektordner gespeichert.
5. FreeCAD/OpenSCAD generiert Modell und Export.
6. Preview-Bild wird erzeugt.
7. Ergebnis wird per Webhook, Ordner, Telegram, Matrix oder Email bereitgestellt.

## Whisper-Sprachsteuerung

Beispiele:

```text
Mach das Gehaeuse zwei Millimeter breiter.
Setze vier Schraubloecher in die Ecken.
Erhoehe die Wandstaerke auf drei Millimeter.
Exportiere als STL.
```

Whisper transkribiert Sprache. OpenClaw wandelt die Aenderung in CAD-Parameter oder Code-Aenderungen um. FreeCAD, CadQuery oder OpenSCAD regenerieren das Modell.

## Sicherheit und Grenzen

- KI-CAD kann fehlerhafte Geometrie, falsche Masse oder unzureichende Toleranzen erzeugen.
- Bauteile fuer Fahrzeuge, Bremsen, Strom, Gas, Medizin, tragende Konstruktionen oder Maschinen muessen fachlich geprueft werden.
- 3D-Druckteile haben begrenzte Stabilitaet und anisotrope Materialeigenschaften.
- Toleranzen muessen real gedruckt und getestet werden.
- Materialwahl, Temperatur, UV, Belastung, Vibration und Schraubkraefte beachten.
- Sicherheitskritische Bauteile duerfen nicht ohne Simulation, Test und Fachpruefung eingesetzt werden.

## Stabil, optional, experimentell

| Stufe | Bausteine |
|---|---|
| stabil | FreeCAD, OpenSCAD, Blender als Preview/Render, FreeCAD-Python, OpenSCAD-Code |
| optional | CadQuery per venv, MeshIO, Trimesh, N8n-Automation, Whisper-Kommandos |
| experimentell | CADAM, text-to-cad Agent Skills, openAI-to-FreeCAD RAG-Workflow, vollautomatische Text-to-CAD-Pipelines |
