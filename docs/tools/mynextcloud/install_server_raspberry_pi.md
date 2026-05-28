# myNextCloud Server auf Raspberry Pi

Dieser Pfad ist `planned` und NextcloudPi-inspiriert, aber kein automatischer NextcloudPi-Fork-Installer.

## Ziel

`myNextCloud Server` soll auf Raspberry Pi lokal-first laufen: kleine Dateiablage, private Sync-Zentrale, optionale KI-Verarbeitung auf einem staerkeren Host.

## Empfehlung

- Raspberry Pi 5 oder MiniPC bevorzugen.
- Datenverzeichnis auf SSD statt SD-Karte legen.
- Datenbank lokal nur bei kleiner Nutzung, sonst externer Postgres/MariaDB-Host.
- Ollama/Whisper nicht auf schwachem Pi erzwingen, sondern per LAN/WSL/VPS-Endpunkt anbinden.

## Sichere Defaults

- Webserver nur intern oder via Tailscale.
- Oeffentlicher Zugriff nur via Cloudflare Access/WAF/Rate-Limits.
- Admin nur ueber Tailscale.
- Backups vor jedem Upgrade.

## TODO

- Ressourcenmesswerte fuer Pi 4, Pi 5 und ARM-VPS erfassen.
- Optionales Profil fuer SSD-Mount, Backup und Healthcheck ergaenzen.
