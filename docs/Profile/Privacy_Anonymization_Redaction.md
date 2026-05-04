# Privacy_Anonymization_Redaction

## Zweck
PII-Erkennung, Schwärzung und DSGVO-nahe Dokumentenverarbeitung.

## Typische Aufgaben
- PII-Erkennung in Texten
- OCR vor Redaction
- Dokumente für RAG anonymisieren
- Datenschutz-Prüfpipelines vorbereiten

## Empfohlene Tools
Microsoft Presidio, OCRmyPDF, Tesseract, Docling, Unstructured.

## Optionale Tools
Apache Tika, Paperless-ngx.

## Benötigte Ports
Keine Pflichtports.

## Ressourcenbedarf
4 bis 8 GB RAM, je nach OCR-Volumen mehr.

## Sicherheitsrisiken
Arbeitet direkt mit sensiblen Inhalten. Zwischenartefakte, Logs und Exporte besonders schützen.

## Ollama/OpenClaw-Fit
Sehr gut als Vorstufe für sichere Agenten- und RAG-Workflows.

## LiteLLM/Open WebUI-Fit
Wichtig vor Prompting mit sensiblen Dokumenten. Erst redigieren, dann modellieren.

## Quickstart
`bash scripts/profiles/Privacy_Anonymization_Redaction_install.sh`

## Deinstallation
`bash scripts/profiles/Privacy_Anonymization_Redaction_uninstall.sh`

## Sinnvolle lokale Modelle
Extraktions- und Zusammenfassungsmodelle nach vorgelagerter Anonymisierung.

## Grenzen und Warnhinweise
Automatische Redaction ist fehleranfällig. Bei kritischen Prozessen immer manuell gegenprüfen.
