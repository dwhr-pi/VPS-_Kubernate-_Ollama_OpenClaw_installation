# Puppeteer: Node zu alt und unzip fehlt

Das Log zeigt zwei Probleme: Node 18 statt >=22.12.0 und fehlendes `unzip`
beim Entpacken der Chrome-Downloads. Beide Voraussetzungen stehen in den
[offiziellen Systemanforderungen](https://pptr.dev/guides/system-requirements).

Der Installer prueft Node vor Paketinstallation und stellt `unzip` bereit.
Standardpaket ist `puppeteer@25.13.0`; `PUPPETEER_VERSION` erlaubt eine feste
andere Version. `npm --engine-strict` verhindert unbeachtete Engine-Warnungen.
Das System-Node wird nicht ersetzt. Eine kompatible Node-Version muss in der
aufrufenden Shell aktiv sein.

```bash
node --version
bash scripts/tools/puppeteer_install.sh --check
bash scripts/tools/puppeteer_install.sh --dry-run
bash scripts/tools/puppeteer_install.sh
```

Check und Dry-Run pruefen hier nur die Node/npm-Voraussetzung; sie starten
keine Installation und keinen Browser. Der Installations-Smoke-Test prueft
den Paketimport und eine ausfuehrbare Browserdatei, startet aber keinen Browser.
Fehlende Linux-Laufzeitbibliotheken oder Sandbox-Probleme koennen deshalb
beim spaeteren Browserstart noch sichtbar werden.

GitHub-Quelle: https://github.com/puppeteer/puppeteer
Installationsquelle des JS-Pakets ist npm; Chrome wird vom Puppeteer-Installer
heruntergeladen. Es wird kein schwerer GitHub-Monorepo-Build vorgespiegelt.
`PUPPETEER_SKIP_DOWNLOAD` behebt keinen fehlenden Browser; ohne gueltigen
`PUPPETEER_EXECUTABLE_PATH` wird dann der Smoke-Test fehlschlagen.
