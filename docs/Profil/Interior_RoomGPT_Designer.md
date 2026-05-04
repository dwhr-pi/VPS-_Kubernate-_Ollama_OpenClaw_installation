# Fachprofil: Interior_RoomGPT_Designer

## Kurzbeschreibung

Dieses Profil beschreibt einen KI-gestuetzten Interior-, Renovierungs- und Home-Staging-Agenten fuer das bestehende Ollama/OpenClaw/Kubernetes/VPS-Setup. Der Agent analysiert Raumfotos, erkennt Raumtyp, Stil und visuelle Probleme, erstellt passende Prompts und erzeugt realistische Vorher-/Nachher-Varianten fuer Modernisierung, Aufraeumen, Umstellen und virtuelle Renovierung.

Der Fokus liegt auf lokalem oder selbst gehostetem Arbeiten mit:

- `Ollama` fuer Textanalyse, Stilberatung und Prompt-Erzeugung
- `OpenClaw` fuer Agentensteuerung und Workflow-Logik
- `Stable Diffusion` oder `SDXL` fuer Bildvarianten
- `ControlNet` fuer strukturerhaltende Aenderungen
- `Inpainting` fuer gezielte Eingriffe
- `ComfyUI` oder `AUTOMATIC1111` fuer lokale Bildpipelines

`roomGPT` dient hier als Open-Source-Inspiration fuer Upload, Stilwahl und Vorher-/Nachher-Vergleich. Laut dem offiziellen Repository nutzt die fruehe Open-Source-Version `ControlNet`, eine `Next.js`-App, `Replicate` fuer die Modell-Ausfuehrung und `Bytescale` fuer Bild-Storage. Fuer dieses Repo soll der bevorzugte Standard jedoch lokal bleiben, mit Cloud nur als bewusstem Fallback. Quellen: [roomGPT](https://github.com/Nutlope/roomGPT), [ComfyUI ControlNet](https://docs.comfy.org/tutorials/controlnet/controlnet), [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui), [ControlNet](https://github.com/lllyasviel/ControlNet)

## Typische Aufgaben des Agents

- Raumfotos analysieren und Raumtyp erkennen
- visuelle Unordnung, schlechte Lichtwirkung und Problemzonen benennen
- Einrichtungsvorschlaege fuer vorhandene Moebel erstellen
- Moebel virtuell neu anordnen
- kleine Budget-Upgrades vorschlagen
- virtuelle Renovierungen testen
- Stilvarianten fuer Verkauf, Airbnb oder Modernisierung erzeugen
- Vorher-/Nachher-Vergleiche exportieren
- Projektordner mit Bildern, Prompts und Varianten sauber ablegen

## Einsatzgebiete

- Wohnzimmer modernisieren
- Schlafzimmer aufraeumen und umgestalten
- Kueche optisch verbessern
- Bad renovieren
- Airbnb- oder Immobilien-Staging
- kleine Wohnungen platzsparend optimieren
- Haeuserfassaden optisch aufwerten
- Garten, Terrasse oder Balkon gestalten

## Betriebsmodi

### 0-Euro-Modus

- nur vorhandene Moebel und Gegenstaende verwenden
- Fokus auf Umstellen, Sortieren, Lichtwirkung und visuelle Balance
- gut fuer kleine Wohnungen, Mietobjekte und schnelle Verbesserungen

### Decluttering-Modus

- visuelle Unordnung reduzieren
- Oberflaechen beruhigen
- Stauraum-Ideen und Sortierlogik hervorheben
- keine oder nur minimale neue Gegenstaende hinzufuegen

### Re-Arrangement-Modus

- vorhandene Moebel neu anordnen
- Laufwege, Licht, Sichtachsen und Nutzbarkeit verbessern
- besonders sinnvoll bei beengten Grundrissen

### Budget-Modus

- kleine Ergaenzungen wie Licht, Pflanzen, Teppiche, Vorhaenge oder Regale
- realistische und bezahlbare Upgrades

### Renovierungsmodus

- Wandfarben, Boeden, Materialien, Leuchten und Oberflaechen virtuell erneuern
- Struktur und Perspektive moeglichst realistisch erhalten

### Luxus- oder High-End-Modus

- hochwertigere Materialien, moeblierte Zielbilder und architektonisch saubere Upgrades
- nur sinnvoll, wenn bewusst gewuenscht und nicht irrefuehrend fuer reale Angebote

### Verkaufs- oder Airbnb-Staging-Modus

- heller, neutraler, ordentlicher und einladender Look
- Fokus auf Flaechenwirkung, Weite und Suchlisten-taugliche Bildsprache

## Benoetigte Komponenten

### Kernkomponenten im vorhandenen Setup

- `Ollama`
  - fuer Raumanalyse, Stilinterpretation und Prompt-Erzeugung

- `OpenClaw`
  - fuer Agentensteuerung, Freigabeschritte, Prompt-Ketten und Dateiorganisation

- `Stable Diffusion` oder `SDXL`
  - fuer die eigentliche Bildgenerierung oder Bildtransformation

- `ControlNet`
  - fuer strukturerhaltende Raumtransformationen auf Basis des Originalfotos

- `Inpainting`
  - fuer gezielte Bearbeitung einzelner Bereiche wie Wand, Boden, Sofa oder Deko

- `ComfyUI` oder `AUTOMATIC1111`
  - als lokale Bildpipeline mit ControlNet- und Inpainting-Unterstuetzung

### Optionale Komponenten

- `roomGPT`
  - als Web-UI-Inspiration fuer Upload, Stilwahl und Ergebnisvergleich
  - das Repo nutzt in seiner Open-Source-Version Cloud-Bausteine und ist daher eher Referenz als direkter Standardpfad

- `Replicate API`
  - nur als bewusst aktivierter Cloud-Fallback
  - sinnvoll, wenn lokal keine GPU verfuegbar ist oder nur testweise verglichen werden soll

- `Next.js`-Frontend
  - sinnvoll fuer Upload, Stilwahl, Prompt-Vorschau und Vorher-/Nachher-Vergleich

- `Open WebUI`
  - als niederschwellige Chat-Oberflaeche fuer Stilberatung, Prompt-Ideen und Projektplanung

## Lokale Architektur

### 1. Foto-Upload

- Upload ueber Web-Oberflaeche oder Projektordner
- Original bleibt erhalten
- Arbeitskopie wird fuer Analyse und Maskierung vorbereitet

### 2. Datenschutz-Preprocessing

- EXIF-Daten entfernen
- Gesichter optional unkenntlich machen
- Dokumente, Adressen, Familienfotos oder Kennzeichen optional maskieren
- nur danach Verarbeitung freigeben

### 3. Bildanalyse

- grobe Raumtyp-Erkennung: Wohnzimmer, Schlafzimmer, Bad, Kueche, Aussenbereich
- Erkennung von visueller Unordnung, Lichtproblemen, Stilbruch und Nutzungskonflikten

### 4. Stil-Auswahl

- modern
- warm-minimal
- skandinavisch
- industrial
- neutral fuer Verkauf oder Airbnb
- boho, japandi, klassisch oder andere Zielstile

### 5. Prompt-Generierung

- `Ollama` erzeugt systematische Positiv- und Negativ-Prompts
- Modus, Budget und Restriktionen werden in den Prompt eingebaut

### 6. ControlNet- oder Inpainting-Ausfuehrung

- `ControlNet` haelt Struktur, Perspektive und Raumgeometrie moeglichst stabil
- `Inpainting` aendert nur definierte Bildbereiche
- mehrere Varianten pro Stil oder Modus erzeugen

### 7. Vorher-/Nachher-Vergleich

- Side-by-Side-Ausgabe
- Versionsvergleich nach Modus
- Export als JPG oder PNG

### 8. Export und Ablage

- Bilder, Prompts, Masken und Metadaten projektbezogen speichern
- optionale Markdown-Zusammenfassung mit Stil- und Budgethinweisen

## Sinnvolle Projektstruktur

```text
projects/interior-roomgpt/
  uploads/
  sanitized/
  masks/
  prompts/
  outputs/
  compare/
  reports/
  logs/
  exports/
```

Optional ergaenzbar:

```text
projects/interior-roomgpt/
  styles/
  budgets/
  staging/
  renovation/
```

## Betriebsmodelle fuer Hardware

### Lokaler Home-Server-Modus

- bevorzugter Standard
- gut fuer Datenschutz, Bildablage und lokale Modelle
- ideal mit MiniPC oder GPU-Workstation

### GPU-Modus

- beste Qualitaet und Geschwindigkeit fuer SDXL, ControlNet und Inpainting
- sinnvoll fuer groessere Bilder, mehrere Varianten und feinere Prompts

### CPU-Only-Modus

- moeglich fuer textnahe Analyse mit `Ollama`
- Bildpipeline deutlich langsamer
- eher fuer kleine Testbilder, Prompting und Voranalyse

### Low-Budget-VPS-Modus

- sinnvoll fuer Steuerung, Upload, OpenClaw, Open WebUI und Projektverwaltung
- Bildsynthese lokal oder ueber bewusst aktivierten Cloud-Fallback auslagern

## Datenschutz und Sicherheit

Wohnungs- und Raumfotos koennen sensible private Informationen enthalten. Deshalb gilt:

- standardmaessig lokale Verarbeitung bevorzugen
- EXIF-Daten vor der weiteren Nutzung entfernen
- Gesichter, Dokumente, Adressen, Bildschirme und andere private Details optional maskieren
- Cloud-Dienste nur nach bewusster Aktivierung nutzen
- keine ungeprueften Fotos automatisch an externe APIs senden
- private Projektfotos getrennt von oeffentlichen Exporten speichern
- Logging und Vorschaudaten minimieren

Besonders wichtig:

- Fotos aus bewohnten Raeumen koennen Hinweise auf Personen, Tagesablaeufe, Besitzverhaeltnisse oder Sicherheitsniveau enthalten
- bei Immobilien-, Airbnb- oder Maklerbildern keine irrefuehrenden Renovierungsbilder ohne klare Kennzeichnung als Visualisierung verwenden

## Beispiel-Prompts

### A) Nur vorhandene Moebel verwenden

```text
Declutter and restyle this room using only the existing furniture and items. Do not add new furniture. Keep the original room structure and perspective. Improve organization, lighting, visual balance, and make it look clean, modern, realistic and practical.
```

### B) Moebel neu anordnen

```text
Rearrange the existing furniture to improve space, flow and comfort. Use only visible furniture and objects. Keep the same room and perspective. Make the room feel more open, organized and cozy.
```

### C) Modernisieren

```text
Transform this room into a modern, warm and minimal interior. Keep the original layout and architectural structure. Use neutral colors, better lighting, clean surfaces and realistic materials.
```

### D) Renovieren

```text
Virtually renovate this room with new flooring, fresh wall colors, improved lighting and modern materials. Keep the room dimensions and perspective realistic.
```

### E) Airbnb- oder Home-Staging

```text
Stage this room for a real estate or Airbnb listing. Make it bright, clean, inviting and modern. Use a realistic, neutral style and improve perceived space.
```

### Zusaetzliche Vorlage: Balkon oder Terrasse

```text
Restyle this balcony or terrace to feel more open, calm and welcoming. Keep the same architecture and proportions. Use realistic outdoor materials, practical furniture placement and a balanced modern aesthetic.
```

### Zusaetzliche Vorlage: Kleine Wohnung platzsparend optimieren

```text
Optimize this small room for better space usage without changing the architecture. Keep the existing layout and perspective. Improve storage logic, walking space, light distribution and visual calm while keeping the result realistic and livable.
```

## Negative Prompts

```text
unrealistic, distorted furniture, impossible architecture, extra doors, extra windows, warped perspective, messy artifacts, fake shadows, cartoon, overdesigned, luxury items not requested
```

Optional erweiterbar:

```text
duplicate furniture, floating objects, broken geometry, inconsistent lighting, fake reflections, overexposed, underexposed, surreal decor, plastic textures, exaggerated staging
```

## Empfehlung fuer den Agenten-Workflow

1. Foto importieren
2. EXIF entfernen und sensible Bereiche pruefen
3. Raumtyp bestimmen
4. Betriebsmodus waehlen
5. Stil und Budget definieren
6. Prompt und Negative Prompt erzeugen
7. ControlNet oder Inpainting anwenden
8. 3 bis 6 Varianten speichern
9. Vorher-/Nachher-Vergleich exportieren
10. optional kurze textliche Empfehlung durch `Ollama` erzeugen

## Grenzen

- ersetzt keine Fachplanung fuer Statik, Elektro, Wasser oder Brandschutz
- ersetzt keine echte Renovierungskostenkalkulation
- ersetzt keine professionelle Bau- oder Innenarchitekturberatung
- sollte keine unrealistischen Immobilienbilder ohne Kennzeichnung erzeugen
- sollte bei bewohnten Raeumen sehr datensparsam arbeiten

## Passung zum vorhandenen Repo

Dieses Profil ergaenzt besonders:

- `Image_Generation.doc.md`
- `Visual_Creator.doc.md`
- `Content_Automation.doc.md`
- `Compliance_Privacy.doc.md`

Es doppelt diese Profile nicht, sondern spezialisiert sie auf:

- Raumfoto-Analyse
- virtuelle Modernisierung
- Decluttering
- Home-Staging
- strukturtreue Innenraum- und Fassadenvarianten
