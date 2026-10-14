# Puppeteer: Node zu alt und unzip fehlt

Das Log zeigt zwei Probleme: Node 18 statt >=22.12.0 und fehlendes `unzip`
beim Entpacken der Chrome-Downloads. Beide Voraussetzungen stehen in den
[offiziellen Systemanforderungen](https://pptr.dev/guides/system-requirements).

Der Installer prueft Node vor Paketinstallation und stellt `unzip` bereit.
Standardpaket ist `puppeteer@25.13.0`; `PUPPETEER_VERSION` erlaubt eine feste
andere Version. `npm --engine-strict` verhindert unbeachtete Engine-Warnungen.
Das System-Node wird nicht ersetzt. Wenn Node oder npm fehlt bzw. zu alt ist,
laedt der echte Installer vorhandenes nvm und versucht eine installierte
Node-22-Version zu verwenden. Bei Bedarf richtet er nvm v0.40.8 aus
[GitHub](https://github.com/nvm-sh/nvm#git-install) und Node 22 samt npm im
Benutzerkonto ein. Node-Binaries kommen ueber nvm von der Node-Distribution,
nicht aus Ubuntu apt; es gibt keinen automatischen Node-Source-Build.
Eine bereits passende Runtime bleibt unveraendert.

```bash
node --version
bash scripts/tools/puppeteer_install.sh --check
bash scripts/tools/puppeteer_install.sh --dry-run
bash scripts/tools/puppeteer_install.sh
```

Check prueft die aktuell sichtbare Runtime und bleibt bei fehlendem Node/npm
erfolglos. Dry-Run zeigt dann die geplante Bereitstellung; er laedt nvm nicht,
wechselt keine Version und startet keinen Download. Der Installations-Smoke-Test prueft
den Paketimport und eine ausfuehrbare Browserdatei, startet aber keinen Browser.
Fehlende Linux-Laufzeitbibliotheken oder Sandbox-Probleme koennen deshalb
beim spaeteren Browserstart noch sichtbar werden.

GitHub-Quelle: https://github.com/puppeteer/puppeteer
Installationsquelle des JS-Pakets ist npm; Chrome wird vom Puppeteer-Installer
heruntergeladen. Es wird kein schwerer GitHub-Monorepo-Build vorgespiegelt.
`PUPPETEER_SKIP_DOWNLOAD` behebt keinen fehlenden Browser; ohne gueltigen
`PUPPETEER_EXECUTABLE_PATH` wird dann der Smoke-Test fehlschlagen.

## Meldung: Node und npm werden benoetigt

Mindestens einer der Befehle fehlt im PATH der Installer-Shell. Auch eine
vorhandene nvm-Installation kann in nicht-interaktiven Shells unsichtbar sein.
Mit dem aktualisierten Installer normal als Benutzer starten, nicht mit sudo.
sudo wird nur fuer benoetigte Systempakete und den Toolordner verwendet.
Kein `curl | bash`, keine Aenderung von `/usr/bin/node` oder Shellprofilen.
nvm kann beim ersten Node-Installieren einen Benutzer-Default-Alias anlegen.
Die Aktivierung im Installer veraendert nicht den PATH der aufrufenden Shell.
Zum spaeteren manuellen Laden:

```bash
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
source "$NVM_DIR/nvm.sh"
nvm use 22
node --version
npm --version
```

Vor neuen Runtime-Downloads prueft der Installer 4 GiB Benutzer-Dateisystem-
Reserve und bei gesetztem WSL_DISTRO_NAME/mountbarem C: 10 GiB Windows-Reserve.
Dies ist kein vollstaendiger Budgetcheck fuer alle Browser-/Paket-Caches.
Eine defekte vorhandene NVM_DIR wird nicht geloescht. Kein Node-Download im
Regressionstest. Echte nvm-/Chrome-Installation und Browserstart bleiben zu testen.
