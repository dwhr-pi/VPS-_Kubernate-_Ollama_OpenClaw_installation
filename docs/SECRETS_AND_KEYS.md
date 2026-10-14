# Secrets and Keys

## Grundregel

Neu: [ENV-Tresor mit Masterpassphrase](ENV_VAULT.md), erreichbar unter
Setup -> Optionen -> 19. Verschluesselter Tresor im Backupverzeichnis,
ENV-Vorschau ohne Werte und Schreiben erst nach Freigabe. Keine gemeinsame
Master-Zugangsdaten fuer alle Programme: die Passphrase schuetzt getrennte Werte.

Keine echten Secrets ins Repository. Dazu zaehlen API-Keys, Tokens, Private Keys, `.env`, SSH-Keys, Cloudflare Tokens, Tailscale Auth Keys, Home Assistant Tokens und Datenbankpasswoerter.

## Pfade

- Vorlagen: `.env.example` oder `*.template`
- echte lokale Werte: `~/.openclaw_ultimate_user_data/`
- Diagnoseberichte: Secrets maskieren

## Empfohlene Tools

| Tool | Zweck | Status |
|---|---|---|
| Gitleaks | Secret-Scan im Repo | optional |
| TruffleHog | tiefer Secret-Scan | optional |
| SOPS | verschluesselte Konfiguration | planned |
| age | lokale Schluessel/Verschluesselung | planned |
| dotenv-linter | `.env`-Format pruefen | planned |

## Setup-Regeln

- Cloud-API-Keys nur bewusst aktivieren.
- Kostenwarnung vor Cloud-/Video-/LLM-APIs anzeigen.
- Tokens nie in Logs ausgeben.
- Forks ohne Integritaetspruefung nicht automatisch selbstheilen.

## Local First Vault Optionen 2026

- SOPS + age fuer Git-nahe verschluesselte Konfiguration.
- pass fuer einfache lokale Secrets.
- OpenBao oder Infisical nur optional/serverseitig nach Backup- und Zugriffskonzept.
- Doppler CLI bleibt optional und cloud-nah; keine Pflicht.
- Doctor soll pruefen, ob .env versehentlich im Repo liegt und ob Beispielwerte Platzhalter bleiben.
