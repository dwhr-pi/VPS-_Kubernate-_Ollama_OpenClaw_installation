# Ethical HackerGPT Runbook

## Erste Schritte

1. Profil-Doku lesen: [Ethical_HackerGPT.doc.md](./Ethical_HackerGPT.doc.md)
2. Scope klar festlegen
3. nur autorisierte Ziele in die Allowlist aufnehmen
4. Standardmodus auf `audit` belassen
5. Output-Verzeichnis fuer Reports pruefen

## Sichere Zieldefinition

Erlaubt sind nur:

- `127.0.0.1`
- `localhost`
- private RFC1918-Netze, wenn sie dir gehoeren
- eigene Domains und Hosts mit dokumentierter Freigabe
- lokale oder isolierte Lab-Systeme

Nicht erlaubt ohne ausdrueckliche Freigabe:

- fremde Domains
- fremde VPS oder Webapps
- oeffentliche IP-Ranges
- Drittanbieter-Systeme

## Erlaubte lokale Tests

- Host- und Port-Uebersicht eigener Systeme
- Secret-Scans auf eigenen Repositories
- Dependency- und SBOM-Pruefungen
- Container- und Dateisystem-Scans
- Header- und TLS-Pruefungen eigener Webdienste
- Baseline-Webscans gegen `localhost` oder autorisierte interne Ziele

## Report-Erstellung

Empfohlenes Format:

1. Scope
2. Zeitstempel
3. Tools
4. Findings
5. Risiko
6. Beweis
7. Empfehlung
8. Fix-Kommandos
9. Prioritaet
10. Nachtest

## Update- und Patch-Workflow

1. Findings priorisieren
2. schnelle Fixes zuerst
3. Pakete, Images oder Configs aktualisieren
4. nach Patch erneut pruefen
5. Report mit Nachtest aktualisieren

## Notfallmodus bei verdaechtigen Logs

Wenn auffaellige Logs oder Indicators auftauchen:

1. keine Panik-Automation ausloesen
2. betroffene Systeme eingrenzen
3. relevante Logs sichern
4. oeffentliche Freigaben pruefen
5. SSH-, Firewall-, Fail2Ban- und Tunnel-Konfiguration kontrollieren
6. nur defensive Massnahmen dokumentiert ausfuehren

## Grenzen des Profils

- keine offensiven Aktionen gegen fremde Ziele
- keine Persistenz- oder Evasion-Techniken
- keine Credential-Exfiltration
- keine Malware
- kein automatischer Scope-Creep ueber die Allowlist hinaus
