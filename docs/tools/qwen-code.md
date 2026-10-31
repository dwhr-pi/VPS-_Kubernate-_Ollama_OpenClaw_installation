# Qwen Code aus GitHub installieren, ohne Docker

Ergaenzende Anleitung:
[Qwen-AI-Interview und Entwicklungswerkzeuge](../tutorials/qwen-development-tooling.md).
Chat-Aussagen ueber Sandbox-Funktionen sind kein Nachweis lokaler CLI-Faehigkeiten.

Qwen Code ist ein Terminal-Coding-Agent, nicht das Modell selbst und nicht die
[Windows-Desktop-App](qwen-desktop-windows.md). Optional/experimental. Der Installer baut nur
CLI-Code; kein Login, Agent, Modell oder Dienst startet.

## Voraussetzungen

- Linux/WSL als normaler Benutzer, nicht mit `sudo` bauen.
- Git und flock; fuer den Build Node **22.22+ innerhalb 22.x**, npm >=10, Corepack und **pnpm
  11.24.0**. Fehlende Laufzeiten werden bei ausdruecklicher Installation/Repair jetzt **privat**
  bereitgestellt, nicht global ersetzt.
- Planungsreserve: **7168 MiB Gesamt-RAM und 5120 MiB aktuell verfuegbarer RAM**, empfohlen
  mindestens 8 GiB Gesamt-RAM; **10 GiB freier Linux-Speicher**, unter WSL zusaetzlich **10 GiB auf
  Windows C:**. Keine gemessenen Mindestwerte; beide RAM-Werte werden vor Downloads geprueft. Andere
  schwere Jobs vorher beenden. Swap ersetzt diese RAM-Reserve nicht.
- Native Pakete koennen Python 3, make und einen C/C++-Compiler benoetigen.

Andere Tools koennen andere pnpm-Versionen verlangen. Versionen pro Projekt verwalten, nicht wahllos
global ersetzen. Keine automatische Profilinstallation.

## Automatische private Laufzeiten

### Abbruch bei 7769 statt 8192 MB

Die alte Meldung meinte Gesamt-RAM (`MemTotal`), nicht freien RAM. Ein 8-GB-System bzw. eine VM kann
weniger als 8192 MiB nutzbar melden. Die starre 8-GiB-Grenze war unsere Planungsreserve, kein
belegtes Upstream-Minimum. Jetzt sind mindestens 7168 MiB gesamt **und** 5120 MiB `MemAvailable`
erforderlich. 7769 MiB gesamt allein beweisen also noch nicht, dass die Installation klappt. Das ist
eine konservative Setup-Regel, kein gemessener Mindestbedarf.

Der
[gepruefte Build](https://github.com/QwenLM/qwen-code/blob/c1a8218f38203e272e6e965778ed6a2795cfeed7/package.json)
setzt 4096 MiB Node-Heap; weitere Prozesse brauchen zusaetzlichen Speicher. pnpm installiert mit
einem parallelen Child-Prozess und maximal vier Netzwerkverbindungen. Das begrenzt nicht saemtliche
Unterprozesse des Builds. Keine automatische Swap-/WSL-Konfigurationsaenderung. Bei
cgroup-/Containerlimits ist `/proc/meminfo` nicht zwingend das tatsaechliche Prozessbudget; der
Installer ist fuer den direkten Linux-/WSL-Aufruf vorgesehen. Build kann weiterhin an Speicherdruck
scheitern; keine Wiederholungsschleife oder automatisches OOM-Retry.

Nach Aktualisierung des Setups die Installation erneut bewusst auswaehlen. Dry-Run zeigt nur die
Regeln und fuehrt keinen Ressourcen-/Build-Test aus.

Erkennbar an `Qwen-Code-Runtime: 2026-10-16-private-node-corepack-bootstrap-ram-budget`. Der
fruehere Abbruch `node fehlt; separat einrichten` wird damit ersetzt. Nach Ressourcenpruefung, Lock
und privatem Buildlog:

1. Passendes Node/npm weiterverwenden oder ueber den vorhandenen GitHub-nvm- Helfer bereitstellen:
   nvm v0.40.8, offizielles Node-22-Binary mit npm und nvm-Checksumpruefung. Patchversion beim
   Download aufgeloest, kein Source-Build.
2. Fehlendes Corepack **0.34.0** per npm in privatem Prefix installieren, mit
   `--global=false --ignore-scripts`. Kein `corepack enable` am System-Node.
3. pnpm **11.24.0 samt SHA-512-Referenz aus dem gepinnten Upstream-Manifest** ausschliesslich im
   privaten Corepack-Cache bereitstellen.

```text
~/.openclaw_ultimate_user_data/tools/qwen_code/runtime/nvm/
~/.openclaw_ultimate_user_data/tools/qwen_code/runtime/corepack/
~/.openclaw_ultimate_user_data/tools/qwen_code/runtime/corepack-cache/
```

Beachtet `OPENCLAW_USER_DATA_DIR`. `COREPACK_HOME` zeigt immer auf diesen Cache; Corepacks
`install --global` aendert **nur dessen private Default-Version**, nicht System-Shims oder die
Corepack-Einstellungen anderer Tools. Kein Umbau von System-Node, `~/.nvm`, globalem pnpm,
Shellprofilen oder Automaton-pnpm 10. Keine andere Anwendung auf pnpm 11 migrieren.
Corepack/Paketmanager kommen aus der offiziellen npm-Registry, der App-Quellcode weiterhin aus
GitHub.

Ressourcen pruefen vor Downloads. Fuer ein frisches nvm kann der gemeinsame Helfer `git`, `curl`,
`ca-certificates`, `tar`, `xz-utils` per apt einrichten und sudo verlangen; kein apt-Node. Native
Compiler/Python bleiben separat. Doctor/Status/Dry-Run laden nichts nach. Die Versionspruefungen
haben `COREPACK_ENABLE_NETWORK=0`; nur die ausdrueckliche Runtime-Vorbereitung darf den privaten
pnpm-Cache fuellen. Deaktivierung behaelt die privaten Laufzeiten.

Automatische Runtime-Downloads deaktivieren:

```bash
QWEN_CODE_AUTO_RUNTIME=0 bash scripts/tools/qwen_code_install.sh
```

Ohne passende Laufzeiten/privaten Cache wird dann abgebrochen. Bei vorhandenen Laufzeiten bleiben
die ausdruecklichen GitHub-/Paketdownloads fuer den Build erlaubt. Ein Bootstrap-Fehler stoppt vor
Clone/Build und neuem Erfolgsmarker.

## Installation

Im aktuellen Setup-Verzeichnis:

```bash
bash scripts/tools/qwen_code_install.sh --dry-run
bash scripts/tools/qwen_code_install.sh
bash scripts/tools/qwen_code_status.sh
bash scripts/tools/qwen_code_doctor.sh
```

Oder **Qwen_Code** im Tool-Menue bewusst auswaehlen. Quelle:
[QwenLM/qwen-code v0.25.1](https://github.com/QwenLM/qwen-code/releases/tag/v0.25.1), Commit
`c1a8218f38203e272e6e965778ed6a2795cfeed7`. Code Apache-2.0; Paket-/Provider-/Modellbedingungen
separat pruefen.

Build im gepinnten Checkout: `pnpm install --frozen-lockfile`, `pnpm run build --cli-only`,
`pnpm run bundle`. Der Installer setzt `BUILD_SANDBOX=0`, `QWEN_SANDBOX=false`,
`QWEN_SKIP_PREPARE=1`, `HUSKY=0`, `COREPACK_ENABLE_NETWORK=0`, `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`
und `PUPPETEER_SKIP_DOWNLOAD=1`; `QWEN_HOME` zeigt auf privates `build-home`. Die Buildphase
erzwingt Corepacks Projekt-Pin und Strict-Modus; `COREPACK_ENABLE_AUTO_PIN=0` verhindert
automatisches Umschreiben des Manifests. Kein `build:all`, `build:sandbox`, `build-and-start`,
Desktop-/Android-Build oder globales `npm install -g`. Kein Docker/Podman.

Paketabhaengigkeiten/native Prebuilds kommen zusaetzlich aus Registries/anderen Hosts.
Lifecycle-Skripte einschliesslich Postinstall/Prepare laufen beim Build; `QWEN_SKIP_PREPARE=1`
vermeidet den sonst doppelten Vollbuild. Kein Supply-Chain-Audit oder OS-Sandbox-Versprechen. Nur
auf vertrauenswuerdigem Laborhost ohne produktive Schluessel bauen.

```text
~/.openclaw_ultimate_user_data/tools/qwen_code/source/
~/.openclaw_ultimate_user_data/tools/qwen_code/source-built
~/.openclaw_ultimate_user_data/install_logs/*_qwen_code_source_*.log
```

Alternativ `OPENCLAW_USER_DATA_DIR`: absoluter symlinkfreier privater Pfad ausserhalb des
Setup-Repos. Origin/Commit/lokale Aenderungen, Build-Lock und Ressourcen werden geprueft. Erfolg
erst nach CLI-Artefakten und `node --check`; das ist noch kein funktionaler Provider-Test. Doctor
startet die CLI nicht.

## Bewusster erster Start

Erst nach dem Build, in einem freigegebenen Testprojekt ohne produktive Secrets:

```bash
# Nur manuell Hilfe ansehen, nicht Teil der Installation:
node "$HOME/.openclaw_ultimate_user_data/tools/qwen_code/source/scripts/cli-entry.js" --help
```

Fuer eine spaetere interaktive Sitzung denselben Befehl ohne `--help` bewusst aufrufen. Dabei
koennen Konfiguration/Login/Providerzugriff erfolgen. Vorher
[Upstream-Dokumentation](https://github.com/QwenLM/qwen-code/tree/v0.25.1/docs) zu Berechtigungen
und Providerwahl lesen. Kein `--yolo`, kein Tool-Allow-All, keine ungeprueften MCP-/Projekt-Hooks.
Ohne Container gibt es **keine Container- Sandbox**: erlaubte Datei-/Shellaktionen laufen mit deinen
Benutzerrechten.

Ollama/OpenAI-kompatibler lokaler Provider ist separat zu konfigurieren. Keine Modelle,
Cloud-Fallbacks oder API-Keys werden vom Installer eingerichtet. Anmeldedaten nie ins Repo/Buildlog
schreiben; Windows-GUI bleibt separat.

## Reparatur und Deaktivierung

```bash
bash scripts/tools/qwen_code_update.sh
bash scripts/tools/qwen_code_install.sh --repair
bash scripts/tools/qwen_code_uninstall.sh
```

Update bedeutet derzeit Rebuild desselben Pins, kein ungepruefter main-Pull. Abweichende/lokal
geaenderte oder unvollstaendige Checkouts zuerst sichern und pruefen; kein Reset/Loeschen.
Deaktivierung verschiebt Code nach `source.disabled.<Zeit>.<PID>` und entfernt nur den Buildmarker.
Keine Prozesse, `~/.qwen`-Logins, Projekte oder Desktop-/Fremdinstallationen angefasst.

## Testgrenzen

15 Offline-Pruefungen fuer Bootstrap, Abbrueche, Dry-Run, Registry und Doku bestanden;
Node/nvm/Corepack werden dabei simuliert, kein echter Download.

Kein echter pnpm-Build, Login, Modellaufruf oder WSL-Eingriff durch Codex. Linux-/WSL-Build und
native Abhaengigkeiten auf x86_64/ARM bleiben praktisch zu testen, bevor der Installer als stabil
gelten kann.

Primaerquellen: [Manifest](https://github.com/QwenLM/qwen-code/blob/v0.25.1/package.json),
[Build](https://github.com/QwenLM/qwen-code/blob/v0.25.1/scripts/build.js),
[Prepare](https://github.com/QwenLM/qwen-code/blob/v0.25.1/scripts/prepare.js). Corepack:
[Manifest 0.34.0](https://github.com/nodejs/corepack/blob/v0.34.0/package.json) und
[private Cache-/Netzwerk-Einstellungen](https://github.com/nodejs/corepack/blob/v0.34.0/README.md#environment-variables).
