# Upstream-Sync fuer myNextCloud Forks

## Server

Fork: `https://github.com/dwhr-pi/myNextCloud-server`

Upstream: `https://github.com/nextcloud/server`

Empfohlener Ablauf:

```bash
git remote add upstream https://github.com/nextcloud/server.git
git fetch upstream --tags
git status --short
git log --oneline --decorate --graph --max-count=20 --all
```

Nicht automatisch mergen, wenn Branding-, Lizenz- oder App-spezifische Aenderungen betroffen sind.
Erst Diff pruefen, dann gezielt mergen oder rebasen.

## Android

Fork: `https://github.com/dwhr-pi/myNexcloud-for-android`

Upstream: `https://github.com/nextcloud/android`

Empfohlener Ablauf:

```bash
git remote add upstream https://github.com/nextcloud/android.git
git fetch upstream --tags
git status --short
git log --oneline --decorate --graph --max-count=20 --all
```

## Android Library

Referenz: `https://github.com/nextcloud/android-library`

Die Library separat beobachten, besonders wenn Login, WebDAV, TLS, OAuth oder File Sync betroffen
sind.

## Rechtlicher Hinweis

Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.

AGPL/GPL/MIT-Lizenztexte und Copyright-Hinweise muessen erhalten bleiben.

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
