# security_privacy

Status: `documentation-first`

## Zweck
Defensive Sicherheits- und Datenschutzpruefung fuer Setup, Repos, Ports, Secrets und Abhaengigkeiten.

## Modelle
- Lokal/Ollama: kleines lokales Modell fuer Zusammenfassungen
- Optional extern: nur anonymisierte Reports

## Tools
Gitleaks, TruffleHog, Trivy, Grype, Syft, Semgrep, UFW, Fail2ban, CrowdSec optional.

## Beispielprompt
`Pruefe diesen Diagnosebericht defensiv auf offene Ports, Secrets und riskante Defaults.`

## Sicherheitsregeln
Nur eigene Systeme oder autorisierte Ziele. Keine offensive Automation.

## Speicher-/Kostenkontrolle
Scans read-only starten. Container-Scans koennen dauern.

## Workflows
Secret-Scan -> Port-Audit -> Dependency-Scan -> Report -> Reparaturplan.

## OpenClaw-Agent
`security-doctor`: read-only, priorisiert Risiken und verlangt Freigabe fuer Aenderungen.
