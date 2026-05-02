# Contributing

## Grundregeln

- keine echten Secrets committen
- keine `.env` mit produktiven Werten hochladen
- schwere Tools nur optional und mit klaren Warnhinweisen einbauen
- neue Profile immer mit Doku, Install- und Uninstall-Skript anlegen

## Vor einem Commit

Empfohlen lokal:

```bash
pre-commit run --all-files
bash scripts/security/secret_scan.sh
bash scripts/healthcheck_all.sh
```

## Stil

- Deutsch schreiben
- Anfängerfreundlich formulieren
- keine versteckten Cloud-Kosten voraussetzen
- lokale und kostenlose Pfade klar bevorzugen

## Neue Tools

Jedes neue Tool sollte möglichst haben:

- `*_install.sh`
- `*_uninstall.sh`
- Statusmarkierung in `~/.openclaw_ultimate_user_data`
- Messwert-Schreibung in `metrics_logs/operation_history.tsv`
- Sicherheits- und Ressourcenhinweise
