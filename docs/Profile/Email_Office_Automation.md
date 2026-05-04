# Profil: Email_Office_Automation

## Zweck

Lokale Dokumenten-, PDF- und Office-Automation mit Fokus auf Datenschutz, Strukturierung und spaeterer Mail-/Kalender-Erweiterbarkeit.

## Installierbare Kern-Tools

- `paperless_ngx`
- `stirling_pdf`
- `apache_tika`
- `pandoc`
- `nextcloud`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `Radicale`, `Vikunja`, CalDAV/CardDAV, lokale Mailparser

## Hardware / Plattform

- gut fuer `MiniPC`, `VPS`
- SSD fuer Dokumentenspeicher und OCR-Caches empfehlenswert

## Risiken und Grenzen

- Dokumente, Scans und Mailanhaenge koennen hochsensibel sein
- kein automatisches Senden oder Weiterleiten ohne bewusste Freigabe

## Quickstart

```bash
bash scripts/profiles/Email_Office_Automation_install.sh
```
