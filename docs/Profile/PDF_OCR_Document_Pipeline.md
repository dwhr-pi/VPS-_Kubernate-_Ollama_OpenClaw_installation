# PDF_OCR_Document_Pipeline

## Zweck
Lokale PDF-, OCR- und Dokumentenverarbeitung fuer RAG und Archivierung.

## Typische Aufgaben
- PDFs OCR-faehig machen.
- Dokumente extrahieren, verschlagworten und indexieren.
- Metadaten und Datenschutzrisiken pruefen.

## Empfohlene Tools
OCRmyPDF, Tesseract, Apache Tika, Docling, Stirling PDF, Paperless-ngx, Qdrant.

## Hardwarebedarf und Status
Hardware: mittel. Status: optional. Installationsart: local, WSL2, Home-Server.

## Datenschutz und Sicherheit
Dokumente koennen PII, Verträge und Finanzdaten enthalten. Standard: lokal-first.

## Beispiel-Prompt
`Plane eine lokale OCR-Pipeline fuer gescannte PDFs mit spaeterer Qdrant-Suche.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5:7b`.

## Grenzen
Keine externe OCR/Cloud ohne vorherige Freigabe.
