# n8n: Node-Version beim GitHub-Build

Das angehaengte Protokoll verlangt `node >=22.22`, verwendet aber `v18.19.1`.
`pnpm install` scheitert deshalb. Die Ubuntu-Node-Pakete sind fuer dieses
Checkout zu alt; die grosse Linux-Speicherangabe erklaert diesen Fehler nicht.

Der Installer prueft jetzt Node >=22.22.0 vor Clone und Basisinstallation.
Die automatisch abgeleitete Node-/npm-Paketinstallation wird fuer n8n
ausgelassen, damit eine bereits eingerichtete Node-Version nicht durch den
Ubuntu-Paketpfad ergaenzt wird. Das System-Node bleibt unveraendert.

Vor dem erneuten Start eine passende Node-Version ueber die vorhandene
Node-Verwaltung aktivieren und in derselben Shell pruefen:

```bash
node --version
command -v node
bash scripts/tools/n8n_install.sh
```

Wenn Corepack vorhanden ist, verwendet der Installer `corepack pnpm`, damit
die `packageManager`-Angabe des n8n-Checkouts beruecksichtigt wird. Andernfalls
muss die vorhandene pnpm-Version exakt zur Checkout-Angabe passen.
`--frozen-lockfile` und `engine-strict` verhindern einen Build mit ungeeigneten
Versionen. Neuere Upstream-Anforderungen koennen zusaetzlich zum hier aus dem
Protokoll abgeleiteten Node-Mindestwert gelten.
