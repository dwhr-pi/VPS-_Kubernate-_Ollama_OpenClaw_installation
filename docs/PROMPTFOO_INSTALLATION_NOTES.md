# Promptfoo: GitHub-Build und Runtime-Pruefung

## Ursache des gemeldeten Fehlers

Das Protokoll verwendet Node 18.19.1 und npm 9.2.0. npm bricht beim
Alias `npm:uri-js-replace` mit `Invalid comparator` ab. Der aktuelle
[Upstream](https://github.com/promptfoo/promptfoo/blob/main/package.json)
verlangt Node >=22.22.0. Die
[Build-CI](https://github.com/promptfoo/promptfoo/blob/main/.github/workflows/main.yml)
verwendet npm 11.11.0. Der Installer verlangt diesen festen npm-Pin als
Setup-Policy; das ist keine allgemeine Aussage, dass andere npm-Versionen
grundsaetzlich unbrauchbar sind. Eine echte Installation bleibt zu testen.

Der fruehere Ausdruck `npm install && npm run build || npm install` konnte
nach einem fehlgeschlagenen Build trotzdem Erfolg melden. Dieser Fallback
ist entfernt. Upstream-Overrides und Lockfile bleiben unveraendert.

## Vorbereiten und installieren

Als normaler Benutzer starten, nicht mit sudo. Der echte Installer verwendet
eine passende Runtime weiter oder laedt/richtet nvm und Node 22 im Benutzerkonto
ein. System-Node bleibt erhalten. Promptfoo und Puppeteer verwenden denselben
Runtime-Helfer. nvm wird nicht bei jedem Tool erneut geklont.

```bash
bash scripts/tools/promptfoo_install.sh --dry-run
bash scripts/tools/promptfoo_install.sh
```

Check prueft nur die aktuell sichtbare Runtime und scheitert bei fehlenden
Voraussetzungen. Dry-Run beschreibt auch deren Bereitstellung, installiert
aber nichts und aktiviert kein nvm. Beide sind kein vollstaendiger Tool-Test.

Weicht npm ab, wird `npm@11.11.0` ohne Lifecycle-Skripte privat unter
`~/.openclaw_ultimate_user_data/runtimes/promptfoo-npm-11.11.0` installiert.
Das globale npm bleibt erhalten. Nur im Installer-Prozess wird dieser private
Paketmanager im PATH bevorzugt, einschliesslich verschachtelter Build-Aufrufe.
Der Ordner bleibt fuer weitere Laeufe erhalten; eine kaputte private npm-
Installation wird als Fehler gemeldet, nicht blind geloescht.

Der echte Installer klont GitHub, installiert Abhaengigkeiten mit
`npm ci --engine-strict`, baut und prueft die CLI. Native Module koennen
Build-Werkzeuge/Python benoetigen; apt dient nur diesen Systemabhaengigkeiten.
Ein vorhandener Git-Checkout wird ausschliesslich per Fast-Forward aktualisiert.
Nicht-Git-Verzeichnisse und abweichende Quellen werden nicht geloescht.

## Ressourcen und Sicherheit

Der Upstream-Build fuehrt mehrere Teilbuilds parallel aus und erlaubt einem
Teilprozess bis zu 8 GiB Node-Heap. Das ist keine RAM-Mindestgarantie.
Fuer den Source-Build konservativ 12-16 GiB RAM und mindestens 20 GiB freien
Speicher einplanen (Setup-Empfehlung, kein offizielles Minimum). Unter WSL
zusaetzlich freien Speicher auf dem Windows-Datentraeger pruefen. Diese
Empfehlung ist noch keine automatische Ressourcen-Sperre fuer den Source-Build.
Vor neuen Runtime-Downloads gelten 4 GiB Benutzer-Dateisystem-Reserve und bei
erkennbarer WSL 10 GiB Windows-C:-Reserve, wie beim Puppeteer-Runtime-Helfer.

Es werden weder ein Webserver noch Evaluierungen gestartet. Secrets und private
Testdaten ausserhalb des Repositories speichern. Cloud-Evaluierungen koennen
Kosten verursachen; Red-Teaming nur mit ausdruecklicher Autorisierung.
Das vorhandene Deinstallationsskript entfernt `/opt/promptfoo`; dort keine
persoenlichen Datensaetze ablegen, vorher sichern.

## Tests und offene Punkte

```bash
bash tests/promptfoo_install_test.sh
bash tests/promptfoo_runtime_setup_test.sh
bash -n scripts/tools/promptfoo_install.sh
```

Die Regressionstests verwenden Mocks, keine echte Paketinstallation. Ein
vollstaendiger Linux-Build, native Module und zukuenftige Upstream-Aenderungen
sind noch zu pruefen. Ein bestehender Registry-Check auf den Verzeichnispfad
allein beweist keinen erfolgreichen Build; die CLI separat testen.
