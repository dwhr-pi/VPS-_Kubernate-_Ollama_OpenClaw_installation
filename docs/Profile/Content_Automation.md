# Profil: Content Automation

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Content_Automation.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Content_Automation.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Profil für automatisierte Content-Pipelines von Skript über Audio und Video bis zum Upload.

## Installierter Stack

- Basis: `python3`, `python3-pip`, `python3-venv`, `nodejs>=22`, `pnpm`
- Bereits als einzelne Tools installierbar:
  - FFmpeg systemweit
  - Whisper unter `/opt/whisper`
  - Playwright unter `/opt/playwright`
  - n8n unter `/opt/n8n`
  - Activepieces unter `/opt/activepieces`
  - Piper unter `/opt/piper`
  - Coqui_TTS unter `/opt/coqui_tts`
  - YT_DLP unter `/opt/yt_dlp`
  - Stable_Diffusion_WebUI unter `/opt/stable-diffusion-webui`
  - Trend_Monitor unter `/opt/trend_monitor`

## Dokumentierte zusätzliche Tools

Die zuvor nur dokumentierten Zusatzbausteine sind jetzt als Setup-Module vorhanden:

- `Thumbnail_Pipeline`
- `Upload_Automation`

## Verantwortlichkeiten

- Content-Skripte erzeugen
- Voiceover vorbereiten
- Video schneiden und zusammenbauen
- Assets für Upload-Pipelines vorbereiten
- Shorts- und YouTube-Workflows automatisieren

## Verfügbare Kommandos

```bash
scripts/tools/ffmpeg_install.sh
scripts/tools/whisper_install.sh
scripts/tools/playwright_install.sh
scripts/tools/n8n_install.sh
scripts/tools/activepieces_install.sh
scripts/tools/piper_install.sh
scripts/tools/coqui_tts_install.sh
scripts/tools/yt_dlp_install.sh
scripts/tools/stable_diffusion_webui_install.sh
scripts/tools/trend_monitor_install.sh
```

## Beispielprompts

### Pipeline Prompt

```txt
Plane eine Content-Automation-Pipeline:
Input -> Skript -> Audio -> Video -> Upload.
Nutze lokale Tools, wo möglich, und gib mir die Schritte als OpenClaw-Workflow aus.
```

### Shorts Automation

```txt
Erstelle einen Workflow für TikTok oder Shorts:
Thema analysieren, Skript erzeugen, Voiceover vorbereiten, Video schneiden und Export-Schritte definieren.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als Pipeline-Orchestrator.
- `FFmpeg` deckt den Videoschnitt-Baustein ab.
- `Whisper` hilft bei Transkript- und Audio-Vorarbeit.
- `Playwright`, `n8n` und `Activepieces` sind gute Grundlagen für Automatisierung und Browser-/Upload-Schritte.
- `Piper`, `Coqui_TTS`, `YT_DLP` und `Stable_Diffusion_WebUI` ergänzen jetzt TTS, Quellbeschaffung und visuelle Asset-Erstellung.
- `Trend_Monitor` ergänzt Themenradar und Feed-basierte Content-Vorbereitung.

## Vergleich

### ✅ In Sync

- `ffmpeg` aus der Quelle ist bereits installierbar.
- Die Workflow-Seite lässt sich mit `n8n`, `Activepieces` und `Playwright` bereits teilweise abbilden.
- `Piper`, `Coqui_TTS`, `YT_DLP` und `Stable_Diffusion_WebUI` sind jetzt ebenfalls als echte Bausteine vorhanden.
- `Trend_Monitor` ist jetzt als Recherche- und Trendmodul installierbar.

### ⚠ Missing in Setup

- Die zuvor fehlenden Thumbnail- und Upload-Bausteine sind jetzt direkt installierbar.
- Offen bleibt nur eine vollständig produktionsfertige End-to-End-Verdrahtung mit echten Zielplattform-Credentials.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang nicht als eigene Profilseite vorhanden.

## Hinweise

- Das Profil ist aktuell eher ein orchestrierbares Baukastensystem als eine fertig vorkonfigurierte Content-Fabrik.
