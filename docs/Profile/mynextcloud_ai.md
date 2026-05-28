# myNextCloud AI

## Zweck
`myNextCloud AI` verbindet den vorbereiteten Server-Fork `myNextCloud Server` und die Android-App `myNextCloud Mobile` mit Ollama, OpenClaw, n8n, Whisper, Home Assistant, Cloudflare Access und optional Tailscale.

## Rechtlicher Hinweis
Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.

Nextcloud Server ist AGPL-lizenziert, die Android-App ist GPL-lizenziert, die Android Library ist MIT-lizenziert. Lizenztexte und Copyright-Hinweise muessen erhalten bleiben. Bei oeffentlichem Betrieb eines modifizierten AGPL-Servers muss der passende Quellcodezugang dokumentiert werden.

## Lokale Datei-KI
- PDF-Zusammenfassung
- Bildbeschreibung
- OCR optional
- Audio-Transkription ueber Whisper
- automatische Tags
- semantische Suche
- private Knowledge Base

## Konzept
Datei-Upload -> myNextCloud Hook -> n8n Workflow -> Ollama Analyse -> Ergebnis als Markdown/JSON zurueck in myNextCloud speichern.

## Empfohlene Tools
Ollama, OpenClaw, n8n, Whisper.cpp/faster-whisper, Qdrant/ChromaDB, Paperless-ngx optional, Cloudflare Access, Tailscale.

## Modelle
- Test: `llama3.2:1b`
- Qualitaet: vorhandenes lokales `llama3:latest` oder aehnliches Modell

## OpenClaw-Agenten
- `myNextCloud_File_Agent`: neue Dateien erkennen, zusammenfassen, taggen.
- `myNextCloud_Admin_Agent`: Speicherplatz, Updates, Backups und Fehlerberichte pruefen.
- `myNextCloud_Security_Agent`: Uploads defensiv pruefen, Hashes vergleichen, lokale Scanner bevorzugen.
- `myNextCloud_Media_Agent`: Bilder, Musik, Videos und Metadaten analysieren, Whisper fuer Audio nutzen.

## Sicherheitsgrenzen
Keine produktiven Secrets im Repo. Keine oeffentlichen Admin-Ports. Admin-Zugriff bevorzugt via Tailscale. Oeffentlicher Zugriff nur via Cloudflare Access/WAF/Rate-Limits.

## Beispiel-Prompt
`Analysiere neue myNextCloud-Dateien lokal, erstelle kurze Zusammenfassungen, Tags und einen Sicherheitsstatus. Speichere Ergebnisse nur als Markdown/JSON im konfigurierten Summary-Ordner.`
