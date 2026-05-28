# system_doctor

Status: `documentation-first`

## Zweck
Zentrale Diagnose fuer Setup, WSL2, Speicher, Ports, Docker, OpenClaw, Ollama und Tool-Status.

## Modelle
- Lokal/Ollama: Log-Zusammenfassung
- Optional extern: nicht noetig

## Tools
`scripts/doctor.sh`, `scripts/preflight.sh`, `scripts/check_ports.sh`, `scripts/check_tools.sh`, `scripts/next_level_dry_run_check.sh`.

## Beispielprompt
`Analysiere diesen lokalen Doctor-Bericht und priorisiere die naechsten drei sicheren Reparaturschritte.`

## Sicherheitsregeln
Keine Reparaturen ohne Freigabe. Keine Secrets in Diagnoseberichte schreiben.

## Speicher-/Kostenkontrolle
Checks sollen schnell sein; Vollscans nur explizit.

## Workflows
Preflight -> Doctor -> Portcheck -> Registrycheck -> Report -> Reparaturplan.

## OpenClaw-Agent
`system-doctor`: read-only Diagnose, Reparatur nur mit Human Approval.
