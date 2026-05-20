# OpenHiggsStack n8n Workflow-Ideen

Diese Workflows sind Konzeptvorlagen. Sie sollen nicht automatisch API-Keys oder Uploads aktivieren.

## Prompt -> Storyboard -> Video

1. Webhook oder manuelle Eingabe.
2. OpenClaw/Ollama erstellt Storyboard.
3. ComfyUI erzeugt Keyframes.
4. Wan2.x erzeugt kurze Clips.
5. FFmpeg kombiniert Clips.
6. Ergebnis wird lokal archiviert.

## Bild -> Video -> Musik -> Export

1. Produkt- oder Charakterbild ablegen.
2. Image-to-Video-Workflow starten.
3. Musik oder Voiceover hinzufuegen.
4. FFmpeg normalisiert Format.
5. Exportordner pro Plattform erzeugen.

## Suno Song -> Musikvideo

1. Songdatei und Lyrics importieren.
2. Agent erstellt Szenen entlang der Songstruktur.
3. ComfyUI/Wan rendert Shots.
4. FFmpeg synchronisiert Audio und Video.
5. Thumbnail und Caption werden erzeugt.

## Produktfoto -> Werbeclip

1. Produktfoto validieren.
2. Marketing-Hook generieren.
3. 3-5 kurze Szenen planen.
4. Image-to-Video rendern.
5. Kurzclip fuer TikTok/YouTube Shorts vorbereiten.

## Blogartikel -> Shorts-Serie

1. Artikel in Kernaussagen zerlegen.
2. Pro Aussage einen Clip planen.
3. Voiceover-Text erzeugen.
4. Visuals und Untertitel generieren.
5. Batch-Export vorbereiten.

## TikTok/YouTube/Instagram Export-Vorbereitung

1. Plattformprofil waehlen.
2. Format, Laenge, Bitrate und Caption setzen.
3. FFmpeg-Exportjobs erzeugen.
4. Upload bleibt manuell oder separat bestaetigungspflichtig.

## Batch-Rendering mit Warteschlange

1. Renderjobs als JSON/Markdown ablegen.
2. n8n liest Queue.
3. Nur ein Renderjob gleichzeitig auf Low-VRAM-Systemen.
4. Nach jedem Job Speicher und Fehlerlog pruefen.
5. Diagnose-Mail optional nur mit Logauszug, nie mit API-Keys.

