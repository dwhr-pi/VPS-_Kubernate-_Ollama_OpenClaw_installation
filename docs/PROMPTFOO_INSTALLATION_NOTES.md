# Promptfoo: GitHub-Build und Runtime-Pruefung

## Ursache des gemeldeten Fehlers

Das Protokoll verwendet Node 18.19.1 und npm 9.2.0. npm bricht beim Alias `npm:uri-js-replace` mit
`Invalid comparator` ab. Der aktuelle
[Upstream](https://github.com/promptfoo/promptfoo/blob/main/package.json) verlangt Node >=22.22.0.
Die [Build-CI](https://github.com/promptfoo/promptfoo/blob/main/.github/workflows/main.yml)
verwendet npm 11.11.0. Der Installer verlangt diesen festen npm-Pin als Setup-Policy; das ist keine
allgemeine Aussage, dass andere npm-Versionen grundsaetzlich unbrauchbar sind. Eine echte
Installation bleibt zu testen.

Der fruehere Ausdruck `npm install && npm run build || npm install` konnte nach einem
fehlgeschlagenen Build trotzdem Erfolg melden. Dieser Fallback ist entfernt. Upstream-Overrides und
Lockfile bleiben unveraendert.

## Vorbereiten und installieren

Als normaler Benutzer starten, nicht mit sudo. Der echte Installer verwendet eine passende Runtime
weiter oder laedt/richtet nvm und Node 22 im Benutzerkonto ein. System-Node bleibt erhalten.
Promptfoo und Puppeteer verwenden denselben Runtime-Helfer. nvm wird nicht bei jedem Tool erneut
geklont.

```bash
bash scripts/tools/promptfoo_install.sh --dry-run
bash scripts/tools/promptfoo_install.sh
```

Check prueft nur die aktuell sichtbare Runtime und scheitert bei fehlenden Voraussetzungen. Dry-Run
beschreibt auch deren Bereitstellung, installiert aber nichts und aktiviert kein nvm. Beide sind
kein vollstaendiger Tool-Test.

Weicht npm ab, wird `npm@11.11.0` ohne Lifecycle-Skripte privat unter
`~/.openclaw_ultimate_user_data/runtimes/promptfoo-npm-11.11.0` installiert. Das globale npm bleibt
erhalten. Nur im Installer-Prozess wird dieser private Paketmanager im PATH bevorzugt,
einschliesslich verschachtelter Build-Aufrufe. Der Ordner bleibt fuer weitere Laeufe erhalten; eine
kaputte private npm- Installation wird als Fehler gemeldet, nicht blind geloescht.

Der echte Installer klont GitHub, installiert Abhaengigkeiten mit `npm ci --engine-strict`, baut und
prueft die CLI. Native Module koennen Build-Werkzeuge/Python benoetigen; apt dient nur diesen
Systemabhaengigkeiten. Ein vorhandener Git-Checkout wird ausschliesslich per Fast-Forward
aktualisiert. Nicht-Git-Verzeichnisse und abweichende Quellen werden nicht geloescht.

## Ressourcen und Sicherheit

Der Upstream-Build fuehrt mehrere Teilbuilds parallel aus und erlaubt einem Teilprozess bis zu 8 GiB
Node-Heap. Das ist keine RAM-Mindestgarantie. Fuer den Source-Build konservativ 12-16 GiB RAM und
mindestens 20 GiB freien Speicher einplanen (Setup-Empfehlung, kein offizielles Minimum). Unter WSL
zusaetzlich freien Speicher auf dem Windows-Datentraeger pruefen. Diese Empfehlung ist noch keine
automatische Ressourcen-Sperre fuer den Source-Build. Vor neuen Runtime-Downloads gelten 4 GiB
Benutzer-Dateisystem-Reserve und bei erkennbarer WSL 10 GiB Windows-C:-Reserve, wie beim
Puppeteer-Runtime-Helfer.

Es werden weder ein Webserver noch Evaluierungen gestartet. Secrets und private Testdaten ausserhalb
des Repositories speichern. Cloud-Evaluierungen koennen Kosten verursachen; Red-Teaming nur mit
ausdruecklicher Autorisierung. Das vorhandene Deinstallationsskript entfernt `/opt/promptfoo`; dort
keine persoenlichen Datensaetze ablegen, vorher sichern.

## Tests und offene Punkte

```bash
bash tests/promptfoo_install_test.sh
bash tests/promptfoo_runtime_setup_test.sh
bash -n scripts/tools/promptfoo_install.sh
```

Die Regressionstests verwenden Mocks, keine echte Paketinstallation. Ein vollstaendiger Linux-Build,
native Module und zukuenftige Upstream-Aenderungen sind noch zu pruefen. Ein bestehender
Registry-Check auf den Verzeichnispfad allein beweist keinen erfolgreichen Build; die CLI separat
testen.

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
python3 -I -B scripts/tool_commands.py show promptfoo
```

### SSH-Aktionen: `promptfoo`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Promptfoo` (ID `promptfoo`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
