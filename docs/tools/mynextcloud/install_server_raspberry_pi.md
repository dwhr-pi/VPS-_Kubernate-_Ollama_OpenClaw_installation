# myNextCloud Server auf Raspberry Pi

Dieser Pfad ist `planned` und NextcloudPi-inspiriert, aber kein automatischer
NextcloudPi-Fork-Installer.

## Ziel

`myNextCloud Server` soll auf Raspberry Pi lokal-first laufen: kleine Dateiablage, private
Sync-Zentrale, optionale KI-Verarbeitung auf einem staerkeren Host.

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

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
