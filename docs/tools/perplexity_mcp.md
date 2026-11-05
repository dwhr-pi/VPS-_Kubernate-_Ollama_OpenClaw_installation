# Perplexity MCP: GitHub-Build mit privatem Node/npm

## Fehler vom 26.10.2026 um 03:45

`node fehlt` ist der Abbruchgrund, nicht Speicherplatzmangel. Der TypeScript- Build wurde damit noch
nicht ausgefuehrt. Der neue Runtime-Ordner wurde laut Log zurueckgerollt; es liegt kein fertig
installierter MCP-Server vor.

Jetzt kann eine fehlende passende Node/npm-Basis nach Zustimmung privat bereitgestellt werden. Nach
Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/perplexity_mcp_install.sh --dry-run
bash scripts/tools/perplexity_mcp_install.sh --install-build-deps
bash scripts/tools/perplexity_mcp_doctor.sh
```

Ohne Flag wird interaktiv `[j/N]` gefragt; Enter/EOF oder fehlende Freigabe laedt nichts herunter.
Plan/Status/Check/Doctor bleiben lesend und starten keinen Bootstrap. Logkennung:
`2026-10-26-perplexity-mcp-private-node-npm`.

## Buildbasis und Speicher

- Vorhandene Basis bevorzugt: Node 22 ab 22.13 oder Reihe 24 mit npm **10.9.9**. Dies ist die
  konservative Erkennungsregel des gemeinsamen Bootstrap-Helfers, nicht die Aussage, dass Upstream
  ausschliesslich diese Versionen unterstuetzt.
- Andernfalls **Node 22.23.4 samt gebuendeltem npm 10.9.9** aus dem offiziellen
  [Node-Archiv](https://nodejs.org/dist/v22.23.4/) fuer Linux amd64/arm64. Feste SHA256/Groessen,
  begrenztes Entpacken, Versions- und Dateiinventurpruefung.
- Dies ist eine ausdrueckliche **Buildwerkzeug-Ausnahme von nodejs.org**, kein
  Perplexity-Docker-Image. Der MCP-Quellcode bleibt aus dem gepinnten
  [offiziellen GitHub-Repository](https://github.com/perplexityai/modelcontextprotocol/tree/cd1d27cffe56739819abb3e56a18e26dbd88c487).
- Private Basis unter `tools/perplexity_mcp/toolchain/` im externen Workspace. Kein globales
  Node/npm, `npm install -g`, Shellprofil- oder System-Python-Umbau. Andere private
  Node-Installationen werden nicht ungeprueft uebernommen.
- Reserve bei neuem Bootstrap: **5120 MiB** (4096 + 1024 MiB Puffer), unter WSL auch auf dem
  Windows-Host. Die gemeldeten 10,5 GiB koennen die Startpruefung erfuellen; weiterer
  Paket-/Buildbedarf bleibt zu beachten.
- Node und npm werden aus dem **geprueften Kindprozess-PATH** aufgeloest. Eine erneute
  ausschliessliche Suche im globalen PATH waere falsch.
- npm bekommt zwei verschiedene private leere User-/Global-Konfigurationsdateien; kein doppeltes
  Laden von `/dev/null`, keine persoenliche `.npmrc` oder Tokens.

Bei fehlendem `libatomic.so.1` gibt es eine getrennte, gezielte Ubuntu-24.04- Freigabe fuer
`libatomic1`, kein beliebiges apt-Node. Nichtinteraktiv kann diese bewusst mit
`PERPLEXITY_MCP_INSTALL_RUNTIME_LIBS=1` zusammen mit dem Install- Flag erlaubt werden. Die
gemeinsame Systembibliothek bleibt bei Deinstallation erhalten. Ohne benoetigte Freigabe stoppt die
Versionspruefung ohne Erfolgsmarker.

## Was installiert wird und was nicht

Erst Basis pruefen/bereitstellen, dann Quellen laden. Paketweg bleibt
`npm ci --ignore-scripts --no-audit --no-fund`, danach explizit `npm run build` und
`node --check dist/index.js`. npm-Abhaengigkeiten kommen aus den Lockfile- Quellen; kein
GitHub-exklusives Netzwerk-/Offline-Versprechen.

Die private Node/npm-Basis bleibt bei einem spaeteren Paketfehler und bei App-Deinstallation
erhalten. Bootstrap-Fehler entfernen nur neues Staging; Paketfehler weiterhin nur die neu angelegte
Runtime. Bestehende fremde Ordner, Profile, Dienste und Nutzdaten werden nicht geloescht.

**Kein MCP-Serverstart, kein HTTP-Port, keine API-Abfrage und kein API-Key beim Build
erforderlich.** Der Build allein registriert auch keinen MCP-Client. Fuer spaetere Nutzung stdio
bevorzugen, `PERPLEXITY_API_KEY` ausserhalb Git gezielt an den Prozess uebergeben und
API-Kosten/Budgets separat freigeben. Kein pauschaler Zugriff auf Cookies, Browserprofile oder
sensible Dokumente. [Gesamtuebersicht](comet-and-browser-research.md).

Offline-Tests pruefen Bootstrap-Freigabe, Reserve/Hashes/Wiederverwendung, npm-Konfigurationen,
absoluten Kindprozess-PATH und Buildbefehle ohne Serverstart. Ein echter MCP-Paketbuild/API-Test
unter Ubuntu/WSL wurde hier nicht ausgefuehrt.

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
python3 -I -B scripts/tool_commands.py show perplexity_mcp
```

### SSH-Aktionen: `perplexity_mcp`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Perplexity_MCP` (ID `perplexity_mcp`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
