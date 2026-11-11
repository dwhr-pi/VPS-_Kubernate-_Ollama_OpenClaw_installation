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

Der letzte Befehl ist jetzt ein Offline-Diagnose-Wrapper. Exit 3 bedeutet
bewusst unvollstaendig, nicht erfolgreiche Runtime-Abnahme. Fuer statische
CI-Gates stattdessen die Registry-/Qualitaetstests verwenden.

## Stil

- Deutsch schreiben
- Anfängerfreundlich formulieren
- keine versteckten Cloud-Kosten voraussetzen
- lokale und kostenlose Pfade klar bevorzugen

## Neue Tools

Jeder neue Tool-PR muss enthalten oder die Nichtanwendbarkeit begruenden:

- `*_install.sh`
- `*_uninstall.sh`
- Statusmarkierung in `~/.openclaw_ultimate_user_data`
- Messwert-Schreibung in `metrics_logs/operation_history.tsv`
- Sicherheits- und Ressourcenhinweise
- GitHub-Source-URL, voller Commit-Pin, Lockfiles und Artefakt-SHA256
- SBOM-Erzeugungspfad, Build-/Compiler-Version und Scanbericht vor Freigabe
- systemd-Unit oder K8s-Manifest fuer Dienste, ohne automatischen Start
- begrenzten Smoke-Test und zugeordneten Doctor-Check, keine Menue-Marker als Health
- deutsche Dokumentation mit VPS-SSH-Weg und ehrlichem Readiness-Status
- idempotenten Uninstall ohne Entfernen privater Daten oder fremder Toolchains

Nicht getestete Tools bleiben nicht verifiziert. Die
[Wahrheitstabelle](TOOL-MATRIX-NEU.md) prueft Dateipfade, nicht Runtime.
Neue Tests muessen auch Ablehnung, Timeout, Abbruch und unveraenderten Bestand
abdecken. [Betriebsreview und Diagnosevertrag](REVIEW-2026-11-11.md).
