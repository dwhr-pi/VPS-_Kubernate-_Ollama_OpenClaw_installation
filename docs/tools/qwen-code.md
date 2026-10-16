# Qwen Code aus GitHub installieren, ohne Docker

Qwen Code ist ein Terminal-Coding-Agent, nicht das Modell selbst und nicht die
[Windows-Desktop-App](qwen-desktop-windows.md). Optional/experimental. Der
Installer baut nur CLI-Code; kein Login, Agent, Modell oder Dienst startet.

## Voraussetzungen

- Linux/WSL als normaler Benutzer, nicht mit `sudo` bauen.
- Node **22.x**, npm, Git, flock, Corepack und **pnpm 11.24.0**.
- `COREPACK_ENABLE_NETWORK=0 corepack pnpm --version` muss bereits lokal
  `11.24.0` liefern. Keine globale Runtime-Aktualisierung durch den Installer.
- Planungsreserve: **8 GiB Gesamt-RAM und 10 GiB freier Linux-Speicher**, unter
  WSL zusaetzlich **10 GiB auf Windows C:**. Keine gemessenen Mindestwerte;
  freien RAM und Last separat pruefen, andere schwere Jobs vorher beenden.
- Native Pakete koennen Python 3, make und einen C/C++-Compiler benoetigen.

Andere Tools koennen andere pnpm-Versionen verlangen. Versionen pro Projekt
verwalten, nicht wahllos global ersetzen. Keine automatische Profilinstallation.

## Installation

Im aktuellen Setup-Verzeichnis:

```bash
bash scripts/tools/qwen_code_install.sh --dry-run
bash scripts/tools/qwen_code_install.sh
bash scripts/tools/qwen_code_status.sh
bash scripts/tools/qwen_code_doctor.sh
```

Oder **Qwen_Code** im Tool-Menue bewusst auswaehlen. Quelle:
[QwenLM/qwen-code v0.25.1](https://github.com/QwenLM/qwen-code/releases/tag/v0.25.1),
Commit `c1a8218f38203e272e6e965778ed6a2795cfeed7`. Code Apache-2.0;
Paket-/Provider-/Modellbedingungen separat pruefen.

Build im gepinnten Checkout: `pnpm install --frozen-lockfile`,
`pnpm run build --cli-only`, `pnpm run bundle`. Der Installer setzt
`BUILD_SANDBOX=0`, `QWEN_SANDBOX=false`, `QWEN_SKIP_PREPARE=1`, `HUSKY=0`,
`COREPACK_ENABLE_NETWORK=0`, `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` und
`PUPPETEER_SKIP_DOWNLOAD=1`; `QWEN_HOME` zeigt auf privates `build-home`.
Kein `build:all`, `build:sandbox`, `build-and-start`, Desktop-/Android-Build
oder globales `npm install -g`. Kein Docker/Podman.

Paketabhaengigkeiten/native Prebuilds kommen zusaetzlich aus Registries/anderen
Hosts. Lifecycle-Skripte einschliesslich Postinstall/Prepare laufen beim Build;
`QWEN_SKIP_PREPARE=1` vermeidet den sonst doppelten Vollbuild. Kein
Supply-Chain-Audit oder OS-Sandbox-Versprechen. Nur auf vertrauenswuerdigem
Laborhost ohne produktive Schluessel bauen.

```text
~/.openclaw_ultimate_user_data/tools/qwen_code/source/
~/.openclaw_ultimate_user_data/tools/qwen_code/source-built
~/.openclaw_ultimate_user_data/install_logs/*_qwen_code_source_*.log
```

Alternativ `OPENCLAW_USER_DATA_DIR`: absoluter symlinkfreier privater Pfad
ausserhalb des Setup-Repos. Origin/Commit/lokale Aenderungen, Build-Lock und
Ressourcen werden geprueft. Erfolg erst nach CLI-Artefakten und `node --check`;
das ist noch kein funktionaler Provider-Test. Doctor startet die CLI nicht.

## Bewusster erster Start

Erst nach dem Build, in einem freigegebenen Testprojekt ohne produktive Secrets:

```bash
# Nur manuell Hilfe ansehen, nicht Teil der Installation:
node "$HOME/.openclaw_ultimate_user_data/tools/qwen_code/source/scripts/cli-entry.js" --help
```

Fuer eine spaetere interaktive Sitzung denselben Befehl ohne `--help` bewusst
aufrufen. Dabei koennen Konfiguration/Login/Providerzugriff erfolgen. Vorher
[Upstream-Dokumentation](https://github.com/QwenLM/qwen-code/tree/v0.25.1/docs)
zu Berechtigungen und Providerwahl lesen. Kein `--yolo`, kein Tool-Allow-All,
keine ungeprueften MCP-/Projekt-Hooks. Ohne Container gibt es **keine Container-
Sandbox**: erlaubte Datei-/Shellaktionen laufen mit deinen Benutzerrechten.

Ollama/OpenAI-kompatibler lokaler Provider ist separat zu konfigurieren.
Keine Modelle, Cloud-Fallbacks oder API-Keys werden vom Installer eingerichtet.
Anmeldedaten nie ins Repo/Buildlog schreiben; Windows-GUI bleibt separat.

## Reparatur und Deaktivierung

```bash
bash scripts/tools/qwen_code_update.sh
bash scripts/tools/qwen_code_install.sh --repair
bash scripts/tools/qwen_code_uninstall.sh
```

Update bedeutet derzeit Rebuild desselben Pins, kein ungepruefter main-Pull.
Abweichende/lokal geaenderte oder unvollstaendige Checkouts zuerst sichern und
pruefen; kein Reset/Loeschen. Deaktivierung verschiebt Code nach
`source.disabled.<Zeit>.<PID>` und entfernt nur den Buildmarker. Keine Prozesse,
`~/.qwen`-Logins, Projekte oder Desktop-/Fremdinstallationen angefasst.

## Testgrenzen

Kein echter pnpm-Build, Login, Modellaufruf oder WSL-Eingriff durch Codex.
Linux-/WSL-Build und native Abhaengigkeiten auf x86_64/ARM bleiben praktisch zu
testen, bevor der Installer als stabil gelten kann.

Primaerquellen: [Manifest](https://github.com/QwenLM/qwen-code/blob/v0.25.1/package.json),
[Build](https://github.com/QwenLM/qwen-code/blob/v0.25.1/scripts/build.js),
[Prepare](https://github.com/QwenLM/qwen-code/blob/v0.25.1/scripts/prepare.js).
