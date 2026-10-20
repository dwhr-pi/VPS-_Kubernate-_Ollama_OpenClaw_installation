# Anthropic CLI: quelloffene Claude-API-CLI `ant`

**Sinn und Zweck:** Mit der offiziellen CLI `ant` die Claude-Plattform aus
dem Terminal oder eigenen Skripten ansprechen. Der Client stammt aus
[anthropics/anthropic-cli](https://github.com/anthropics/anthropic-cli) und
steht unter der [MIT-Lizenz](https://github.com/anthropics/anthropic-cli/blob/78ab237474e7c34983d77f6f41fcd1152f32a7ce/LICENSE).
Quelloffener Client bedeutet nicht offene Modellgewichte oder kostenlose API-Nutzung.

Stand: **21.10.2026**, Setupstatus `experimental`, optional, kein Docker.
Gepruefter Pin: `78ab237474e7c34983d77f6f41fcd1152f32a7ce`.
Hier wurden keine Programme installiert, Go-Builds, Anmeldungen oder API-Aufrufe
ausgefuehrt. Der Installer ist vorbereitet und mit Offline-Fixtures getestet.

## Nicht mit Claude Code verwechseln

| Tool | GitHub / Lizenz | Aufgabe im Setup |
|---|---|---|
| **Anthropic_CLI / `ant`** | anthropics/anthropic-cli, MIT | Offizieller API-Client fuer Nachrichten und Plattformressourcen; aus Go-Quellen baubar |
| **Claude_Code / `claude`** | anthropics/claude-code, [Commercial Terms](https://github.com/anthropics/claude-code/blob/main/LICENSE.md) | Separater Coding-Agent; der bestehende GitHub-Referenzcheckout ist keine installierte CLI |

Die [Upstream-Anleitung](https://github.com/anthropics/anthropic-cli/blob/78ab237474e7c34983d77f6f41fcd1152f32a7ce/README.md)
beschreibt Nachrichten, Dateiuploads sowie Agenten-/Session-Verwaltung ueber
die API. `ant` wird dadurch nicht automatisch zum interaktiven Coding-Agenten
mit den Workflows von Claude Code. Bestehende Claude-Code-Profile werden nicht
umbenannt oder heimlich auf einen anderen Client umgeleitet.

## Installation aus GitHub vorbereiten und ausfuehren

Voraussetzung: vorhandenes Git, Python >=3.10 und fuer den Build **Go >=1.25**.
Massgeblich ist das [go.mod am Pin](https://github.com/anthropics/anthropic-cli/blob/78ab237474e7c34983d77f6f41fcd1152f32a7ce/go.mod);
die allgemeinere README-Angabe Go >=1.22 reicht fuer diesen Stand nicht aus.
Keine Go-/Systeminstallation oder automatischer Toolchain-Download durch das Setup.

```bash
bash scripts/tools/anthropic_cli_install.sh --dry-run
bash scripts/tools/anthropic_cli_install.sh
bash scripts/tools/anthropic_cli_doctor.sh
bash scripts/tools/anthropic_cli_status.sh
```

Im Tools-Menue heisst der Eintrag **Anthropic_CLI**. Die explizite Auswahl startet
den GitHub-Source-Build, keinen Container. Primaerquelle ist der feste GitHub-Pin,
kein `@latest`, kein Homebrew-/npm-/apt-Installationspfad.
Go-Modulabhaengigkeiten duerfen beim Build vom Go-Modulproxy geladen werden:
`proxy.golang.org`, Pruefsummen ueber `sum.golang.org`, Versionen aus go.mod/go.sum.
"Aus GitHub" bedeutet hier **nicht**, dass jedes transitive Paket allein von
GitHub geladen wird oder dass der Build ohne Netzwerk moeglich sein muss.

Nur Quellcode, ohne Go-Build und ohne Installed-Marker:

```bash
bash scripts/tools/anthropic_cli_install.sh --source-only
```

Zielbasis: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/anthropic_cli/`.

| Bestandteil | Pfad / Verhalten |
|---|---|
| Quellen | `source/`, Pin und unveraenderter Git-Zustand werden geprueft |
| Private CLI | `bin/ant`, nativ unter Windows `bin/ant.exe` |
| Status | `build-ready.json` erst nach erfolgreichem Build, Go-Buildinfo-Pruefung und Hash-Erfassung |
| Cache / Temp | `go-cache/`, `go-build-cache/`, `build-temp/`, isoliertes `build-home/`; keine persoenliche Go-Konfiguration uebernehmen |
| Logs / Lock | Eigenes aktuelles Log im externen `install_logs/`, Operationssperre gegen doppelte Installation |
| Reserven | 1 GiB Disk fuer Quellen, 4 GiB fuer Build; unter Linux mindestens 1 GiB aktuell verfuegbarer RAM; WSL-C:-Reserve separat geprueft |

Go laeuft mit `GOTOOLCHAIN=local`, CGO aus, Build-Parallelitaet 1 und zwei
Go-Prozessoren. Das gesetzte Go-GC-Speicherziel ist kein hartes RAM-Limit.
Der Build ist auf 1800 Sekunden je langer Phase begrenzt. Keine API-Keys,
Cloud-Credentials oder fremden Go-Overrides aus der Umgebung an den Build geben.
Die verwendete Toolchain muss vertrauenswuerdig sein; Umgebungsfilterung ist
keine Betriebssystem-Sandbox. Kein `go generate` und kein Start der gebauten CLI.
Die Buildinfo-Pruefung verwendet `go version -m`, nicht `ant --version`.

## Windows, Linux und macOS

Der Python-Installer baut mit der vorhandenen nativen Go-Toolchain; er startet
**keine WSL**. Unter Windows kann er direkt aus PowerShell aufgerufen werden:

```powershell
py -3 -B scripts/tools/helpers/anthropic_cli.py --dry-run
py -3 -B scripts/tools/helpers/anthropic_cli.py install
py -3 -B scripts/tools/helpers/anthropic_cli.py doctor
```

Nach eigener erfolgreicher Installation ist die CLI fuer eine bewusste lokale
Hilfeabfrage erreichbar, ohne PATH oder Shellprofile zu veraendern:

```powershell
& "$HOME/.openclaw_ultimate_user_data/tools/anthropic_cli/bin/ant.exe" --help
```

Unter Linux/macOS entsprechend `bin/ant --help` unter der gewaehlten Zielbasis
aufrufen. Diese Hilfeabfragen werden vom Installer nicht ausgefuehrt. Bei
`OPENCLAW_USER_DATA_DIR` muss der Pfad entsprechend angepasst werden. ARM oder
andere Architekturen sind erst nach einem echten Build/Smoke-Test als getestet
zu betrachten; keine Performance-Zusage fuer MiniPC, Raspberry Pi oder VPS.

## Update, Repair, Doctor und Deinstallation

```bash
bash scripts/tools/anthropic_cli_update.sh --dry-run
bash scripts/tools/anthropic_cli_update.sh
bash scripts/tools/anthropic_cli_install.sh --repair
bash scripts/tools/anthropic_cli_uninstall.sh --dry-run
bash scripts/tools/anthropic_cli_uninstall.sh
```

Update bleibt auf demselben Pin. Lokal geaenderte Quellen oder eine geaenderte
CLI werden nicht ueberschrieben. Doctor/Status starten weder CLI noch Go oder
API, sondern pruefen Quellpin, Besitzmarker und Binary-Hash. `api_tested=false`
bleibt ausdruecklich erhalten: ein gebauter API-Client ist kein erfolgreicher
Anmeldungs- oder Modelltest. Ein Quellcheckout allein gilt nicht als installiert.

Deinstallation entfernt nur die hashgepruefte eigene CLI und ihren Build-Marker.
Fremde Dateien, Quellen, Logs, Go-Cache, gemeinsam genutztes Go und Zugangsdaten
bleiben erhalten. Neue Build-Stagingdateien werden bei Fehlern entfernt;
ein Fehler beim abschliessenden Markerschreiben entfernt auch die neue CLI.
Alte erfolgreiche Installationen werden nicht wegen eines spaeteren Fremdfehlers
geloescht. Caches koennen Platz belegen; kein pauschales Autoremove.

## API-Freigabe bleibt ein eigener Schritt

Die Nutzung kann Daten an externe Anbieter senden und Kosten verursachen.
Kein `ant auth login`, `ant messages create`, `ant apply`, Upload oder Agentenstart
im Installer. Erst Modell-ID, API-Zugang, Budget, Datenfreigabe und Rechte pruefen.
Schluessel nicht als Kommandozeilenargument oder in Markdown/Logs hinterlegen.
Vorhandenes `ANTHROPIC_API_KEY` nur bewusst im separaten Nutzungsprozess verwenden.

Ein OpenAI-kompatibler Endpunkt wie OpenRouter/token8341 ist nicht automatisch
ein passender Anthropic-Protokolladapter. Auch Ollama und FreeLLMAPI werden nicht
automatisch konfiguriert oder getestet. Keine globale `ANTHROPIC_BASE_URL` aendern.

Weiter: [Coding-Agenten](../agents/coding-agent-profiles.md),
[API-Key-Katalog](../_API-Keys/PROVIDER_KEY_CATALOG.md),
[FreeLLMAPI](freellmapi.md), [Secrets](../SECRETS_AND_KEYS.md).
