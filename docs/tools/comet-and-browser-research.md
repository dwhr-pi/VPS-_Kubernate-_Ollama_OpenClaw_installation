# Comet, offene Browser und Perplexity fuer dieses Setup

Stand: 26.10.2026. Jetzt im Tools-Menue als letzte Gruppe **hinter der A-Z-Liste**
installierbar bzw. fuer manuelle Desktop-Installation auswaehlbar. Die beiden
Nutzeranhaenge bleiben Recherchematerial; deren Befehle wurden nicht ausgefuehrt. Keine Cookies,
Browserprofile, Konten oder externen Recherche-APIs wurden verbunden.

## Comet ist ein Client, keine lokale Inferenz-Runtime

Die [offizielle Comet-Seite](https://www.perplexity.ai/comet) bietet Downloads
fuer Desktop/Mobilgeraete. Ein offizieller vollstaendiger Comet-Quellcode-/Build-
Vertrag wurde in den geprueften Quellen nicht nachgewiesen. Daher **kein
GitHub-Source-Installer fuer Comet** und keine Gleichsetzung mit dem offenen
Chromium-Unterbau. Fuer Comet bleibt es beim offiziellen Downloadlink.
Konto-/Tarif-/Plattformbedingungen vor Installation dort pruefen. Der neue Eintrag
**Comet** bietet wie Qwen Desktop Oeffnen der offiziellen Downloadseite, einen
Wartepunkt und anschliessende manuelle Bestaetigung. Die EXE wird unter Windows
heruntergeladen/geprueft/ausgefuehrt, niemals automatisch in WSL.

## Neue Eintraege am Listenende

| Projekt / GitHub | Rolle | Einordnung fuer den Hybridstack |
|---|---|---|
| **Comet** / [Download](https://www.perplexity.ai/comet) | Proprietaerer Desktop-Browser | Manueller Windows-Download mit Pause/Bestaetigung; explizite Nicht-GitHub-Ausnahme |
| **BrowserOS** / [GitHub](https://github.com/browseros-ai/BrowserOS) | Offener agentischer Desktop-Browser | Offiziellen GitHub-Release manuell fuer Windows/Linux installieren, kein Chromium-Source-Build |
| **Enki_Browser** / [GitHub](https://github.com/danilogiles/enki-browser) | Chromium-Browser mit eigenem Assistenten | Offiziellen GitHub-Release manuell fuer Windows/Linux installieren |
| **Browser_Use** / [GitHub](https://github.com/browser-use/browser-use) | Browser-Agent-Bibliothek | Privates Python-Paket aus GitHub mit uv-Lock; kein Browserdownload oder Agentenstart |
| **Perplexity_MCP** / [GitHub](https://github.com/perplexityai/modelcontextprotocol) | Offizieller API-MCP-Server | Gepinnter TypeScript-Build; kein Serverstart, kein API-Key erforderlich fuer den Build |
| **Perplexity_Python** / [GitHub](https://github.com/perplexityai/perplexity-py) | Offizieller Python-SDK | Gepinntes Bazel-Wheel mit privater Python-Umgebung; keine API-Anfrage |
| **Perplexity_Node** / [GitHub](https://github.com/perplexityai/perplexity-node) | Offizieller Node-SDK | Gepinntes Bazel-Paket; keine API-Anfrage |
| **Perplexity_API_Cookbook** / [GitHub](https://github.com/perplexityai/api-cookbook) | Offizielle Beispiele | Gepinnte Beispielsammlung lokal installieren; kein ausfuehrbarer Dienst, Beispiele werden nicht gestartet |

Die Eintraege sind jetzt separat im Setup erreichbar; **kein Download oder Build
wurde auf deinem Produktivsystem ausgefuehrt**. Die PDF-Aussagen zu
Browser Operator und OpenBrowser sind ohne eindeutige Quell-/Lizenzidentitaet
nicht als Installer umgesetzt. Auch SPACE/pplx-Kernels aus dem Text sind kein
belegter Ersatz fuer ein Browserprodukt oder eine fertige sichere Sandbox.
Lizenzdatei, Commit, Plattform, Buildbedarf und funktionale Abnahme sind pro
Kandidat weiterhin zu beachten; ein Repositorylink oder ein erfolgreicher Build
ist kein Sicherheits- oder vollstaendiger Funktionsnachweis.

## Installation, Voraussetzungen und Lebenszyklus

Die drei Desktop-Eintraege koennen die offizielle Seite nach Bestaetigung oeffnen.
Manuell korrektes Betriebssystem/CPU waehlen, Signatur/Pruefsumme nach Upstream
pruefen; keine Warnungen, AppArmor- oder Chromium-Sandbox deaktivieren. BrowserOS
und Enki bieten GitHub-Releases, Comet die offizielle Herstellerseite.
BrowserOS/Enki koennen auch auf einem Linux-Desktop manuell installiert werden;
deren angegebener `source_commit` bezeichnet den geprueften Quellstand, **nicht**
einen automatisch festgehaltenen EXE-/Release-Hash. Die manuell geoeffnete
`releases/latest`-Seite kann spaeter andere Versionen anbieten.
WSL braucht fuer einen Linux-Browser eine gesondert abgenommene grafische Umgebung.
Keine `curl | bash`-Installation. Deinstallation in Windows unter **Einstellungen
-> Apps** bzw. ueber den selbst gewaehlten Linux-Paketweg. Das Setup loescht keine
Profile/Cookies und erstellt keinen automatisch verifizierten Desktop-Marker.
Enter/Nein nach dem Wartepunkt liefert `skipped` (Exit 3), nicht einen Buildfehler.

Die fuenf GitHub-Eintraege besitzen Install/Update/Uninstall/Status/Check/Doctor.
Vorher stets einen lesenden Plan ansehen, beispielsweise:

```bash
bash scripts/tools/comet_install.sh --dry-run
bash scripts/tools/browser_use_install.sh --dry-run
bash scripts/tools/perplexity_mcp_install.sh --dry-run
bash scripts/tools/perplexity_python_install.sh --dry-run
bash scripts/tools/perplexity_node_install.sh --dry-run
bash scripts/tools/perplexity_cookbook_install.sh --dry-run
```

Danach im Tools-Menue installieren oder dasselbe Skript ohne `--dry-run` starten.
Fuer Desktopseiten ist `--open-download` als expliziter Browseraufruf verfuegbar.

| Paket | Buildvertrag auf Linux/Ubuntu/WSL | Reserve |
|---|---|---|
| Browser_Use | Python >=3.11 mit SSL, uv; `uv sync --frozen --no-dev --no-default-groups`, kein Python-/Browserdownload | 4 GiB |
| Perplexity_MCP | Node >=22, npm; `npm ci --ignore-scripts`, danach explizit `npm run build`, `node --check` | 4 GiB |
| Perplexity_Python | Bazel 9.2.0, Python >=3.10 mit SSL, uv; upstream `bazel build //:wheel`, Wheel im privaten venv | 8 GiB |
| Perplexity_Node | Bazel 9.2.0, Node 26, pnpm 11.17.0; frozen Install ohne Lifecycle-Hooks, upstream `bazel build //:pkg` | 8 GiB |
| Perplexity_API_Cookbook | Git; ausschliesslich Commit-Checkout mit README/Lizenznachweis | 2 GiB |

Die Voraussetzungen stammen aus den geprueften gepinnten `pyproject.toml`,
`package.json`, `CONTRIBUTING.md`, `.bazelversion` und `BUILD.bazel` der oben
verlinkten Repositories. Mit `BROWSER_RESEARCH_PYTHON_BIN` laesst sich ein bereits
vorhandenes passendes Python waehlen. Kein apt-Systemumbau, globales npm/pip,
automatischer Toolchain-Download oder Docker. Paket-/Bazel-Abhaengigkeiten werden
beim freigegebenen Build aus ihren Upstream-Registries geladen; kein offline-
oder vollstaendig auf GitHub begrenztes Netzwerkversprechen. Das Python-SDK-Wheel
hat Versionsbereiche fuer Laufzeitabhaengigkeiten, keinen vollstaendigen Hash-Lock.

Pins stehen in `scripts/tools/helpers/gap_tools.json`, gespiegelt in
`config/tools.yml`. Ziel: `~/.openclaw_ultimate_user_data/tools/<id>/runtime`,
Nachweis: `ready.json`. Update prueft denselben Pin statt blind `main/latest`.
Doctor prueft die Dateiinventur. Geaenderte/ergaenzte Dateien blockieren die
Deinstallation; keine alten Browser-Use-venvs, `/opt`-Installationen oder privaten
Profile werden uebernommen/geloescht. Bei einem Fehler werden nur neu angelegte
Runtime-Dateien des Versuchs entfernt, Logs/Basiswerkzeuge bleiben.

Beispiele zum lesenden Status und zur bewussten Entfernung:

```bash
bash scripts/tools/browser_use_status.sh
bash scripts/tools/perplexity_mcp_doctor.sh
bash scripts/tools/perplexity_cookbook_uninstall.sh
```

Browser Use installiert noch keinen Chromium-Browser: CDP-/Browserpfad und eigene
leere Profile anschliessend separat konfigurieren. MCP ist nach dem Build noch
nicht in einem Client registriert; stdio statt oeffentlichem HTTP bevorzugen.
Erst bei freigegebener Nutzung `PERPLEXITY_API_KEY` ausserhalb Git setzen;
API-Nutzung kann Geld kosten. Kein Installer testet Modelle oder echte Suchanfragen.

**Abnahmegrenze:** Quellen/Buildvertraege wurden online geprueft; lokale Offline-
Tests pruefen Menue, Planausgaben, Lifecycle und Sicherheitsgrenzen. Die kompletten
SDK-/Bazel-Builds, grafischen Installationen und externe API-Funktion muessen auf
der Zielmaschine gesondert abgenommen werden. Keine pauschale Produktionsfreigabe.

## Sichere Einbindung

```text
Desktop-Browser / erlaubter Browser-Worker
           -> freigegebene Agententools / menschliche Bestaetigung
           -> lokales Gateway -> Ollama
           -> optional Perplexity MCP -> externe API (separat freigegeben)
```

Browser-Worker in eigenem Namespace oder separatem Hostprofil, Non-Root,
eigenem leeren Browserprofil und begrenztem CPU/RAM/Disk-Budget betreiben.
Keine bestehenden privaten Tabs, Cookies oder SSO-Sessions automatisch
uebernehmen. CDP/Debugging-Ports und MCP-HTTP nicht unauthentifiziert ins WAN.
Kein Kubernetes-ServiceAccount-Token und kein Docker-Socket fuer Webrecherche.

Webseiten/Transkripte sind untrusted Input: keine darin enthaltenen Shell-/MCP-
Anweisungen als Nutzerfreigabe behandeln. Downloads, Formulare, Nachrichten,
Kaeufe und Logins brauchen explizite Policies/Freigaben. SSRF-/Metadatenzugriff
und private Netze auch bei frei erlaubter Websuche sperren. NetworkPolicy allein
validiert keine URL/Redirects; dafuer kontrollierten Egress-Proxy einsetzen.

API-Key ausserhalb Git als eng berechtigtes Secret speichern, nur an den
zugehoerigen Toolprozess geben. Eine Browser-Pro-Mitgliedschaft ist kein Beleg
fuer enthaltene API-Credits. Keine Personalakten oder internen Dokumente an
Cloudrecherche senden. Im [Audit](../security/SECURITY_ARCHITECTURE_AUDIT_2026-10-25.md)
ist dieser Worker deshalb eine eigene Vertrauensgrenze.
