# Fachprofil: Anti_Virus

## Zweck

Lokales Schutz- und Hygieneprofil fuer Malware-Scans, Quarantaene-Workflows, Datei-Checks, Signaturen, YARA-Regeln und verdachtige Downloads. Es ist defensiv und fuer eigene Systeme gedacht.

## Typische Aufgaben

- Downloads und Upload-Verzeichnisse pruefen
- ClamAV-Signaturen aktualisieren
- YARA-Regeln fuer lokale Dateipruefung nutzen
- Log- und Quarantaeneordner getrennt halten
- False Positives dokumentieren

## Empfohlene Tools

- `clamav`
- `yara`
- optional `rkhunter`
- optional `chkrootkit`
- `gitleaks` fuer Repo-Hygiene

## Sicherheit

Keine Samples ins Repo legen. Verdachtige Dateien nicht ungeprueft ausfuehren. Quarantaene ausserhalb des Repos unter `~/.openclaw_ultimate_user_data/security/quarantine/`.

## Status

`beta`.
