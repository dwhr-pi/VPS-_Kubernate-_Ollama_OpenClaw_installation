# Email_Calendar_Office_Agent

## Zweck
Lokaler Office-Agent für Dokumente, Termine, Kalender, Aufgaben und persönliche Wissensarbeit.

## Typische Aufgaben
- Kalender-/Kontakt-Sync
- Aufgaben- und Terminverwaltung
- PDF- und Dokumentenablage
- DMS-nahe Office-Automation

## Empfohlene Tools
Radicale, Vikunja, Paperless-ngx, Nextcloud, Stirling PDF, Apache Tika.

## Optionale Tools
Pandoc, Tesseract, OCRmyPDF.

## Benötigte Ports
`3456`, `5232`, `8010`, `8081`, `8082`, `9998`

## Ressourcenbedarf
4 bis 8 GB RAM empfohlen.

## Sicherheitsrisiken
Mails, Kontakte, Termine und Dokumente sind hochsensibel. Nur lokal oder mit sauberer Auth-/Proxy-Schicht freigeben.

## Ollama/OpenClaw-Fit
Gut für lokale Office-Helfer und DMS-gestützte Agentenaufgaben.

## LiteLLM/Open WebUI-Fit
Hilfreich für Chat-Assistenz über lokale Dokumente und Office-Wissensbestände.

## Quickstart
`bash scripts/profiles/Email_Calendar_Office_Agent_install.sh`

## Deinstallation
`bash scripts/profiles/Email_Calendar_Office_Agent_uninstall.sh`

## Sinnvolle lokale Modelle
Allround-Modelle für Zusammenfassungen, Extraktion und To-do-Erstellung.

## Grenzen und Warnhinweise
Kein Default für öffentliche Mail-/Kalender-Freigaben. Zugriff immer absichern.
