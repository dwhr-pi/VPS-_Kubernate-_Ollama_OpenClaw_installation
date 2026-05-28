# mail-control-panel Frontend

Das Frontend ist als eigenes kleines Control Panel geplant. Es soll Stalwart
nicht forken, sondern ueber das Backend verwalten.

## Bevorzugte Technik

- React/Vite
- lokale oder VPN-geschuetzte Bereitstellung
- keine direkte Verbindung aus dem Browser zu geheimen Backend-Secrets

## Bereiche

- Login
- Domainliste
- Mailboxliste
- Aliasliste
- Quotas
- Status
- DNS-Check
- KI-Assistent
- Audit-Log
- IMAP-Import von Web.de/GMX
- manuelle Freigabe von KI-Antworten

## Sicherheitsregeln

- Admin-UI nicht oeffentlich ohne Schutz.
- Session-Cookies sicher konfigurieren.
- Keine Passwoerter anzeigen.
- KI-Antworten nur als Entwurf.
- Jede Aenderung mit Audit-Hinweis anzeigen.

## Seiten

- [Domains](domains.md)
- [Mailboxes](mailboxes.md)
- [Aliases](aliases.md)
- [Rules](rules.md)
- [AI Assistant](ai-assistant.md)
