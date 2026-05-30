# Voice Studio Workflows fuer n8n und Home Assistant

## n8n Workflow: Text zu Sprache
1. Webhook nimmt Text und Stimme entgegen.
2. OpenClaw prueft Rechte, Zielordner und Ressourcen.
3. Piper erzeugt schnelle WAV-Datei.
4. FFmpeg normalisiert und exportiert MP3.
5. Ergebnis wird lokal oder in Nextcloud/myNextCloud gespeichert.

## n8n Workflow: Text zu Hoerbuch
1. Text in Kapitel teilen.
2. Pro Kapitel Queue-Job erzeugen.
3. TTS-Ausgaben pruefen.
4. Kapitel-Metadaten und Markdown-Protokoll erstellen.

## n8n Workflow: Text zu Podcast
1. Skript aus Stichpunkten erzeugen.
2. Sprecherrollen zuweisen.
3. TTS-Drafts erzeugen.
4. Manuelle Freigabe einholen.
5. Export als MP3 plus Show Notes.

## n8n Workflow: Text zu Chor
1. Lyrics und Melodie erfassen.
2. SATB-Stimmen planen.
3. DiffSinger/OpenUtau/RVC-Schritte als geplante Jobs vorbereiten.
4. Mixdown nur nach manueller Freigabe starten.

## n8n Workflow: Text zu Song-Demo
1. Songidee erfassen.
2. Struktur: Intro, Verse, Chorus, Bridge.
3. Voice-/Singer-Tool auswaehlen.
4. Exportpfad und Kennzeichnung erzeugen.

## Home Assistant
- Piper ist Standard fuer lokale Sprachausgabe.
- Coqui TTS bleibt optional und wird nicht automatisch aktiviert.
- Automationen duerfen keine Stimmen klonen.
- Beispiel: Benachrichtigung bei abgeschlossenem Hoerbuch-Export.

```yaml
alias: Voice Studio Export fertig
trigger:
  - platform: webhook
    webhook_id: voice_studio_export_done
action:
  - service: notify.persistent_notification
    data:
      title: "Voice Studio"
      message: "Der lokale Audioexport ist fertig. Bitte vor Veroeffentlichung pruefen."
```

