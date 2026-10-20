# Alle API-Schluessel: Dokumentation und Verwaltung

Diese Uebersicht buendelt die Dokumentation zu API-Zugaengen und ihrer
sicheren Verwaltung. **Hier stehen keine echten Schluessel oder Tokens.**
Es werden keine Konten angelegt, Zugangsdaten ausgelesen, Schluessel erzeugt
oder Dienste aktiviert. Ein dokumentierter Zugang ist keine Cloud-Freigabe.

## Navigation

- [Kostenlose LLM-Zugaenge, Free Tiers und Trial-Credits](FREE_TIERS_AND_TRIAL_CREDITS.md):
  konkrete GitHub-/Primaerquellen, eigene Bewertung und woechentliche Nachpruefung.
- [Datierte Quellenberichte](reviews/README.md): Befunde und Original-Links bleiben erhalten.

- [API-Key-Katalog aller im Setup dokumentierten Anbieter und Dienste](PROVIDER_KEY_CATALOG.md):
  offizielle Webseiten direkt in den Tabellen, Variablennamen, Zweck,
  lokale Zugänge, OAuth und Connector-Grenzen.
- [API-Key Guide, Ports und Sicherheit](API_KEY_GUIDE.md): formatierte Anleitung,
  aus `docs/API_KEY_GUIDE.md` in dieses Verzeichnis verschoben.

- [OnlineOnKeyServices](OnlineOnKeyServices/README.md): ein API-Schluessel fuer
  mehrere KI-Modelle, ohne Installation des Anbieterdienstes.
- [OpenRouter](OnlineOnKeyServices/openrouter.md): eigener Anbieter-Key,
  vorhandener FreeLLMAPI-Provider und optionale direkte Anbindung.
- [token8341 / TokenWorks](OnlineOnKeyServices/token8341.md): eigener
  Anbieter-Key, bedingte Custom-Anbindung an FreeLLMAPI.
- [FreeLLMAPI](../tools/freellmapi.md): lokaler Unified Key fuer Clients,
  getrennte Upstream-Keys fuer Modellanbieter.
- [Secrets und Keys](../SECRETS_AND_KEYS.md): gemeinsame Sicherheitsregeln.
- [ENV-Tresor](../ENV_VAULT.md): verschluesselte lokale Verwaltung und
  kontrolliertes Ausfuellen von ENV-Dateien.

## Schluesselarten auseinanderhalten

| Zugang | Wer verwendet ihn? | Nicht verwechseln mit |
|---|---|---|
| FreeLLMAPI Unified Key | Dein freigegebener Client gegen den lokalen Router | Anbieter-Key oder Tresor-Passphrase |
| OpenRouter-Key | Router oder bewusster direkter OpenRouter-Client | OpenAI-Key, token8341-Key oder lokalem Unified Key |
| token8341-Key | Router-Custom-Endpunkt oder bewusster direkter Client | OpenRouter-Key oder lokalem Unified Key |
| Weitere Provider-/Dienstzugangsdaten | Nur die jeweilige freigegebene Integration, nach deren Dokumentation | Allgemeinem Zugang fuer alle Programme |
| ENV-Tresor-Passphrase | Mensch zur Entschluesselung lokaler Werte | API-Key eines Anbieters; sie wird nicht an Provider gesendet |

Die Liste ist ein Dokumentationsindex, kein automatisch geprueftes Inventar
aller lokal vorhandenen Credentials. Einzelne Integrationen koennen OAuth,
API-Tokens, Passwoerter oder gar keinen Key verwenden. Massgeblich bleiben
ihre jeweilige Dokumentation und Konfiguration.

## Sichere Ablage

Echte Werte bleiben unter `~/.openclaw_ultimate_user_data/` bzw. dem bewusst
gewaehlten externen User-Workspace. Nur leere `.env.example`-Vorlagen oder
Platzhalter duerfen ins Repository. Keine Secrets in Markdown, Screenshots,
Git, Shell-Argumente, Diagnoseberichte oder unverschluesselte Backups aufnehmen.
Dateirechte und Zugriffsschutz pruefen; getrennte Keys je Dienst und Zweck,
Budget/Quoten, Rotation und Widerruf vorsehen. Der Tresor ist kein gemeinsamer
Universal-Key und kein automatischer Export aller Werte an FreeLLMAPI.

Zurueck zum [Tool-Index](../TOOL_INDEX.md).
