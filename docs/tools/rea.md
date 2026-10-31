# REA: Reverse Engineer Anything

**Sinn und Zweck:** REA verbindet Coding-Agenten mit Analysewerkzeugen fuer Softwareverhalten,
Web-/JavaScript-Anwendungen und native Programme. Fuer unseren Anwendungsfall dient es optional
dazu, autorisierte Beobachtungen nachzuvollziehen und daraus eine **eigene, kleine lokale App** zu
entwickeln. REA ist kein Abo-Entsperrer, kein Ersatz fuer eine Produktlizenz und keine Garantie
eines rechtlich zulaessigen oder wirtschaftlichen Nachbaus.

## Quelle und Einordnung

- Original: [morluto/rea auf GitHub](https://github.com/morluto/rea).
- Website: [rea.tools](https://rea.tools/).
- Setup-Pin vom 20.10.2026: `1629266e3c08c90fed6bba5383528af7986a12b7`.
- Paketname laut
  [package.json](https://github.com/morluto/rea/blob/1629266e3c08c90fed6bba5383528af7986a12b7/package.json):
  `rea-agents`, Quellversion `6.7.0`, MIT. Keine Aussage zur npm-Veroeffentlichung.
- [Tutorial: Eigene App statt Abo](../tutorials/own-app-with-rea.md): Analyse-Prompt, Bau-Prompt,
  Steckbrief und Rechtepruefung.

Keine ungeprueften Sterne-/Forkzahlen als Empfehlung uebernommen. Der eingefuegte Ausgangstext wurde
zusammengefuehrt und fachlich ueberarbeitet. REA kann wesentlich mehr als Screenshots ansehen.
Runtime-Anhaenge, Netzwerkaufnahmen, Debugger und Decompiler bleiben fuer diesen Workflow aus.

## 1. GitHub-Installation im Ultimate KI Setup

Im Tools-Menue **REA** waehlen oder:

```bash
bash scripts/tools/rea_install.sh
```

**Standardumfang: echter gepinnter GitHub-Checkout, noch keine gebaute CLI.** Python 3.10+ und Git
muessen vorhanden sein. Kein Docker, kein npm-Paket als Toolquelle und kein automatischer
System-Python-/Node-Umbau.

Ablauf: eigener Log, Lock, Ressourcenpruefung, flacher GitHub-Fetch am Pin, Pruefung von
Repository/Paket und erst danach Erfolgsmarker. Quellen liegen im externen User-Workspace unter
`~/.openclaw_ultimate_user_data/tools/rea/source/`. `OPENCLAW_USER_DATA_DIR` kann den externen
Workspace festlegen. Symlink-/Junction-Ziele und Nutzdaten im Setup-Repo werden abgelehnt.

**Installiert im Menue bedeutet hier Quellvorbereitung**, nicht MCP-Verbindung oder erfolgreich
analysiertes Ziel. Die Statusausgabe unterscheidet `github-source` und `github-source-built`; beide
sind kein Laufzeittest.

## 2. Optional: Source-Build ohne Docker

Nur nach Pruefung von Lizenz, Lockfile und Build-Skripten und mit bewusstem Ressourcenbudget auf
Linux/macOS:

```bash
REA_BUILD=1 INSTALL_HEAVY_TOOLS=1 bash scripts/tools/rea_install.sh --repair
```

Der Build verlangt vorhandenes Node passend zu `^22.19.0 || ^24.11.0 || >=26.0.0` und npm `11.16.0`.
Nicht einfach jede Version groesser als 22 verwenden: Node 23/25 sind durch diesen Ausdruck nicht
zugelassen. Kein automatischer Runtime-Download.

Dependencies werden mit `npm ci --ignore-scripts` geladen, danach wird der gepruefte
`build:cached`-Task explizit ausgefuehrt. Build-Skripte sind Code: Der GitHub-Pin ist keine Sandbox.
Paketabhaengigkeiten kommen weiterhin aus Paketregistries. Browserdownloads werden ueber die
bekannten Playwright-/Puppeteer-Schalter abgewählt; keine Modell-/Engine-Installation durch unser
Skript. Je Buildphase maximal 3600 Sekunden. Die Prozessausgabe steht im aktuellen Log, nicht als
versteckter Hintergrundjob.

Das Setup prueft anschliessend erwartete CLI-/MCP-Artefakte und ihre Hashes. **Kein echter
Source-Build wurde bei dieser Erweiterung ausgefuehrt**; der Weg bleibt experimentell. Native
Windows-Builds sind bewusst manuell: nach dem GitHub-Checkout in PowerShell das Quellverzeichnis
oeffnen und die versionierten
[Upstream-Buildhinweise](https://github.com/morluto/rea/blob/1629266e3c08c90fed6bba5383528af7986a12b7/scripts/rea.mjs)
pruefen. Unser automatischer Build lehnt Windows ab, statt WSL zu starten.

## 3. MCP nur separat und nach Planfreigabe

Unser Installer fuehrt **niemals `rea setup`** aus. Er schreibt keine Claude-/Qwen-Konfiguration,
startet keinen MCP-Server und installiert keine Skills, Hopper, Ghidra oder IDA automatisch.

Erst nach erfolgreichem, separat geprueftem Build im Quellordner:

```bash
# Plant Konfigurationsaenderungen, noch keine Zustimmung:
node scripts/rea.mjs setup --client claude_code --skill=false --dry-run
# Nach eigener Planpruefung, bewusst im interaktiven Terminal:
node scripts/rea.mjs setup --client claude_code --skill=false
```

Die
[Upstream-Anleitung](https://github.com/morluto/rea/blob/1629266e3c08c90fed6bba5383528af7986a12b7/docs/installation.md)
beschreibt Vorschau, Backups und Zustimmung. `--skill=false` vermeidet hier eine zusaetzliche
Skill-Aktivierung. Nur den gewollten Client waehlen, keine pauschale Konfiguration aller erkannten
Agenten und keine Hopper-Freigabe. Agenten neu laden; bei Claude Code die Verbindung ueber `/mcp`
kontrollieren. Ein Konfigurationseintrag allein beweist keinen verbundenen oder sicheren Server.

Fuer die isolierte Registrierung/Diagnose stets dasselbe Benutzerprofil nutzen. Direkte
Registrierung eines gebauten GitHub-Checkouts muss auf dessen dauerhaften absoluten
`scripts/rea.mjs`-Pfad mit passender Node-Runtime zeigen, nicht auf einen temporaeren npm-Cache. Den
Vorschlag vor Uebernahme pruefen. MCP-Toolrechte im Client begrenzen; ein Prompt ersetzt keine
Zugriffskontrolle. Fuer Screenshot-Analyse allein ist REA/MCP gar nicht erforderlich.

## 4. Windows und Qwen Code Desktop

Der aktuelle REA-Quellstand nennt `qwen_code` als Client-ID. Das ist **nicht** Vercels `qwen-code`
aus find-skills.
[Qwen Code dokumentiert MCP](https://github.com/QwenLM/qwen-code/blob/main/docs/users/features/mcp.md);
die konkrete [Desktop-Version](qwen-desktop-windows.md) bleibt separat zu pruefen. Keine pauschale
Funktionsgarantie fuer Qwen Chat/Studio oder jede GUI-Version.

Nativer Windows-Checkout ohne WSL:

```powershell
py -3 -B scripts/tools/helpers/rea_source.py --dry-run
py -3 -B scripts/tools/helpers/rea_source.py install
```

Das Windows-Benutzerprofil ist nicht das WSL-Profil. Nach bewusst manuellem Build kann im
Quellordner zunaechst der Qwen-Plan geprueft werden:

```powershell
node scripts/rea.mjs setup --client qwen_code --skill=false --dry-run
```

Erst nach eigener Freigabe ohne `--dry-run` wiederholen und die Verbindung in der installierten
Qwen-Version kontrollieren. Kein Desktop-/MCP-Livetest durch diese Repo-Aenderung. Claude Code,
Claude Desktop und Qwen Code bleiben unterschiedliche Clients mit unterschiedlichen
Konfigurationsdateien.

## 5. Optionaler npm-Einzeiler aus dem Ausgangstext

```bash
npx rea-agents setup
```

**Nur als erklaerte Alternative:** Das installiert/laedt die Tool-Distribution aus npm, nicht
ausschliesslich aus GitHub, und kann Agentenkonfiguration aendern. Es ist nicht unser
Setup-Installationsweg. Der Einzeiler ist unpinnt; kein blindes `@latest setup` als Reparatur
empfehlen. Quellversion und veroeffentlichte Paketversion koennen auseinanderliegen. Kein
`curl | bash` und kein automatisch gestarteter Setup-Wizard in unserem Installer.

REA hat eine MIT-Lizenz. Claude Code und externe Modelle haben eigene Zugangs-/Kostenbedingungen;
nicht pauschal ein einziges kostenpflichtiges Claude-Abo als einzige Anmeldemoeglichkeit
voraussetzen. Lokale Inferenz kann API-Gebuehren vermeiden, aber nicht Strom-, Hardware- oder
Wartungskosten.

## 6. Pruefung, Update und Entfernen

```bash
bash scripts/tools/rea_status.sh
bash scripts/tools/rea_doctor.sh
bash scripts/tools/rea_update.sh
bash scripts/tools/rea_uninstall.sh
```

Alle Wrapper unterstuetzen `--dry-run`. Unser Doctor prueft Quellen/Marker und ggf. Build-Hashes
**offline**, ohne REA zu starten oder private Agentenkonfiguration zu lesen. Update behaelt den
gleichen Pin und setzt keine lokalen Aenderungen zurueck. `--repair` repariert keine fremden Dateien
durch Loeschen/Reset; bei Abweichung zuerst sichern und manuell vergleichen.

Ein fehlgeschlagener Download bereinigt nur den neu angelegten Download-Ordner. Ein fehlgeschlagener
Build erzeugt keinen neuen Erfolgsmarker; Teilbuild und Quellen bleiben fuer Diagnose erhalten. Logs
nennen Fehler und Speicherstand. Nach Absturz kann ein Lock zurueckbleiben: erst laufende Vorgaenge
pruefen.

**Unsere Deinstallation deaktiviert nur die Setupregistrierung.** Quellen, Build, Logs,
Evidence-Dateien sowie manuell eingerichtete Agenten- registrierungen bleiben erhalten. Das
vermeidet beschaedigte Clientpfade oder geloeschte Untersuchungsdaten. Manuelle MCP-Eintraege zuerst
im richtigen Client/Profil entfernen oder nach der
[Upstream-Deinstallationsdokumentation](https://github.com/morluto/rea/blob/1629266e3c08c90fed6bba5383528af7986a12b7/docs/installation.md#diagnose-update-and-remove)
pruefen. Kein automatisches `--purge-data`. Ein spaeteres Entfernen des Quellordners darf erst nach
Backup und Pruefung verbleibender Referenzen erfolgen.

## 7. Ressourcen und optionale Analyseprogramme

| Ziel / Baustein        | Einordnung                                                                                                    |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| GitHub-Quellcheckout   | 1 GiB freie Disk als Reserve; vorhandenes Python/Git, keine GPU                                               |
| Optionaler Build       | 8 GiB Disk, unter WSL auch C:; Linux mindestens 2 GiB verfuegbarer RAM; ein Installationslock                 |
| MiniPC / RPi5          | Screenshot-Steckbrief bevorzugen; Source-Build und native Anbieter architekturabhaengig                       |
| Oracle VPS / Dual Xeon | Kein Desktop-/Prozesszugriff automatisch; keine Admin-/MCP-Ports oeffnen                                      |
| Gaming-PC / RTX 5080   | REA-Quellvorbereitung braucht 0 VRAM; Modellbedarf separat                                                    |
| Kubernetes             | Kein Deployment/Host-Mount/Debuggerzugang durch dieses Tool                                                   |
| Hopper / IDA           | Separate, teils proprietaere/kommerzielle Werkzeuge; nicht durch REAs MIT-Lizenz freigegeben                  |
| Ghidra                 | Separates Open-Source-Analyseprogramm mit eigener Lizenz/Java-/Plattformvoraussetzung, hier nicht installiert |

Das Tools-Menue kann vorher strengere allgemeine Ressourcenreserven verlangen. Diese Zahlen sind
konservative Guards, keine gemessene Gesamtgroesse jeder REA-Analyse. Kein Dauer-Worker und keine
automatische App-Untersuchung.

Rechte, Datenschutz und Clean-Room-Vorgehen beschreibt das
[Tutorial](../tutorials/own-app-with-rea.md). Siehe auch
[Security Baseline](../SECURITY_BASELINE.md), [Secrets](../SECRETS_AND_KEYS.md),
[find-skills](find-skills.md) und [Tool-Index](../TOOL_INDEX.md).
