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

Eine passende Node-Version bewusst in der eigenen Benutzerumgebung aktivieren,
beispielsweise ueber ein bereits eingerichtetes nvm. Nicht `/usr/bin/node`
ueberschreiben und npm nicht mit sudo in die Systeminstallation installieren.
Erst nach Aktivierung der gewuenschten Node-Version:

```bash
node --version
npm install -g npm@11.11.0
npm --version
bash scripts/tools/promptfoo_install.sh --check
bash scripts/tools/promptfoo_install.sh --dry-run
bash scripts/tools/promptfoo_install.sh
node /opt/promptfoo/dist/src/entrypoint.js --version
```

Check/Dry-Run pruefen nur die Runtime, nicht die Vollstaendigkeit einer bereits
installierten Toolchain. Sie klonen nichts, installieren nichts und bauen nicht.
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
Empfehlung ist noch keine automatische Ressourcen-Sperre in diesem Installer.

Es werden weder ein Webserver noch Evaluierungen gestartet. Secrets und private
Testdaten ausserhalb des Repositories speichern. Cloud-Evaluierungen koennen
Kosten verursachen; Red-Teaming nur mit ausdruecklicher Autorisierung.
Das vorhandene Deinstallationsskript entfernt `/opt/promptfoo`; dort keine
persoenlichen Datensaetze ablegen, vorher sichern.

## Tests und offene Punkte

```bash
bash tests/promptfoo_install_test.sh
bash -n scripts/tools/promptfoo_install.sh
```

Die Regressionstests verwenden Mocks, keine echte Paketinstallation. Ein
vollstaendiger Linux-Build, native Module und zukuenftige Upstream-Aenderungen
sind noch zu pruefen. Ein bestehender Registry-Check auf den Verzeichnispfad
allein beweist keinen erfolgreichen Build; die CLI separat testen.
