# Security_BlueTeam

Status: `documentation-first`

## Zweck
Defensive Analyse von Logs, Ports, Secrets, Abhaengigkeiten und Host-Hardening.

## Typische Aufgaben
Secret-Scan, Port-Audit, Trivy/Grype/Syft-Reports, Fail2ban/CrowdSec-Auswertung.

## Empfohlene Tools
Gitleaks, TruffleHog, Trivy, Grype, Syft, Semgrep, UFW, Fail2ban, CrowdSec.

## Erlaubte Aktionen
Read-only Scans, Findings priorisieren, Reparaturvorschlaege.

## Verbotene/gefaehrliche Aktionen
Keine offensiven Tests, keine fremden Ziele, keine Exploit-Automation.

## Umgebungsvariablen
Keine Secrets erforderlich. Optional `SECURITY_REPORT_DIR`.

## Beispiel-Prompts
`Pruefe diesen Logauszug defensiv und priorisiere die wahrscheinlichsten Risiken.`

## Modellvorschlaege
Ollama lokal; Cloud nur mit anonymisierten Reports.

## Speicherort
`~/.openclaw_ultimate_user_data/reports/security_blueteam`
