# legal_license_checker

Status: `documentation-first`

## Zweck
Lizenz-, Datenschutz-, Impressums- und Compliance-Hinweise strukturiert pruefen. Keine Rechtsberatung.

## Modelle
- Lokal/Ollama: Zusammenfassung und Checklisten
- Optional extern: nur anonymisierte Texte

## Tools
Gitleaks, scancode-toolkit optional, reuse, licensee, Trivy/Syft fuer SBOM.

## Beispielprompt
`Erstelle eine nicht-rechtsverbindliche Lizenz-Checkliste fuer dieses Open-Source-Projekt.`

## Sicherheitsregeln
Keine Rechtsberatung behaupten. Unsichere Punkte als TODO markieren.

## Speicher-/Kostenkontrolle
Scans read-only und lokal. Grosse Repos mit Timeout pruefen.

## Workflows
Repo -> Lizenzscan -> Copyright-Hinweise -> Risiko-Liste -> TODOs.

## OpenClaw-Agent
`license-checker`: erstellt Checklisten, keine juristischen Endentscheidungen.
