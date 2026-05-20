# Architektur_3D_BIM

Lokales Profil fuer Architektur, BIM/IFC, CAD, Innenraumplanung, 3D-Rendering, Smart-Home-Planung und Renderfarm-Workflows im Ultimate KI Setup.

Dieses Profil erweitert Ollama, OpenClaw, n8n, ComfyUI, Blender, FreeCAD und optionale Kubernetes-Worker zu einem lokal-first Architektur- und BIM-Studio. Es ist fuer Planung, Analyse, Visualisierung und Dokumentation gedacht, nicht als Ersatz fuer Architekten, Statiker, Energieberater, Brandschutzplaner oder bauvorlageberechtigte Fachpersonen.

## Kurzbeschreibung

`Architektur_3D_BIM` kombiniert klassische Open-Source-Bau-, CAD- und 3D-Werkzeuge mit lokalen KI-Agenten:

- Grundrisse analysieren und Varianten vorschlagen
- FreeCAD-/OpenSCAD-/Blender-Skripte vorbereiten
- IFC/BIM-Modelle pruefen und zusammenfassen
- Innenraeume, Materialien und Lichtstimmungen planen
- ComfyUI-Render- und Konzeptbild-Pipelines dokumentieren
- Materiallisten, Projektberichte und Export-Checklisten erzeugen
- Renderjobs lokal oder spaeter ueber Kubernetes verteilen
- Smart-Home- und Home-Assistant-Ideen in die Gebaeudeplanung einbinden

## Sicherheits- und Fachregel

KI darf in diesem Profil Vorschlaege, Analysen, Skripte und Visualisierungen erzeugen. Sie darf keine verbindliche Bauplanung, Statik, Elektroplanung, Brandschutzbewertung, Genehmigungsplanung oder Kostenzusage ersetzen.

Pflichtregeln:

- Bau-, Statik-, Tragwerks-, Brandschutz-, Elektro- und Genehmigungsfragen immer fachlich pruefen lassen.
- IFC-/CAD-Aenderungen nur versioniert speichern und nie ungeprueft in produktive Planungsstaende uebernehmen.
- Cloud-APIs, Renderdienste und Materialdatenbanken nur mit Kostenlimit und ohne vertrauliche Projektdaten nutzen.
- Remote WebUIs nur ueber Auth, Tunnel-Policies und lokale Firewalls freigeben.
- AI-Renderings als Entwurf kennzeichnen, nicht als baurechtliche Planung.

## Zielarchitektur

```text
User / Open WebUI / OpenClaw
        |
        v
OpenClaw Agent: Architektur_3D_BIM
        |
        +-- Ollama: Analyse, CAD-Code, IFC-Zusammenfassung
        +-- n8n: Renderjobs, Reports, Backup, Benachrichtigungen
        +-- ComfyUI: Konzeptbilder, Materialideen, Depth/ControlNet
        |
        v
FreeCAD / Blender / Bonsai / IFCOpenShell / OpenSCAD
        |
        +-- IFC / STEP / DXF / STL / GLB / OBJ
        +-- Render / PDF / Materialliste / Preview
        |
        v
Projektordner / Asset-Browser / Rendercache / Backup
        |
        v
Optional: Kubernetes Render- und GPU-Worker
```

## Geeignete Aufgaben

- Architekturkonzepte, Raumprogramme und Varianten sammeln
- Grundriss-Ideen und Zonierungslogik beschreiben
- IFC-Eigenschaften, Bauteile, Raeume und Mengen auswerten
- CAD-/BIM-Skripte fuer FreeCAD, Blender, IFCOpenShell oder OpenSCAD vorbereiten
- Innenraum-Stile, Materialkombinationen und Lichtkonzepte entwerfen
- Renderprompts fuer SDXL, Flux, ControlNet und ComfyUI vorbereiten
- Smart-Home-Planung mit Home Assistant, MQTT und Sensorik skizzieren
- Projektordner, Backup, Rendercache und Exportpfade strukturieren
- Renderfarm- und Kubernetes-Topologien planen

## Nicht geeignete Aufgaben

- verbindliche Statik oder Tragwerksplanung
- Brandschutz- oder Fluchtwegfreigaben
- Elektroplanung ohne Fachpruefung
- Energieausweise oder amtliche Nachweise ohne zugelassene Tools/Fachperson
- Bauantraege, Genehmigungsplanung oder Haftungszusagen
- automatische Aenderung produktiver IFC-/CAD-Dateien ohne Review

## Empfohlene Open-Source-Bausteine

| Bereich | Tool | Aufgabe | Status |
|---|---|---|---|
| CAD | FreeCAD | parametrisches CAD, STEP/STL/DXF, Python-Scripting | stabil |
| 3D/Rendering | Blender | Visualisierung, Animation, Asset- und Renderpipeline | stabil |
| BIM | Bonsai / BlenderBIM | IFC-Modellierung und BIM in Blender | stabil/aktiv |
| Kollaboration | Speckle | Modell-Streaming, Versions- und Teamworkflows | optional |
| Innenraum | SweetHome3D | schnelle Wohnraum- und Moebelplanung | stabil |
| Energie | OpenStudio | Energieanalyse und Gebaeudesimulation | fortgeschritten |
| GIS/Stadt | QGIS | Stadtplanung, Geo-Daten, Lageplaene | stabil |
| IFC | IFCOpenShell | IFC lesen, schreiben, pruefen, Skripting | stabil |
| Code-CAD | OpenSCAD | parametrisches Code-CAD und 3D-Druck | stabil |
| Photogrammetrie | Meshroom / AliceVision | Foto zu 3D-Mesh | optional/GPU-lastig |
| Photogrammetrie | COLMAP | SfM/MVS, Kamera-Posen, 3D-Rekonstruktion | optional/GPU-lastig |

## Ollama-Modellvorschlaege

| Modellfamilie | Staerke | Einsatz |
|---|---|---|
| `qwen2.5-coder` / Qwen Coder | Code, Python, Skripting | FreeCAD-, Blender-, IFCOpenShell- und OpenSCAD-Code |
| `deepseek-coder` | technische Codegenerierung | CAD-Skripte, Automationslogik, n8n-Glue-Code |
| `deepseek-r1` | reasoning-lastige Analyse | Variantenbewertung, Planungslogik, Fehleranalyse |
| Llama 3.x | allgemeine Assistenz | Projektberichte, Checklisten, Kundenkommunikation |
| Mistral / Codestral | kompakte Code- und Textarbeit | lokale CAD-/BIM-Hilfsagenten |
| CodeLlama | klassische Codehilfe | kleinere Skripte und Beispiele |
| Phi / Gemma | sparsame Hardware | Zusammenfassungen, einfache Checklisten, offline kleine Systeme |

Empfehlung: Auf schwacher Hardware kleine 3B- bis 8B-Modelle fuer Dokumentation nutzen. Fuer CAD-Code und IFC-Analyse sind 14B- bis 32B-Modelle deutlich angenehmer. Grosse Render- oder Vision-Pipelines brauchen unabhaengig vom LLM vor allem SSD, RAM und GPU/VRAM.

## OpenClaw-Agentenrollen

| Agent | Aufgabe |
|---|---|
| Architektur-Assistent | sammelt Anforderungen, Raumprogramm, Varianten und Rueckfragen |
| BIM-Analyst | liest IFC-Berichte, erkennt fehlende Eigenschaften und Mengenrisiken |
| CAD-Code Generator | erzeugt FreeCAD-, OpenSCAD-, Blender- oder IFCOpenShell-Skripte |
| Innenraum Designer | erstellt Stil-, Licht-, Material- und Moebelkonzepte |
| Materialplaner | ordnet Materialien, Mengen, Nachhaltigkeit und Kostenrisiken |
| SmartHome Architekt | plant Sensorik, Zonen, Home Assistant, MQTT und Datenschutz |
| Stadtplanungs-KI | nutzt QGIS-/Geo-Kontext fuer Lage, Umgebung und Infrastruktur |
| Renderfarm Manager | plant Blender-/ComfyUI-Jobs, Prioritaeten und GPU-Auslastung |
| IFC Parser | extrahiert Raeume, Bauteile, Geschosse, Mengen und Property Sets |
| STL/3D-Druck Assistent | prueft Massstab, Wandstaerken, Export und Druckbarkeit |

## Beispiel-Workflows

### Workflow 1: IFC Analyse

1. IFC-Datei in den Projektordner legen.
2. IFC Parser extrahiert Raeume, Geschosse, Bauteile und Property Sets.
3. BIM-Analyst erstellt Auffaelligkeiten und fehlende Datenfelder.
4. OpenClaw erzeugt einen Markdown-Bericht.
5. Nutzer prueft und entscheidet, ob Anpassungen in FreeCAD/Bonsai erfolgen.

### Workflow 2: Innenraum-Rendering mit ComfyUI

1. Nutzer beschreibt Raum, Stil, Materialien und Licht.
2. Architektur-Assistent erstellt einen strukturierten Prompt.
3. ComfyUI nutzt SDXL/Flux, ControlNet, Depth und Architektur-LoRAs.
4. Renderfarm Manager speichert Varianten mit Seed, Modell und Workflow.
5. Nutzer waehlt Favoriten fuer Blender/FreeCAD-Weiterarbeit aus.

### Workflow 3: CAD zu 3D-Druck

1. CAD-Code Generator erstellt FreeCAD/OpenSCAD-Entwurf.
2. STL/3D-Druck Assistent prueft Wandstaerke, Toleranzen und Massstab.
3. Blender erzeugt Preview und optional GLB.
4. Export nach STL/STEP/DXF.
5. Fachliche Pruefung vor realem Einsatz.

### Workflow 4: Kubernetes Renderfarm

1. n8n nimmt Renderauftrag entgegen.
2. Renderfarm Manager priorisiert Jobs nach VRAM, Deadline und Projekt.
3. Kubernetes verteilt Blender-/ComfyUI-Jobs auf GPU-Worker.
4. Ergebnisse landen in `renders/` und `exports/`.
5. Grafana/Prometheus zeigen GPU, VRAM, Queue und Fehler.

## N8n-Automationen

- Renderjob aus Formular oder Webhook starten
- IFC-Datei hochladen, Analysebericht erzeugen, PDF exportieren
- Materiallisten aus IFC/CSV sammeln und Preis-/Verfuegbarkeitsnotizen vorbereiten
- Bild-zu-3D-Pipeline mit COLMAP/Meshroom als optionaler Batchjob
- Blender-Renderjobs mit Prioritaet und Ausgabeformat ausloesen
- Konzeptzeichnungen mit ComfyUI erzeugen und in Projektordner ablegen
- Grundrissanalyse starten und Rueckfragenliste erzeugen
- Projektbackup, Rendercache-Cleanup und ZIP-Export automatisieren

## ComfyUI / AI-Bildsysteme

Empfohlene Bausteine:

- SDXL fuer stabile Architektur- und Innenraumkonzepte
- Flux fuer hochwertige Konzeptbilder, falls lokal sinnvoll betreibbar
- ControlNet fuer Grundriss-, Kanten-, Tiefen- und Referenzsteuerung
- Depth Mapping fuer Raumwirkung und Bild-zu-3D-Vorstufen
- Architektur-LoRAs fuer Fassaden, Raeume, Tiny Houses, Stadtansichten
- Innenraum-LoRAs fuer Stilrichtungen, Licht, Moebel und Material
- Material-LoRAs fuer Holz, Beton, Glas, Metall, Keramik, Stoff

Wichtig: LoRAs und Modelle nur aus vertrauenswuerdigen Quellen nutzen und Lizenzbedingungen pruefen.

## Kubernetes- und Multi-GPU-Skalierung

| Node | Aufgabe | Hinweise |
|---|---|---|
| Node 1 | Ollama / OpenClaw | CPU/RAM wichtig, GPU optional |
| Node 2 | ComfyUI | NVIDIA CUDA/VRAM fuer SDXL/Flux |
| Node 3 | Blender Renderer | GPU-Rendering, Cycles, Eevee Next |
| Node 4 | IFC/FreeCAD/QGIS Jobs | CPU/RAM/SSD, nicht zwingend GPU |
| Node 5 | Storage/Cache | schnelle NVMe, Backups, Asset Library |

Kubernetes bleibt optional. Fuer kleine Setups reicht ein lokaler Rechner. Fuer Renderfarmen spaeter GPU-Worker mit Labels wie `gpu=true`, `render=blender` und `ai=comfyui` verwenden.

## Projektordnerstruktur

```text
Ultimate_KI_Setup/
  architecture/
    projects/
    ifc/
    cad/
    blender/
    comfyui/
    renders/
    exports/
    textures/
    materials/
    photogrammetry/
    reports/
    cache/
    backups/
```

## Beispiel-ENV

```env
ARCHITECTURE_PROFILE_ENABLED=true
ARCHITECTURE_MODE=local_first
ARCHITECTURE_PROJECT_ROOT=$HOME/Ultimate_KI_Setup/architecture

OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=qwen2.5-coder:14b

OPENCLAW_AGENT_PROFILE=architektur_3d_bim
OPENCLAW_REQUIRE_REVIEW=true

COMFYUI_URL=http://127.0.0.1:8188
BLENDER_HEADLESS=true
FREECAD_HEADLESS=true

IFC_VALIDATE_BEFORE_WRITE=true
RENDER_CACHE_DAYS=30
BACKUP_ENABLED=true
REMOTE_WEBUI=false
```

## Remote WebUI und Cloudflare Tunnel

- WebUIs standardmaessig nur lokal binden.
- Cloudflare Tunnel nur mit Access Policy, MFA und klaren Hostnamen nutzen.
- Projektdateien, IFCs, Kundendaten und Plaene nicht ohne Freigabe in externe Dienste laden.
- API-Keys fuer Render-/KI-Dienste nie im Repo speichern.

## Backup- und Rendercache-Strategie

- Projektordner versionieren, grosse Binardateien getrennt sichern.
- `renders/` und `cache/` regelmaessig bereinigen.
- IFC-/CAD-Originale unveraendert in `projects/originals/` halten.
- Exportierte PDFs, STLs und GLBs mit Datum/Version benennen.
- Vor AI-gestuetzten Massenoperationen Snapshot oder Backup erstellen.

## Lizenzhinweise

- FreeCAD, Blender, QGIS, IFCOpenShell und OpenSCAD sind Open-Source-Projekte, aber einzelne Plugins, Assets, LoRAs, Texturen und Modelle koennen andere Lizenzen haben.
- Speckle, OpenStudio, Meshroom/AliceVision und COLMAP koennen je nach Paket/Distribution eigene Installations- und Lizenzbedingungen haben.
- KI-generierte Entwuerfe nicht ohne Rechtepruefung als Kunden- oder Verkaufsunterlagen nutzen.

## Beispielprompts

```text
Analysiere diese IFC-Zusammenfassung und nenne fehlende Raum- und Bauteileigenschaften.
```

```text
Erstelle einen FreeCAD-Python-Entwurf fuer ein Tiny-House-Modul mit parametrischer Laenge, Breite und Wandstaerke.
```

```text
Formuliere einen ComfyUI-Prompt fuer ein helles skandinavisches Wohnzimmer mit Holz, Lehmputz und grossem Nordfenster.
```

```text
Erstelle einen n8n-Workflow, der Blender-Renderjobs annimmt, in eine Queue schreibt und nach Abschluss eine Nachricht sendet.
```

```text
Pruefe diese Materialliste auf Kosten-, Liefer- und Nachhaltigkeitsrisiken.
```

## Installations- und Checkpfade

```bash
bash scripts/install_architektur_3d_bim_optional.sh
ARCH_INSTALL_CORE=1 bash scripts/install_architektur_3d_bim_optional.sh
bash profiles/architektur_3d_bim/scripts/check_architektur_stack.sh
```

Standardmaessig prueft das Installationsskript nur System und Hinweise. Schwere Pakete werden erst mit `ARCH_INSTALL_CORE=1` vorgeschlagen/installiert.

