# mail-control-panel Backend

Das Backend ist die geplante Integrationsschicht zwischen Stalwart,
OpenClaw/Ollama und dem spaeteren Webinterface.

## Ziel

Stalwart bleibt Upstream. Das Backend kapselt nur:

- Stalwart Management/JMAP/API
- Mailbox-Management
- Alias-Management
- IMAP-Import
- Audit-Logging
- KI-Agent-Freigabeprozess

## Bevorzugte Technik

- Node.js/TypeScript oder Rust
- `.env.example` statt echter `.env`
- keine Passwoerter im Klartext loggen
- API-Keys nur in `~/.openclaw_ultimate_user_data/mail`

## Module

| Modul | Aufgabe |
|---|---|
| `stalwart-api-client/` | API-Kapselung fuer Stalwart Management/JMAP/API |
| `mailbox-manager/` | Mailboxen erstellen, sperren, Quotas, Passwortwechsel |
| `alias-manager/` | Aliase, Weiterleitungen, Catch-all optional |
| `imap-importer/` | Web.de/GMX per IMAP abrufen/importieren |
| `audit-logger/` | alle Aenderungen revisionssicher protokollieren |

## API-Sicherheitsregeln

- Jede produktive Aenderung braucht Actor, Grund und Audit-Log.
- KI-Agent Aktionen sind `requires_approval=true`.
- Keine offene Relay-Konfiguration erzeugen.
- Catch-all nur nach expliziter Freigabe.
- Passwoerter nur setzen, nie lesen oder loggen.

## Offene Punkte

Vor Implementierung pruefen:

- aktuelle Stalwart Management API
- Authentifizierungsmodell
- JMAP-Funktionen fuer Mailboxen/Identities
- Alias-/Forwarding-Konfiguration
- Log- und Event-API
- sichere IMAP-Importstrategie
