# business_office

Status: `documentation-first`

## Zweck
Lokale Office-, Dokumenten-, E-Mail- und Wissensworkflows fuer Alltag und Business.

## Modelle
- Lokal/Ollama: `llama3.2:1b` fuer Entwuerfe/Zusammenfassungen
- Optional extern: nur fuer freigegebene, nicht-private Inhalte

## Tools
LibreOffice CLI, Pandoc, Stirling PDF, Paperless-ngx, Tesseract/OCRmyPDF, n8n optional.

## Beispielprompt
`Fasse dieses Dokument lokal zusammen und erstelle eine Aufgabenliste ohne externe Dienste.`

## Sicherheitsregeln
Keine personenbezogenen Daten an Cloud-Modelle senden. E-Mails nicht automatisch versenden.

## Speicher-/Kostenkontrolle
OCR- und PDF-Jobs koennen CPU-lastig sein; Stapelgroessen begrenzen.

## Workflows
Dokument -> OCR -> Summary -> Aufgaben -> Archiv/Tags.

## OpenClaw-Agent
`office-assistant`: erstellt Entwuerfe und Reports, Versand nur mit Freigabe.
