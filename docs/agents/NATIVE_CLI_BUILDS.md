# Native Coding-CLIs: Build und Verwaltung

Nur nach ausdruecklichem Aufruf, ohne Root-Rechte und auf nativem Linux x86_64/glibc. Builds unter
Windows, macOS, ARM, musl und WSL werden abgelehnt; fuer WSL fehlt eine validierte
Host-Ressourcenpruefung. Planen funktioniert plattformuebergreifend und folgt unter Windows keinen
Datenpfad-Junctions. Bestehende `/opt`-Installationen, auch `/opt/openhands`, bleiben unveraendert.
Der vorhandene Qwen-Builder bleibt unabhaengig und unveraendert; die neuen Menue-/Registry-Pfade
verweisen auf den hier beschriebenen Helper.

## Aufruf und Status

```sh
python3 scripts/agents/install_cli.py opencode
python3 scripts/agents/install_cli.py codex_cli install --plan
bash scripts/tools/opencode_install.sh --plan
bash scripts/tools/aider_install.sh --plan --hashed-lock /absolute/reviewed.txt --lock-sha256 REVIEWED_SHA256
```

Standard ist `plan`. Schnittstelle:
`install_cli.py TOOL [plan|install|update|uninstall|doctor|status|check] [OPTIONS]`. TOOL:
`opencode`, `aider`, `codex_cli`, `openhands`. Optionen: `--plan`, `--dry-run`,
`--data-dir ABSOLUTE`, `--toolchain-bin ABSOLUTE`, `--hashed-lock ABSOLUTE`, `--lock-sha256 SHA256`.
Unbekannte Argumente werden abgelehnt.

Die Wrapper `scripts/tools/TOOL_ACTION.sh` waehlen ihre benannte Aktion und reichen Argumente
unveraendert weiter. Sie starten den Helper mit `python3 -I -B`. Install-Wrapper bauen
beziehungsweise bereiten Quellen vor; `--plan` und `--dry-run` verhindern jede Aktion. Wrapper bei
Bedarf mit `bash` aufrufen.

`install` verwendet bereits gueltige Nachweise desselben Pins unter dem Lock wieder. `update` baut
denselben geprueften Pin bewusst neu, niemals die aktuelle Branch-Spitze. Neue Pins erfordern eine
erneute Quellen-, Lizenz- und Build-Pruefung. `status`, `doctor` und `check` pruefen nur
Integritaetsnachweise, ohne Agent, Login, Versionsaufruf, Provider-Test oder Netzwerkzugriff; sie
reparieren nichts.

Rueckgabecodes: **0** fuer Plan, gueltigen Zustand oder Deaktivierung; **1** bei fehlender
Installation fuer `check`/`doctor`; **2** bei Ablehnung oder Fehler. `status` liefert bei fehlender
Installation 0 mit `state: absent`. Native CLIs melden `built` und `runtime_ready: true`: Artefakt
gebaut und Integritaet geprueft, aber kein Nachweis fuer Login, Modelle oder Laufzeitgesundheit.
SDK-Quellen melden `state: source-prepared, runtime_ready: false`; auch ein erfolgreicher `check`
bedeutet hier keine betriebsbereite Anwendung.

## Gepruefte Quellen und Builds

GitHub-Metadaten, Lizenzen und Build-Dateien wurden am 2026-10-29 an diesen vollstaendigen Commits
geprueft. `config/agents/native_clis.json` enthaelt deren SHA256-Nachweise; Abhaengigkeitshashes
werden nicht erfunden.

| ID        | Offizielle Quelle mit festem Commit                                                                                           | Lizenz                    |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| opencode  | [anomalyco/opencode](https://github.com/anomalyco/opencode/tree/f023f7c36c090260a49c6e4da0ff69cbbd10c168)                     | MIT, `LICENSE`            |
| aider     | [Aider-AI/aider](https://github.com/Aider-AI/aider/tree/5dc9490bb35f9729ef2c95d00a19ccd30c26339c)                             | Apache-2.0, `LICENSE.txt` |
| codex_cli | [openai/codex](https://github.com/openai/codex/tree/8fdf6472955749a731fd9e4b8ffc218e8e80c51d)                                 | Apache-2.0, `LICENSE`     |
| openhands | [OpenHands/software-agent-sdk](https://github.com/OpenHands/software-agent-sdk/tree/47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5) | MIT, `LICENSE`            |

### OpenCode

Der feste
[packageManager](https://github.com/anomalyco/opencode/blob/f023f7c36c090260a49c6e4da0ff69cbbd10c168/package.json)
verlangt vorhandenes Bun 1.4.4. Im Quellwurzelverzeichnis:
`bun install --frozen-lockfile --ignore-scripts`, danach
`bun run --cwd packages/cli build --single --skip-install`. `--skip-install` ist nur nach Pruefung
der vorbereiteten Pakete `@opentui/core` 0.7.0 und `@opencode-ai/pty` 0.3.1 erlaubt. So entfaellt
das zusaetzliche, nicht eingefrorene `bun install` des Build-Skripts. Fehlende Abhaengigkeiten oder
Build-Dateien fuehren zum Abbruch, nicht zu Ersatzlaunchern.

Artefakt: `source/packages/cli/dist/cli-linux-x64/bin/opencode`, keine Desktop-App. Das
Upstream-Skript bereinigt sein dist-Verzeichnis im neuen Checkout selbst; Build-Helfer koennen
weitere Build-Dateien herunterladen.

### Aider

Die festen
[requirements](https://github.com/Aider-AI/aider/blob/5dc9490bb35f9729ef2c95d00a19ccd30c26339c/requirements.txt)
enthalten keine Hashes und teilweise Versionsbereiche. Fuer einen neuen Build sind ein extern
gepruefter `--hashed-lock` und dessen `--lock-sha256` zwingend. Der Lock muss alle
plattform-/Python-spezifischen Abhaengigkeiten einschliesslich `build`, `setuptools`,
`setuptools-scm` und deren Abhaengigkeiten abdecken. Format:
`package[extras]==version --hash=sha256:...`; Kommentare und Fortsetzungszeilen sind erlaubt,
Includes, URLs, Indizes, Versionsbereiche und Umgebungsmarker nicht. Installation nur gehashter
Wheels mit `--require-hashes --only-binary=:all: --no-deps`.

Eine private venv nutzt vorhandenes `python3` (>=3.10,<3.15). Build:
`python -I -m build --wheel --no-isolation`; lokales Wheel mit `--no-index --no-deps` installieren,
danach `pip check`. Keine globale Python-Aenderung, kein Editiermodus und keine ungeprueften
Backend-Downloads. Fehlende Pakete bedeuten Abbruch.

Artefakt: `venv/bin/aider`, Einstiegspunkt `aider.main:main`. Lock-Hash und venv-Verzeichnisinhalt
werden zusaetzlich nachgewiesen.

### Codex

Die feste
[toolchain](https://github.com/openai/codex/blob/8fdf6472955749a731fd9e4b8ffc218e8e80c51d/codex-rs/rust-toolchain.toml)
verlangt vorhandene echte `cargo`- und `rustc`-Programme der Version 1.95.0. Rustup-Shims sind
gesperrt. `--toolchain-bin` kann auf deren vorhandenes `bin`-Verzeichnis zeigen;
Systemvoraussetzungen muessen separat bereitstehen.

In `source/codex-rs`: `cargo build --locked --release --bin codex`. Artefakt:
`source/codex-rs/target/release/codex`.

### OpenHands: SDK-Quellen, keine Anwendung oder Laufzeit

`openhands install` laedt und prueft ausschliesslich die festen SDK-Quellen. Kein SDK-Build, keine
Python-Abhaengigkeiten, kein Server, Docker oder Image. Pruefartefakt: `source/LICENSE`, zusaetzlich
Hash des SDK-Quellverzeichnisses. Marker und Status bleiben `runtime_ready: false`,
`state: source-prepared`. Fuer die Ausfuehrung werden ein separat bereitgestellter netzwerkloser
Worker mit SDK im selben Prozess und ein manuell vorbereitetes/geprueftes Worker-Image benoetigt.
Die Lizenzdatei ist kein ausfuehrbares Agentenartefakt.

## Ablage und Sicherheit

Basis: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/ID/native-coding`.
`--data-dir` hat Vorrang. Datenpfade muessen absolut, benutzereigen und ohne Schreibrechte fuer
Gruppe/Andere sein; Traversierung und Symlink-Vorfahren sind gesperrt. Builds nutzen `.lock`,
`versions/FULL_COMMIT-RANDOM_ID/`, `source/`, privates `build-home/` sowie bei Bedarf `venv/`,
`wheels/` und `requirements.hashed.txt`.

`current/OWNED.json` dokumentiert Eigentuemer, UID, Quelle, Commit, Lizenz, Build-Datei-Hashes,
Artefaktpfad/SHA256 und Bereitschaft. Nur vollstaendig gepruefte Versionen werden per atomarem
Austausch des `current`-Symlinks aktiviert. Die Artefaktpfade oben gelten relativ zu `current/`;
globale PATH-Links gibt es nicht. `uninstall` prueft diese Nachweise und entfernt nur `current`.
Quellen, Builds, Marker, Zugangsdaten, Fehlversuche und `/opt` bleiben erhalten. Keine rekursive
Loeschung; manipulierte Nachweise erfordern manuelle Pruefung. Fehler vor der Aktivierung lassen die
bisherige Version unveraendert.

Die Build-Umgebung ist eingeschraenkt: privates HOME und eigene Konfigurations-, Cache- und
Temporaerverzeichnisse; keine uebernommenen Zugangsdaten, Traces, Shell-Hooks, Python-Pfade,
Cargo-Wrapper oder Provider-/Proxy-Einstellungen. Git nutzt nur HTTPS, ohne Hooks,
Credential-Helfer, Eingabeaufforderungen oder Submodule. Quelle, HEAD und Build-Nachweise werden vor
und nach dem Build geprueft. Mindestens 20 GiB freier Platz fuer OpenCode/Codex, 10 GiB fuer
Aider/SDK. Jeder Subprozess hat 3600 Sekunden Zeitlimit; Build-Ausgaben werden verworfen, Metadaten
groessenbegrenzt gelesen. Fehler und Zeitueberschreitungen brechen ohne Prozessausgaben oder Traces
ab. Builds sind weder netzwerklos noch eine Betriebssystem-Sandbox und sollten nicht in sensiblen
Benutzerkonten laufen.

## Tests

```sh
python3 -m unittest discover -s tests -p test_native_coding_clis.py -v
```

Die Tests ersetzen Build-/Prozessaufrufe durch Mocks und pruefen unter anderem Pins, Lizenzen,
Wrapper, Pfad-/Ressourcenschutz, Nachweise, Wiederverwendung, Zeitlimits und SDK-Quellenstatus.
Keine Installation, Downloads, Builds, Anmeldung oder Agentenausfuehrung. Echte Upstream-Builds sind
weiterhin ungeprueft.
