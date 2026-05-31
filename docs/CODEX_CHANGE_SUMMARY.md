# Codex Change Summary

## Stand: 2026-05-31

Diese Zusammenfassung dokumentiert die letzte Next-Level-Erweiterung des Ultimate KI Setups. Ziel war: mehr Struktur, mehr Sicherheit, bessere Einsteigerfuehrung und keine riskanten Autoinstallationen.

## Geaenderte Dateien

| Datei | Aenderung |
| --- | --- |
| `config/profiles.yml` | Neue Profile als `planned` / `documentation-first` registriert. |
| `config/tools.yml` | Fehlende GitHub-Tool-Kandidaten als `planned` / `manual` ergaenzt. |
| `docs/GITHUB_TOOL_SOURCES.md` | Primaerquellen fuer neue Tool-Kandidaten dokumentiert. |
| `docs/TOOL_MATRIX.md` | Neue Tool-Kandidaten mit Ressourcen- und Risiko-Hinweis ergaenzt. |
| `docs/PROFILE_MATRIX.md` | Neue Next-Level-Profile in Matrix aufgenommen. |
| `docs/JOB_QUEUE_AGENT_WORKER.md` | Queue-Hinweise fuer schwere Aufgaben und Zielgeraete ergaenzt. |

## Neue Profile

- `AI_Model_Router_Gateway`
- `Voice_AI_Callcenter`
- `Email_AI_Office`
- `Observability_Control_Tower`
- `Security_BlueTeam_SOC`
- `Network_DDNS_ZeroTrust`
- `Media_Music_Video_Studio`

Alle neuen Profile sind bewusst nicht automatisch installierend. Sie bleiben `planned` oder `documentation-first`, bis sichere Installer, Uninstaller, Doctor-Checks, Portdoku, Ressourcenwerte und Rollback-Pfade vorhanden sind.

## Neue Tool-Kandidaten

- `paddleocr`
- `livekit`
- `asterisk`
- `beszel`
- `zeek`
- `falco`
- `stalwart`
- `sieve`

Alle neuen Tools verwenden GitHub-Quellen in der Registry und Stub-Installer. Das Setup installiert sie nicht automatisch.

## Offene Risiken

- Einige schwere Toolchains brauchen noch echte Resource-Preflight-Checks pro Tool.
- Security-/Monitoring-Tools wie Zeek und Falco duerfen nicht blind auf MiniPC/WSL2 installiert werden.
- Telefonie-Stacks wie Asterisk/LiveKit brauchen Port-, NAT-, TLS- und Missbrauchsschutz-Doku, bevor sie produktiv genutzt werden.
- Weitere Tools sollten schrittweise auf maschinenlesbare Quellen, Lizenzhinweise und Healthchecks vereinheitlicht werden.

## Bewusst planned/manual geblieben

- Voice-/Callcenter-Stacks
- Blue-Team-SOC-Komponenten
- GPU-/Medienpipelines
- Zero-Trust-/Reverse-Proxy-Erweiterungen
- Observability-Komplettstacks

## Naechste sinnvolle Schritte

1. `bash scripts/check_profiles.sh`
2. `bash scripts/check_tools.sh`
3. `bash scripts/check_ports.sh`
4. `bash scripts/validate_config.sh`
5. Danach fuer jedes schwere Tool einzeln Installer, Uninstaller, Doctor-Check und Rollback ergaenzen.
