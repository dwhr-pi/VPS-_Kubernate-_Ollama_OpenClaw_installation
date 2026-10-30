# Black und mypy: Qualitaetswerkzeuge fuer Coding-Agenten

**Sinn und Zweck:** Black prueft einheitliche Python-Formatierung; mypy sucht Typfehler vor dem
Programmstart. Beide ergaenzen Tests, ersetzen sie aber nicht. Claude Code, Qwen Code, OpenClaw und
Automaton koennen diese lokalen CLIs nach ausdruecklicher Projektfreigabe verwenden. Kein Modell und
kein API-Key notwendig.

Stand: 21.10.2026. **Optional / experimental**, nicht standardmaessig installiert. Keine
Installation oder WSL-Aktion bei der Erstellung dieser Integration; Offline-Fixtures sind kein
erfolgreicher Livebuild.

| Tool  | Offizielle GitHub-Quelle                      | Lizenzhinweis                                  | Gepruefter Stand                                                                               | Bedarf / Risiko                                                               |
| ----- | --------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Black | [psf/black](https://github.com/psf/black)     | MIT                                            | [26.10.1, 258e7db](https://github.com/psf/black/tree/258e7dbf348bc23cb70b8cdf693481c04634ebcc) | Python >=3.10; 2 GiB Disk-Reserve; Buildhooks und versehentliche Formatierung |
| Mypy  | [python/mypy](https://github.com/python/mypy) | MIT, weitere PSF-/Typeshed-Hinweise in LICENSE | [2.4.0, 935ba8a](https://github.com/python/mypy/tree/935ba8afba7ceacca0651579450c74339f343016) | Python >=3.10; 2 GiB Disk-Reserve; Projektplugins koennen Code ausfuehren     |

Zielhosts: Linux/MiniPC, bewusst vom Nutzer verwendetes WSL, Windows nativ und macOS mit vorhandenem
Python 3.10-3.15, Git, SSL, venv und ensurepip. Keine GPU oder Kubernetes erforderlich.
Architektursupport haengt auch von passenden Wheels der Abhaengigkeiten ab; kein pauschaler
ARM-/MiniPC-Live-Testnachweis.

## GitHub statt Docker

Die Primaerpakete werden aus **festen GitHub-Commits** gebaut, nicht aus einem Docker-Image und
nicht als gleichnamiges ungepinntes PyPI-Hauptpaket geladen. Build-/Runtime-Abhaengigkeiten kommen
weiterhin von **PyPI**. Sie sind nicht vollstaendig mit Hashes eingefroren; die aufgeloesten
Versionen stehen im Log. Fuer transitive Pakete werden Wheels verlangt; fehlt ein passendes Wheel,
wird abgebrochen, statt unbemerkt Rust-/C-Source-Builds nachzuziehen. Black-mypyc und
mypy-mypyc-Kompilierung werden nicht aktiviert. Ein Buildhook fuehrt dennoch Upstream-Code aus:
Umgebungsfilterung ist keine Sicherheits-Sandbox.

## Bewusste Installation

```bash
bash scripts/tools/black_install.sh --dry-run
bash scripts/tools/black_install.sh
bash scripts/tools/mypy_install.sh --dry-run
bash scripts/tools/mypy_install.sh
bash scripts/tools/black_doctor.sh
bash scripts/tools/mypy_status.sh
```

Die Eintraege **Black** und **Mypy** sind im Tools-Menue verfuegbar. Kein sudo, apt, Docker,
System-Python-Ersatz oder globaler PATH-Eintrag. Bei fehlendem venv/ensurepip vorher bewusst ein
passendes vorhandenes Python waehlen:

```bash
DEV_QUALITY_PYTHON_BIN=/absoluter/pfad/python3.12 bash scripts/tools/black_install.sh --repair
```

Ein Auswahlpfad installiert kein fehlendes Python-Paket. Unter Debian/Ubuntu kann zum ausgewaehlten
Interpreter das passende `python3.x-venv` fehlen; dies muss der Betreiber bewusst bereitstellen. Der
Installer aendert WSL nicht von Windows aus. Nativ unter Windows geht es auch ohne Bash:

```powershell
py -3 -B scripts/tools/helpers/dev_quality.py black --dry-run
py -3 -B scripts/tools/helpers/dev_quality.py black install
py -3 -B scripts/tools/helpers/dev_quality.py mypy install
```

Ein alter, bisher nicht zentral registrierter Black-Installer nutzte PyPI/apt und `/opt/black`.
Dieser Wrapper ist jetzt auf den GitHub-Installer umgestellt. Ein alter `/opt/black`-Bestand wird
**weder migriert noch geloescht** und gilt nicht automatisch als neue private GitHub-Installation.
Die neue Deinstallation fasst solche Altbestaende nicht an; fuer deren Bereinigung vorher gesondert
Besitz, Inhalt und eventuelle weitere Nutzer pruefen.

## Speicherung, Status und Rollback

Basis: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/<black|mypy>/`.
`source/` enthaelt den GitHub-Pin. Jedes neue venv hat einen eigenen `env-*`-Pfad; es wird nach dem
Aufbau nicht verschoben, damit Python-Launcher gueltig bleiben. Der erfolgreiche Installer zeigt den
absoluten Interpreterpfad an.

- Lock gegen gleichzeitige Aktionen fuer dasselbe Tool und aktuelles Vorgangslog.
- Disk-Vorpruefung fuer Ziel und bei erkanntem WSL auch C:; keine Platzgarantie fuer die gesamte
  Laufzeit. Die gemeinsame Setup-Speicherwache bleibt zusaetzlich aktiv.
- Timeout: venv 180 s, Installationsphase 1800 s, kleinere Pruefphasen 30-60 s; keine unbegrenzte
  Reparaturschleife oder harte RAM-/CPU-Sandbox.
- Nach Installation: `pip check`, Paketversionskontrolle, Datei-/Hashmanifest. Erst dann
  `build-ready.json`; `project_tested=false` bleibt sichtbar.
- Bei Fehlern wird nur das neue eigene venv entfernt. Quellcache, Logs und bereits erfolgreich
  installierte Umgebungen bleiben erhalten.
- Status/Doctor lesen den Besitznachweis, die Dateien und den Git-Stand; keine CLI-Ausfuehrung,
  Downloads oder Projektanalyse. Das Menue nutzt den schnellen Erfolgsmarker, keine teure
  Hashpruefung bei jedem Oeffnen.

## Nutzung im eigenen Projekt

Den vom Installer ausgegebenen Interpreterpfad einsetzen. Keine komplette Benutzerumgebung
durchsuchen. Zunaechst nur den benoetigten Projektordner pruefen:

```bash
"/absoluter/toolpfad/black/env-XYZ/bin/python" -B -m black --check --diff src/ tests/
"/absoluter/toolpfad/mypy/env-XYZ/bin/python" -B -m mypy src/
```

Unter Windows statt `bin/python` den Pfad `Scripts/python.exe` verwenden. Black ohne `--check`
veraendert Dateien: nur nach ausdruecklicher Freigabe. mypy liest Projektkonfiguration und kann
konfigurierte Plugins ausfuehren. Fremde Projekte/Plugins erst pruefen; ein privates Tool-venv
enthaelt nicht automatisch alle Projektbibliotheken und Typ-Stubs. Fuer umfassende Typpruefung die
Abhaengigkeiten des Zielprojekts separat kontrolliert bereitstellen.

## Update und Deinstallation

```bash
bash scripts/tools/black_update.sh --dry-run
bash scripts/tools/black_update.sh
bash scripts/tools/mypy_install.sh --repair
bash scripts/tools/black_uninstall.sh --dry-run
bash scripts/tools/black_uninstall.sh
bash scripts/tools/mypy_uninstall.sh
```

Update bleibt beim selben Pin und ist bei intaktem Bestand idempotent. Repair ueberschreibt keine
veraenderte Installation. Die Deinstallation entfernt nur das vollstaendig hashgepruefte eigene venv
und seinen Marker; generierte Python-Bytecode-Caches gelten als wegwerfbar. Unbekannte/geaenderte
Dateien blockieren das Loeschen. Quellen, Build-Temp/Home, Logs, Systemwerkzeuge und persoenliche
Projekte bleiben erhalten. Ein verwaistes venv ohne Marker wird nicht pauschal geloescht; erst
manuell pruefen.

Weiter: [Manus-Interview: lokale Umsetzung](../tutorials/manus-development-workflow.md),
[Agentic Coding](agentic-coding.md), [Queue](../CODEX_TASK_QUEUE.md).
