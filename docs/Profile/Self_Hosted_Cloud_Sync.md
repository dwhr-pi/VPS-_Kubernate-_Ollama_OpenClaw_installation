# Self_Hosted_Cloud_Sync

## Zweck
Eigene Cloud-, Sync- und Backup-Schicht für Dokumente, Notizen, Artefakte und Teamdaten.

## Typische Aufgaben
- Datei- und Notiz-Synchronisation
- S3-kompatible Ablage
- Offsite-Backups
- lokaler Daten-Hub für andere Profile

## Empfohlene Tools
Nextcloud, Syncthing, Rclone, MinIO, Restic.

## Optionale Tools
BorgBackup, Tailscale, Headscale.

## Benötigte Ports
`8384`, `8082`, `9000`, `9001`

## Ressourcenbedarf
SSD und regelmäßige Backup-Kapazität einplanen.

## Sicherheitsrisiken
Datei- und Cloud-Sync ist ein zentrales Risikoobjekt. Keine öffentliche Freigabe ohne Auth, TLS und Rollenmodell.

## Ollama/OpenClaw-Fit
Sehr gut als Speicherbasis für Agenten, Modelle, Datasets und Dokumente.

## LiteLLM/Open WebUI-Fit
Nicht direkt zentral, aber als Artefakt- und DMS-Schicht sehr wertvoll.

## Quickstart
`bash scripts/profiles/Self_Hosted_Cloud_Sync_install.sh`

## Deinstallation
`bash scripts/profiles/Self_Hosted_Cloud_Sync_uninstall.sh`

## Sinnvolle lokale Modelle
Nicht modellzentriert; eher Infrastrukturprofil.

## Grenzen und Warnhinweise
Backups regelmäßig rücksichern testen. Keine unverschlüsselten Exporte als Standard.
