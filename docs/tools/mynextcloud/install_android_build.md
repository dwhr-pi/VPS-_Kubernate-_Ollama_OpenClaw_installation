# myNextCloud Mobile: Android Build

## Ziel

Android-Fork lokal unter Windows 11 + WSL2 + Android Studio bauen.

## Upstream

```bash
git clone https://github.com/dwhr-pi/myNexcloud-for-android.git
cd myNexcloud-for-android
git remote add upstream https://github.com/nextcloud/android.git || true
git fetch upstream --tags
```

## Branding-Aufgaben

- App-Name: `myNextCloud Mobile`
- Package/Application-ID pruefen und eigenen Namespace planen.
- Launcher-Icon und Splashscreen durch eigene Platzhalter ersetzen.
- Login-Hinweis: `Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.`
- Standard-Server-URL per BuildConfig/Settings vorbereiten.

## Build-Hinweise

- Android Studio nutzen, keine automatische Store-Veroeffentlichung.
- Signing-Keys nicht ins Repo.
- F-Droid/Google-Play-Tauglichkeit nur dokumentieren, nicht automatisieren.

## TODO

QR-Code Login spaeter vorbereiten, aber nicht ohne Sicherheitsreview aktivieren.

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
