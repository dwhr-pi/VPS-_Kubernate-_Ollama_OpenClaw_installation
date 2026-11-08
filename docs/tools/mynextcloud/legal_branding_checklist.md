# Legal Branding Checklist

## Lizenzen

- Nextcloud Server: AGPL-3.0, siehe <https://github.com/nextcloud/server/blob/master/COPYING>.
  Lizenztexte erhalten. Bei oeffentlichem Betrieb eines modifizierten Servers Quellcodezugang
  dokumentieren.
- Nextcloud Android: GPL-2.0, siehe <https://github.com/nextcloud/android/blob/master/LICENSE.txt>.
  Lizenztexte erhalten.
- Nextcloud Android Library: MIT, siehe
  <https://github.com/nextcloud/android-library/blob/master/LICENSE.md>. Lizenztext erhalten.

## Branding

- Projektname: `myNextCloud AI`
- Servername: `myNextCloud Server`
- Android-App: `myNextCloud Mobile`
- Pflicht-Hinweise:
  - `Fork based on Nextcloud`
  - `Not affiliated with or endorsed by Nextcloud GmbH`

## Zu pruefende Stellen Server

- App-Name und Default Title
- Logo, Favicon, Splash-/Login-Grafiken
- Login-Seite und Footer
- Updater-/Help-/About-Referenzen
- Standard-E-Mail-Texte
- App-Store-/Marketplace-Hinweise

## Zu pruefende Stellen Android

- App-Name
- Package-/Application-ID
- Launcher-Icon
- Splashscreen
- Login-Hinweise
- About-/Legal-Seite
- Store-Metadaten

## TODO

Eigene Icons/Logos erst verwenden, wenn sie wirklich selbst erstellt oder sauber lizenziert sind.

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
