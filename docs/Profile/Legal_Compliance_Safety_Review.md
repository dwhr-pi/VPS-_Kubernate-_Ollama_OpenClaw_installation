# Legal Compliance Safety Review

Status: `planned`  
Hardwarebedarf: `low` bis `medium`  
Installationsart: lokal, CI, WSL2, VPS

## Zweck

Sichere Nutzung fuer Recht, Datenschutz, Urheberrecht, Lizenzen, Impressum und Open-Source-Compliance. Keine Rechtsberatung, sondern Pruef- und Dokumentationsassistenz.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| reuse/licensee | Lizenzpruefung | empfohlen |
| scancode-toolkit | umfassende OSS-Compliance | optional, schwer |
| gitleaks/detect-secrets | Secret-Pruefung | empfohlen |
| Semgrep | Policy- und Code-Regeln | empfohlen |

## Sicherheitsregeln

- Keine verbindliche Rechtsberatung behaupten.
- Datenschutz- und Lizenzbefunde als Hinweise mit Quellen darstellen.
- Human-Approval fuer Veroeffentlichungen und Policy-Aenderungen.
