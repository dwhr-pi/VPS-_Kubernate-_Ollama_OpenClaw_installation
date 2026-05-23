# Local AI Office Suite

Status: `planned`  
Hardwarebedarf: `low` bis `medium`  
Installationsart: lokal, WSL2, Linux-PC, VPS optional

## Zweck

Lokale Office- und Dokumenten-KI fuer PDFs, Tabellen, Briefe, OCR, Zusammenfassungen und strukturierte Dokumentenablage.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| LibreOffice CLI | Headless-Konvertierung, Serienbriefe, Office-Export | geplant |
| Pandoc | Markdown, DOCX, HTML, PDF-Konvertierung | empfohlen |
| Tesseract OCR | OCR fuer Scans und Bilder | empfohlen |
| Stirling PDF | Lokale PDF-Werkzeuge | optional |
| Paperless-ngx | Dokumentenarchiv | optional, schwerer Stack |
| Docling | PDF-/Office-Strukturimport fuer RAG | empfohlen |

## OpenClaw-Agenten

- Dokumenten-Pruefer: extrahiert Kernaussagen, Fristen und To-dos.
- OCR-Operator: erkennt schlechte Scans und schlaegt bessere Einstellungen vor.
- Office-Automation-Agent: erzeugt Briefe, Tabellen und Markdown-Exports.

## Sicherheitsregeln

- Standard: lokale Verarbeitung, keine Cloud-Uebertragung.
- Keine echten Ausweise, Verträge oder medizinischen Unterlagen an externe APIs senden.
- Dokumentenordner nur mit expliziter Freigabe in RAG-Indizes aufnehmen.

## Naechste Schritte

- Installer fuer LibreOffice CLI, Pandoc und Tesseract pruefen.
- Paperless-ngx als optionalen Docker-/Compose-Pfad klar kennzeichnen.
