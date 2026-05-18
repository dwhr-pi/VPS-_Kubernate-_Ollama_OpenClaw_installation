# n8n Workflows fuer OpenHiggsStack

Status: concept / optional  

## Grundprinzip

n8n soll Renderjobs nicht blind starten. Es verwaltet Warteschlangen, Benachrichtigungen, Freigaben, Dateipfade und Exporte. Modelle, Kosten und Cloud-APIs bleiben explizit kontrolliert.

## Prompt zu Storyboard zu Video

1. Webhook nimmt Prompt entgegen.
2. OpenClaw/Ollama erzeugt Storyboard.
3. Nutzer bestaetigt Modell und Kosten.
4. ComfyUI rendert Keyframes oder Video.
5. FFmpeg erzeugt Zielversion.
6. Ergebnis wird im Projektordner archiviert.

## Bild zu Video zu Musik zu Export

1. Produkt-/Charakterbild hochladen.
2. Storyboard Agent erstellt Motion-Idee.
3. Wan-I2V-Workflow erzeugt Clip.
4. Audio/Music Agent erzeugt Musik-/Voiceover-Konzept.
5. FFmpeg fuehrt Audio und Video zusammen.
6. Social Media Clip Agent erzeugt Titel, Beschreibung und Hashtags.

## Suno Song zu Musikvideo

1. Songdatei oder Songbeschreibung erfassen.
2. Lyrics/BPM/Mood analysieren.
3. Music Video Agent erstellt Szenenfolge.
4. ComfyUI/Wan rendert Szenen in niedriger Vorschau.
5. Nach Freigabe High-Quality-Render starten.
6. FFmpeg finalisiert Musikvideo.

## Produktfoto zu Werbeclip

1. Produktfoto in Projektordner speichern.
2. Hintergrund-/Keyframe-Prompt erzeugen.
3. Motion-Preset auswaehlen.
4. Export fuer 9:16, 1:1 und 16:9 erzeugen.
5. Optional Virality-/Hook-Check ausfuehren.

## Blogartikel zu Shorts-Serie

1. Blogartikel einlesen.
2. 5 Hooks extrahieren.
3. Je Hook ein Storyboard erzeugen.
4. Batch-Queue fuer Renderjobs anlegen.
5. Exporte und Beschreibungstexte erzeugen.

## TikTok/YouTube/Instagram Export-Vorbereitung

- TikTok: 9:16, kurzer Hook, schnelle Untertitel.
- YouTube Shorts: 9:16, klares Thema, Titelvarianten.
- Instagram Reels: 9:16, visuelle Konsistenz, Caption.
- Archiv: Masterdatei, Projekt-Metadaten, Prompts und Quellen sichern.

## Batch-Rendering mit Warteschlange

- Queue-Datei oder n8n-Datastore mit Status `planned`, `approved`, `rendering`, `done`, `failed`.
- Maximal parallele Jobs begrenzen.
- Speicherplatz vor jedem Job pruefen.
- Fehlerlog automatisch in `logs/` speichern.
- Optional Diagnose per E-Mail senden.
## Hugging Face / Huge_Facing in n8n

n8n sollte Hugging Face nicht ungefragt als Downloader fuer grosse Modelle verwenden. Sinnvoll ist eine Metadatenrolle: Modellname, Modellversion, Lizenz, lokaler Pfad, Quelle und Renderjob-ID werden pro Workflow gespeichert.

Empfohlene Workflow-Erweiterungen:

- Vor dem Renderjob pruefen, ob das benoetigte Modell lokal vorhanden ist.
- Bei fehlendem Modell nur einen Hinweis erzeugen, keinen automatischen Multi-GB-Download starten.
- `HUGGINGFACE_TOKEN` nur aus lokaler Env oder Credential-Verwaltung lesen.
- Modellquelle und Lizenz in den Export-Report schreiben.
