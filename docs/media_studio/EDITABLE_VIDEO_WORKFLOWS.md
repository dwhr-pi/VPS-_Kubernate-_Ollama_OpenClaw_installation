# Video-Workflows vor dem Rendern bearbeiten

[OpenMontage](../tools/openmontage.md) ergaenzt Produktionsplanung und
optionale Komposition. Eigener Kerninstaller ohne Docker; keine automatisch
fertige Anbindung dieses Rezeptplaners an OpenMontage oder ComfyUI.

Stand: **22.10.2026**. Arcads-/Umnik-Nutzerquellen, lokale Umsetzung und
ausfuehrbarer **Offline-Planer**, keine fertige Videogenerierungs-App.

## Kann dein Setup das?

**Ja, als modularen Eigenbau mit Bearbeitung und Freigabe vor dem Rendern.**
Skript, Szenen, Fotos, Bewegung, Stimme, Laufzeit und Ausgabeformat koennen
vorher eingestellt werden. Ein identischer Nachbau jedes kommerziellen
Templates oder dessen Qualitaet ist damit nicht garantiert. Produktdetails,
Gesichter, Haende, Schrift und zeitliche Konsistenz brauchen Sichtkontrolle.

Dein Setup hat viele passende **Katalogeintraege**: ComfyUI, Wan21,
WanVideoWrapper, Ollama, FFmpeg, Coqui TTS, SadTalker, LivePortrait, MuseTalk,
Node-RED und n8n. Registrierung ist kein Nachweis fuer Installation, passende
Gewichte, lizenzierte Assets oder eine getestete Gesamtpipeline.
[Bestehender Integrationsplan](SOCIAL_AVATAR_AUTOMATION.md).

## Quellen: was tatsaechlich bekannt ist

| Quelle | Pruefergebnis und Grenze |
|---|---|
| [Arcads-Flow](https://app.arcads.ai/flow/public/dcvTLGxXOccLw8L3YOeIVvya) | Beim Abruf nicht auslesbar; konkrete Nodes, Modelle und Eingabefelder unbekannt |
| [Arcads-Reel](https://www.instagram.com/reel/Deo_dq6zbPo/) | Abruf gedrosselt; Beschreibung stammt aus deinem eingefuegten Text |
| [Umnik](https://umnik.ai/) | Oeffentliche Startseite beschreibt eine Modellplattform und Foto-/Trendangebote; kein Beleg fuer interne Modelle oder eine exportierbare lokale Pipeline |
| [Umnik-Reel](https://www.instagram.com/reel/DeeOsB4qmNb/) | Abruf gedrosselt; konkrete Fahrszene und Herstellungsweg nicht verifiziert |

Deshalb hier zwei **eigene Funktionsrezepte**, kein ausgelesener Arcads-Graph
und keine Behauptung, Umnik benutze intern Wan, InsightFace oder ComfyUI.
Umnik nennt selbst variable Ergebnisse. Gesichtertausch ist fuer einfache
Fotoanimationen nicht notwendig und wird hier nicht eingebaut.

## Schlanker Toolstack statt alles gleichzeitig

| Aufgabe | GitHub-Quelle | Benoetigt? / reale Grenze |
|---|---|---|
| Parameter und Graph bearbeiten | [ComfyUI](https://github.com/Comfy-Org/ComfyUI) | Fuer den vorgeschlagenen generativen Video-Pfad; lokale GUI/API, Gewichte und Nodes separat |
| Foto-/B-Roll-Animation | [Wan2.1](https://github.com/Wan-Video/Wan2.1) | Ein konkret passendes I2V-Modell/Graph; nicht jedes Wan-Modell nimmt Bilder entgegen |
| Schnitt, Ton und Encoding | [FFmpeg](https://github.com/FFmpeg/FFmpeg) | Fuer die spaetere Montage; auch ein Video ohne generative Animation ist damit moeglich |
| Vereinfachtes Eingabeformular | [Gradio](https://github.com/gradio-app/gradio) | Optional statt direkter ComfyUI-Bedienung; eigene Adapter erforderlich, keine automatische App hier |
| Skriptvarianten | [Ollama](https://github.com/ollama/ollama) | Optional; manuell geschriebener Text reicht zum Start |
| Voiceover | [Coqui TTS](https://github.com/coqui-ai/TTS) oder vorhandener TTS-Pfad | Optional; eigene Audiodatei reicht, Stimmen-/Gewichtslizenzen pruefen |
| Lippenbewegung | [MuseTalk](https://github.com/TMElyralab/MuseTalk) | Nur fuer sprechenden Avatar; unterstuetzt Audio plus Bild/Video-Eingaben, Ergebnis nicht automatisch perfekte Identitaet |
| Mehrstufige Orchestrierung | [Node-RED](https://github.com/node-red/node-red) | Optional; fuer einen einzelnen lokalen Workflow nicht zwingend |

ComfyUI hat bereits Parameter und eine Queue. Du brauchst nicht zusaetzlich
n8n, Node-RED, Streamlit UND Gradio. Fuer den Einstieg: vorhandenes ComfyUI,
ein kurzes geprueftes Rezept und anschliessend Montage. Ein Formular ist
Komfort, nicht Voraussetzung fuer die Bearbeitbarkeit.
[ComfyUI-Repository](https://github.com/Comfy-Org/ComfyUI),
[Gradio-Repository](https://github.com/gradio-app/gradio).

Keine Docker-Pflicht. Fuer neue Installationsarbeit GitHub-Quellen und
gepruefte Releases/Commits verwenden, isolierte Umgebungen vorsehen und
vorhandene Paketstaende nicht ungefragt aktualisieren. **Dieser Beitrag
installiert keine Tools, Gewichte, Custom Nodes oder Treiber.**

## Architektur: drei getrennte Ebenen

```text
1. Bedienung: Rezeptdatei / ComfyUI-Oberflaeche / spaeter eigenes Formular
      -> Eingaben bearbeiten und als neue Revision pruefen
2. Steuerung: Mensch, optional Agent / OpenMontage / Node-RED
      -> Arbeitsschritte planen, Freigaben und Ressourcen kontrollieren
3. Verarbeitung: ComfyUI + passendes Videomodell, optional TTS/LipSync
      -> einzelne Clips erzeugen -> FFmpeg oder optionale Komposition
```

Diese Grafik ist eine **Zielarchitektur**, keine bereits verbundene App.
Der [Offline-Planer](../../tools/media_workflow/plan.py) prueft heute nur
Rezeptdaten. [OpenMontage](../tools/openmontage.md) ist separat integrierbar;
es ersetzt weder das Videomodell noch einen noch fehlenden Rezept-Adapter.
Ein Coding-Agent kann beim Vorbereiten helfen, ist aber keine Voraussetzung
fuer den manuellen Ablauf. Keine dieser Ebenen verlangt grundsaetzlich Docker.

Der MiniPC kann Briefing und Bedienoberflaeche uebernehmen, waehrend der
RTX-Rechner spaeter rendert. Diese Aufteilung benoetigt eine bewusst
eingerichtete, zugriffsgeschuetzte Verbindung und Dateifreigabe; der Planer
uebertraegt nichts. Kein ComfyUI-Port sollte dafuer ungeschuetzt ins Internet.

### Welche Einstellungen lassen sich vorher aendern?

Die Feldnamen beziehen sich auf die beiden vorhandenen JSON-Beispiele,
nicht auf eine behauptete Arcads- oder Umnik-Schnittstelle.

| Wunsch | Im jetzigen Rezept | Was noch separat erforderlich ist |
|---|---|---|
| Werbetext, Hook, Sprache | `script` als Freitext | Textpruefung; ein Sprachwahlfeld ist nicht implementiert |
| Produktfoto oder Avatar | `scenes[].source` | Eigene Datei bereitstellen; Upload, Rechte und Bildinhalt werden nicht automatisch geprueft |
| Statische Szene, Fotoanimation oder sprechender Avatar | `scenes[].kind` | Passender Graph/Adapter; die Auswahl allein startet kein Modell |
| Bewegung, Kamera und Stil | `scenes[].prompt` | Modellabhaengige Umsetzung; ein Textwunsch garantiert keine exakte Kamerafahrt |
| Zufallsstart | `seed` | Gleicher Seed allein garantiert bei anderem Modell/Graph keine identische Ausgabe |
| Szenenreihenfolge und Dauer | Reihenfolge in `scenes`, jeweils `seconds` | Audiolaenge messen und beim spaeteren Schnitt abstimmen |
| Seitenformat und Bildrate | `canvas.width`, `canvas.height`, `canvas.fps` | Unterstuetzte Modellabmessungen pruefen; Rezeptvalidierung ist keine GPU-Kompatibilitaetspruefung |
| Kein Ton, eigene Aufnahme oder TTS | `audio.mode`, dazu `source` oder `voice_ref` | Datei bzw. freigegebene Stimme und separater Audio-Adapter |
| Musik, Untertitel, Uebergaenge, Exportcodec | Noch keine eigenen Rezeptfelder | In Montage/Schnitt konfigurieren; nicht als bereits unterstuetzte JSON-Felder erfinden |

### Bedienablauf: erst bearbeiten, dann bewusst rechnen lassen

1. Ein Beispielrezept als eigenes Projekt vorbereiten und nur eigene oder
   freigegebene Medien referenzieren. Zunaechst kurze Szenen planen.
2. Text, Bildreferenzen, Bewegung, Ton und Dauer bearbeiten. Den unten
   beschriebenen Offline-Planer ausfuehren und offene Punkte lesen.
3. Storyboard und vorhandene Medien manuell ansehen. Eine **generierte**
   Audio-/Videovorschau ist bereits ein eigener Inferenzauftrag und braucht
   Ressourcen und Freigabe; sie ist nicht Teil der Offline-Pruefung.
4. Fuer einen spaeter implementierten Renderpfad genau die gepruefte Revision
   samt Assets, Modell und Graph freigeben. Nach Aenderungen erneut pruefen.
5. Clips nacheinander erzeugen, ansehen und erst danach montieren/exportieren.
   Keine automatische Veroeffentlichung oder Wiederholung ohne Limit.

**Heute sofort nutzbar:** Rezept bearbeiten und offline pruefen. **Manuell
moeglich bei separat eingerichteten Tools:** ComfyUI-Graph bedienen und Clips
montieren. **Noch zu entwickeln:** ein gemeinsames Formular mit sicherer
Queue, Freigabe und durchgaengigem Render-Adapter. Der Eintrag im Tools-Menue
allein bedeutet nicht, dass diese Gesamtintegration bereits funktioniert.

### Briefing fuer einen Coding-Agenten ohne Renderfreigabe

```text
Plane ein kurzes Video anhand meines Angebots und meiner freigegebenen Assets.
Nutze examples/media-workflow/ugc-ad.json oder photo-trend.json als Schema.
Liefere zuerst Skript, Szenenplan und einen passenden JSON-Rezeptentwurf.
Kennzeichne fehlende Assets, Lizenzen und noch nicht implementierte Einstellungen.
Keine erfundenen Testimonials, Produktmerkmale oder Identitaetsgarantien.
Fuehre hoechstens die lokale Offline-Rezeptpruefung aus.
Keine Installation, Modellabfrage, Vorschaugenerierung, Queue-Einreichung,
Cloud-Uebertragung oder Veroeffentlichung. Warte auf meine separate Freigabe.
```

Ein solcher Prompt ist eine Arbeitsanweisung, keine technische Sandbox.
Zugriffsrechte, Netzwerkregeln und Joblimits muessen ausserhalb des Prompts
durchgesetzt werden. Lokale Verarbeitung spart moegliche API-Gebuehren,
aber nicht Strom, Speicherplatz, Einrichtungszeit oder Lizenzpruefungen.

## Zwei bearbeitbare Rezepte

### A. UGC-/Produktwerbung nach dem Arcads-Prinzip

```text
Angebot + eigene Produktbilder + belegte Aussagen
  -> Skript/Hook bearbeiten
  -> Voiceover waehlen oder eigene Tondatei
  -> Avatar optional, Produkt-B-Roll separat
  -> Storyboard + Audio-Vorschau pruefen
  -> genaue Revision freigeben
  -> kurze Szenen nacheinander rendern
  -> mit FFmpeg montieren, Untertitel/Produktdetails pruefen
  -> manueller Export; kein automatisches Hochladen
```

[Editierbares UGC-Beispiel](../../examples/media-workflow/ugc-ad.json).
Es enthaelt nur Platzhalterreferenzen, keine Fotos oder Stimmen. Fuer einen
einfacheren ersten Film den Avatar durch eine statische Produktansicht und
eine eigene Tonaufnahme ersetzen. LLM und LipSync sind dann nicht notwendig.
TTS-Laufzeit erst messen: gesprochener Text passt nicht automatisch in die
geplante Szenenlaenge. Untertitel und Timing danach abstimmen.

### B. Foto-/Trendanimation nach dem Umnik-Prinzip

```text
Eigenes, freigegebenes Foto
  -> Bewegung, Kamera, Stil, Dauer und Seed bearbeiten
  -> Ausschnitt und Storyboard pruefen
  -> kurze Image-to-Video-Szene rendern
  -> Bewegung/Identitaet kontrollieren
  -> optional Musik/Schnitt und manueller Export
```

[Editierbares Foto-Beispiel](../../examples/media-workflow/photo-trend.json).
Ein konkreter Trend kann besondere Bewegungsreferenzen oder ein anderes
Modell brauchen. Eine Texteingabe allein garantiert weder exakte Kamerapfade
noch konsistente Personen. Kein Face-Swap-Modell als Pflicht ergaenzen.

## Jetzt lokal nutzbar: Rezept pruefen, ohne Renderstart

[tools/media_workflow/plan.py](../../tools/media_workflow/plan.py),
Python >=3.10, nur Standardbibliothek. Vom Setup-Hauptverzeichnis:

```text
python -B tools/media_workflow/plan.py examples/media-workflow/photo-trend.json
python -B tools/media_workflow/plan.py examples/media-workflow/ugc-ad.json
```

Du kannst die JSON-Rezepte vorher im Editor anpassen. Der Planer liest nur
die angegebene Rezeptdatei und schreibt das Pruefergebnis auf die Konsole.
Er oeffnet keine referenzierten Bilder, startet keine Server, fuehrt Prompts
nicht aus und macht keine API-Aufrufe. Kein zusaetzlicher Menue-Installer.

| Feld | Anpassung / Begrenzung im Prototyp |
|---|---|
| project, workflow | Kurzer Projekt-Slug; ugc_ad oder photo_trend |
| script | Dein Text, maximal 8000 Zeichen; keine geheime Systemanweisung |
| seed | Ganzzahl 0 bis 4294967295; Reproduzierbarkeit haengt spaeter auch von Modell/Software ab |
| canvas | 256 bis 1280 Pixel je Achse, durch 16 teilbar; 8 bis 30 FPS |
| audio | none, existing mit source oder tts mit voice_ref |
| scenes | 1 bis 6 Szenen; static, image_to_video oder talking_head; 1 bis 8 Sekunden, gesamt maximal 30 |
| source | Relative assets/-Referenz, keine URL oder absolute Datei; Dateiinhalt und Existenz hier ungeprueft |
| prompt | Maximal 2000 Zeichen je Szene; keine freie Node-/Shell-Konfiguration |
| rights | Eigene Angaben zu Bild-/Audiofreigabe und kommerzieller Verwendung, kein Rechtsnachweis |

Diese Grenzen sind **Planungsbudgets**, keine modelluebergreifenden gueltigen
Inferenzparameter oder GPU-Zusagen. Modellabhaengige Frame-Anzahl, Aufloesung,
Sampler und Eingabeformat muss der spaetere Adapter validieren.
nominal_output_frames ist nur Sekunden mal Ausgabe-FPS, kein fertiger
Wan-Parameter.

Erfolgreiche Validierung liefert Exit-Code 0 und `status=review_required`,
**immer render_ready=false**. Fehler liefern Exit-Code 2 und starten nichts.
recipe_sha256 identifiziert den Rezeptinhalt, nicht die Assetdateien und
ist **keine Renderfreigabe**. Rechtefelder auf true setzen schaltet keinen
Renderer frei. Die geplante Ein-Job-Regel ist lediglich ausgegeben, noch
kein implementierter Worker/Lock.

## Noch zu bauen: Formular und abgesicherter Renderadapter

Fuer eine einfache Gradio-Oberflaeche dieselben Felder anbieten. Der Button
"Plan pruefen" darf nur validieren. Erst eine getrennte Aktion
"Diese Revision rendern" darf einen Job erzeugen. Jede Aenderung an Skript,
Stimme, Bild, Prompt oder Parameter verwirft die alte Freigabe. Ein Freigabe-
Datensatz muss spaeter Rezept-, Asset-, Modell- und Graph-Hashes binden.

Der Adapter verwendet einen **geprueften ComfyUI-API-Graph** und feste
Node-/Input-Zuordnungen. Normales GUI-Workflow-JSON ist nicht automatisch
ein passender API-Auftrag. Nur erwartete Felder ersetzen, Modell-/Node-
Allowlist verwenden; keine beliebigen hochgeladenen Graphen ausfuehren.
Custom Nodes sind ausfuehrbarer Python-Code, keine harmlosen Vorlagendaten.

ComfyUI nimmt Generierungsauftraege ueber `POST /prompt` an und liefert
Fehler oder eine prompt_id; das Einstellen ist bereits ein Renderauftrag,
kein reiner Preview-Check. Queue, Verlauf und Ergebnispruefung getrennt
behandeln. [Offizielle Server-Routen](https://docs.comfy.org/development/comfyui-server/comms_routes).
Hier ist kein solcher Submit-Adapter implementiert.

Vor echtem Betrieb fehlen unter anderem lokale Uploadvalidierung und
Asset-Hashes, authentifizierter Loopback-Zugang, eine persistente Queue
mit atomarem Ein-Job-Lock, Abbruch/Timeout, Speicher-/VRAM-Preflight,
modellbezogene Smoke-Tests und kontrollierte Montage/Dateiausgabe.
Keine automatischen Cloud-Fallbacks, Endlosschleifen oder Publikationen.
Teilresultate nicht als fertigen Film markieren; bestehende Nutzerdateien
bei Fehlern nicht loeschen. Ressourcenbedingte Abbrueche ins Joblog schreiben.

## RTX 5080, MiniPC und Speicher

Fuer deinen Host planen wir mit den bekannten **16 GB VRAM**, nicht mit den
generischen "High-End"-Eintraegen alter Tabellen. Kurzclips, kleine Vorschau-
aufloesung und **ein GPU-Job gleichzeitig** sind der sinnvolle Start.
LLM, TTS, Avatar und Video nicht gleichzeitig im VRAM halten.
MiniPC: Formular, Planung, Queue und kleine Montage; GPU-Arbeit bei Bedarf
explizit dem RTX-Host zuordnen, nicht automatisch externen Cloud-APIs.

Wan nennt einen niedrigen VRAM-Bedarf fuer **T2V-1.3B**; daraus folgt keine
gleich grosse Anforderung fuer den hier gewuenschten I2V-Pfad. Keine Renderzeit
aus RTX-4090-Werbewerten auf deine Hardware uebertragen.
[Wan-Referenz](https://github.com/Wan-Video/Wan2.1).
Gewichte, Caches, Offloading und Zwischenframes brauchen zusaetzlichen
RAM/SSD-Speicher; Windows-Speicher am VHDX-Standort separat pruefen.
[Bestehende Speicherplanung](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md).

## Lizenzen, Datenfluss und Werbung

- **n8n ist nicht pauschal OSI-Open-Source:** Sustainable Use License und
  Enterprise-Ausnahmen beachten. Selfhosting bedeutet nicht uneingeschraenkte
  Weitervermarktung. [Upstream-Lizenz](https://github.com/n8n-io/n8n/blob/master/LICENSE.md).
- **XTTS-v2:** Die verlinkten Gewichte stehen unter Coqui Public Model License
  mit nichtkommerziellen Einschraenkungen; nicht ungeprueft fuer Werbung
  einsetzen. Code-Lizenz ersetzt keine Gewichtslizenz.
  [Modelllizenz](https://huggingface.co/coqui/XTTS-v2/blob/main/LICENSE.txt).
- **InsightFace:** MIT-Code und vortrainierte Modelle haben unterschiedliche
  Bedingungen; Upstream nennt nichtkommerzielle Forschung fuer entsprechende
  Daten/Modelle. Kein pauschaler kommerzieller Face-Swap-Pfad.
  [Lizenzhinweise](https://github.com/deepinsight/insightface#license).
- Auch bei MuseTalk, Wan, Stimmen, Musik, Logos und Produktbildern die jeweils
  verwendeten Artefakte pruefen. Nur eigene oder ausreichend freigegebene
  Personen/Stimmen verwenden; keine erfundenen Testimonials produzieren.
- Lokal spart moeglicherweise API-Abos, nicht Strom, Hardware, Zeit und
  Wartung. Ein lokaler Graph mit Cloud-Nodes ist nicht vollstaendig offline.
  Kennzeichnung, Werbeaussagen und Personenrechte vor Veroeffentlichung
  fallbezogen pruefen; dieser Plan ist keine Compliance-Zertifizierung.

## Was geprueft wurde

Offline-Tests fuer beide Rezepte, Parsergrenzen, Aenderungs-Hashes und
ausgeschlossene Nebenwirkungen. Kein Film, GPU-/WSL-Start, Download,
Docker-Container, Providerkonto oder echter ComfyUI-Job wurde ausgefuehrt.

```text
python -B -m unittest discover -s tests -p test_media_workflow_plan.py -v
```
