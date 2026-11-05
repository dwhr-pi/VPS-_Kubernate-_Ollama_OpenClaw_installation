# Fork-Review myNextCloud

Stand der Online-Pruefung: 2026-05-28.

## Erreichbarkeit

| Repository                                          | HEAD bei Pruefung                          | Ergebnis           |
| --------------------------------------------------- | ------------------------------------------ | ------------------ |
| `https://github.com/dwhr-pi/myNextCloud-server`     | `3f7721b996d6ade60d7da6b862353805c1c60403` | erreichbar         |
| `https://github.com/dwhr-pi/myNexcloud-for-android` | `1a957bd5e98a2d8377043207b2e34d1c3e6c9594` | erreichbar         |
| `https://github.com/nextcloud/server`               | remote erreichbar                          | Upstream           |
| `https://github.com/nextcloud/android`              | remote erreichbar                          | Upstream           |
| `https://github.com/nextcloud/android-library`      | remote erreichbar                          | Referenz           |
| `https://github.com/nextcloud/nextcloudpi`          | remote erreichbar                          | optionale Referenz |

## Ableitbarkeit pruefen

Die sichere Ableitbarkeit wird nicht durch einen GitHub-Namen garantiert, sondern durch den lokalen
Git-Verlauf. Nach dem Klonen:

```bash
git remote add upstream https://github.com/nextcloud/server.git
git fetch upstream --tags
git merge-base HEAD upstream/master
git log --oneline --decorate --graph --max-count=30 --all
```

Fuer Android:

```bash
git remote add upstream https://github.com/nextcloud/android.git
git fetch upstream --tags
git merge-base HEAD upstream/master
git log --oneline --decorate --graph --max-count=30 --all
```

Wenn `merge-base` keinen gemeinsamen Commit findet, ist der Fork nicht sauber ableitbar oder die
Historie wurde umgeschrieben. Dann keine automatische Selbstheilung oder Update-Merges ausfuehren.

## Ergebnis

Die Remotes sind erreichbar. Die historische Ableitbarkeit sollte im jeweiligen lokalen Fork mit den
oben genannten Befehlen geprueft werden, bevor Branding-, Upstream- oder Release-Aenderungen gemergt
werden.

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
