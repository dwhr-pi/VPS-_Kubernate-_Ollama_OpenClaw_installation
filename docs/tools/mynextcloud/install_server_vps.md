# myNextCloud Server: Oracle VPS

## Ziel

Sicherer VPS-Pfad mit HTTPS, Backup und eingeschraenktem Admin-Zugriff.

## Grundregeln

- HTTPS Pflicht.
- Admin bevorzugt nur ueber Tailscale.
- Oeffentlicher Zugriff nur ueber Cloudflare Access/WAF/Rate-Limits.
- UFW/Fail2Ban vor Webfreigabe konfigurieren.
- Backups vor Updates testen.

## Minimaler Ablauf

```bash
git clone https://github.com/dwhr-pi/myNextCloud-server.git
cd myNextCloud-server
git remote add upstream https://github.com/nextcloud/server.git || true
cp .env.example .env
```

Danach Webserver, PHP, Datenbank und Cron nach Nextcloud-kompatibler Anleitung konfigurieren.
Docker/Compose bleibt optional und ist kein Pflichtpfad.

## Quellcodezugang

Wenn der modifizierte AGPL-Server oeffentlich angeboten wird, muss der passende Quellcodezugang
dokumentiert werden, z. B. im Footer oder Impressum/Legal-Bereich.

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
