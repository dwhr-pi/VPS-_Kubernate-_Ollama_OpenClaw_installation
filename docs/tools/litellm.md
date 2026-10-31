# LiteLLM: GitHub-Paket mit privater Buildbasis

LiteLLM bietet SDK-/Proxy-Schnittstellen fuer lokale oder externe Modelle. Ein lokaler Proxy macht
einen externen Modellanbieter nicht lokal und erzeugt keine kostenlosen API-Kontingente.
Providerfreigaben und Budgets bleiben getrennt.

## Fehler vom 26.10.2026 um 00:42: Paketinstallation nach 7200 Sekunden abgebrochen

Dieses Protokoll zeigt nun funktionierendes **Rust/Cargo 1.98.0, uv 0.13.5, Python 3.12.3 und
installierte C/C++-Compilerbasis**. Der Abbruch erfolgt bei `uv pip install ... source[proxy]` nach
zwei Stunden. Es ist weder ein Nachweis fuer erneutes Rust-Fehlen noch fuer OOM/Speicherplatzmangel.
Ob ein langsamer Source-Build, Dependency-Aufloesung oder Netzwerkproblem ursachlich war, laesst
sich aus der bisher gepufferten, im Timeoutfall fehlenden uv-Ausgabe nicht bestimmen.

Die korrigierte LiteLLM-Paketinstallation:

- uebertraegt stdout/stderr mit `--verbose` laufend in das aktuelle Operationslog;
- zeigt PID, Laufzeit und Restbudget alle 30 Sekunden. Ein lebender Prozess ist **kein** Beleg fuer
  Fortschritt oder einen erfolgreichen Build;
- begrenzt Cargo- und parallele uv-Source-Builds jeweils auf 1, Downloads auf 4;
- setzt uv-Verbindungs-/Lesetimeouts auf 20/60 Sekunden und HTTP-Retries auf 2. Cargo erhaelt
  ebenfalls HTTP-Timeout 60 Sekunden und Retry-Limit 2;
- beendet bei Abbruch unter Linux die eigene Build-Prozessgruppe einschliesslich darin verbliebener
  Kindprozesse, bevor der bestehende Rollback greift;
- puffert Metadaten/`uv pip freeze` weiterhin vollstaendig, damit die Liste
  `resolved-requirements.txt` nicht durch den begrenzten Streaming-Rueckgabepuffer abgeschnitten
  wird. Kein automatischer Wiederholungsversuch nach einem Timeout.

Die Einstellungen orientieren sich an der
[offiziellen uv-Referenz](https://docs.astral.sh/uv/reference/environment/). Die
Parallelitaetsbegrenzung reduziert Last, kann den Build aber verlaengern; sie ist kein hartes
RAM-Limit. Ein langsamer Build wird dadurch nicht garantiert schneller. Das Gesamtlimit bleibt
standardmaessig **7200 Sekunden pro uv-Install**.

Nach Uebernahme der korrigierten Dateien erneut starten. Wenn bewusst bis zu vier Stunden fuer den
jeweiligen Installationsprozess erlaubt werden sollen:

```bash
LITELLM_BUILD_TIMEOUT_SECONDS=14400 \
  bash scripts/tools/litellm_install.sh --install-build-deps
```

Erlaubt sind ganze Sekunden von **300 bis 21600** (maximal sechs Stunden); ungueltige Werte brechen
vor neuen Downloads/apt-Aktionen ab. Die Variable gilt nur fuer LiteLLMs gestreamte
`uv pip install`-Schritte, nicht fuer alle Installer oder Bootstrap-Schritte. Sie erhoeht keine
Netzwerk-Retry-Schleifen. Nicht blind Zeitlimits erhoehen: zuerst die neu sichtbaren
Download-/Resolver-/Compilerzeilen im aktuellen Log pruefen. Kein Timeout wird als Erfolg
umgedeutet.

Die bereits erfolgreich bereitgestellten privaten Rust-/uv-Basen bleiben erhalten und werden
wiederverwendet. Der vorherige neue native Buildordner wurde laut Log zurueckgerollt; abgebrochene
Source-Builds werden **nicht** automatisch fortgesetzt. Vor einem erneuten Versuch auf Prozesse aus
dem alten, nicht prozessgruppenfaehigen Installer pruefen, ohne sie pauschal zu beenden:

```bash
ps -u "$USER" -o pid,ppid,etime,comm
```

Ein alter Cargo-/rustc-Prozess ist moeglich, aber aus dem Log nicht bewiesen. Bei unklarer
Installationssperre die lesende Installations-Reset-Diagnose des Setups verwenden; keine
WSL-Neuinstallation und kein blindes Loeschen von Locks. Logs koennen Pfade/Download-Metadaten
enthalten: vor Weitergabe lokal pruefen. Die Korrektur ist mit kleinen lokalen Kindprozessen und
Build-Fixtures getestet, nicht durch einen echten mehrstuendigen LiteLLM-Source-Build.

## Fehler vom 26.10.2026: Rust 1.98.0 fehlt

Das Log um 00:14 meldet **keine passende vorhandene Rust-Toolchain**, nicht Speicherplatzmangel oder
einen fehlgeschlagenen LiteLLM-Paketbuild. Der Toolchain-Pin wurde direkt im unten verlinkten
Upstream-Quellstand bestaetigt. Die fruehere Auswahlfunktion hat bei fehlendem Rust nur abgebrochen.

Jetzt kann der Installer nach Zustimmung eine **isolierte Rust-Basis** einrichten:

```bash
# First copy/update the corrected setup scripts, then run in Ubuntu/WSL:
bash scripts/tools/litellm_install.sh --dry-run
bash scripts/tools/litellm_install.sh --install-build-deps
bash scripts/tools/litellm_doctor.sh
```

Ohne Flag wird interaktiv mit `[j/N]` gefragt; Enter/EOF und nichtinteraktive Ausfuehrung ohne
Freigabe verweigern den Download. `--install-build-deps` erlaubt jetzt ausdruecklich auch diese
Rust-Basis, neben den dokumentierten Compiler-/uv-Abhaengigkeiten. Plan/Status/Doctor laden kein
Rust nach.

Vorhandenes passendes Rust wird weiter bevorzugt; explizite falsche
`NATIVE_SOURCE_RUST_TOOLCHAIN`-Pfade werden niemals still ersetzt. Die neue Basis liegt unter
`tools/litellm/toolchain/rust-1.98.0-linux-<arch>/` im externen User-Workspace. Eigene
`HOME`-/`CARGO_HOME`-/`RUSTUP_HOME`-Verzeichnisse fuer den Bootstrap, `--no-modify-path`, kein sudo,
kein apt-Rust, kein Shellprofil- oder Default-Toolchain-Wechsel. Keine Uebernahme persoenlicher
Cargo-Zugangsdaten.

**Offizielle Buildwerkzeug-Ausnahme:** rustup-init **1.29.2** kommt von
`https://static.rust-lang.org/rustup/archive/1.29.2/`, nicht aus einem LiteLLM- Docker-Image.
Groesse und fest hinterlegte SHA256 werden vor Ausfuehrung fuer Linux amd64/arm64 geprueft; fremde
Redirect-Hosts werden blockiert. Rustup laedt anschliessend die genaue Version **1.98.0**, Profil
`minimal`, ueber den fest gewaehlten offiziellen Rust-Distributionsserver und dessen
Integritaetspruefung. Kein eigener fester SHA-Pin jedes Rust-Komponentenarchivs wird zugesichert.
Quellen: [Rustup-Installation](https://rust-lang.github.io/rustup/installation/index.html),
[Umgebungsvariablen](https://rust-lang.github.io/rustup/environment-variables.html). Die geprueften
rustup-init-Digests stammen aus den offiziellen `.sha256`-Dateien neben den jeweiligen
amd64-/arm64-Binaerdateien; sie stehen im Bootstraphelper.

Rust-/Cargo-Version und sysroot werden nach Installation und nach Verschieben ins endgueltige Ziel
erneut geprueft. Erst danach entsteht `rust-ready.json` mit Dateiinventur. Ein vorhandener
geaenderter/unvollstaendiger privater Bestand wird nicht ueberschrieben. Fehler entfernen nur neues
Staging/diesen neuen fehlgeschlagenen Slot, keine alten Tools oder Daten. Eine erfolgreiche Basis
bleibt bei spaeterem LiteLLM-Fehler und App-Deinstallation erhalten.

Startreserve mit neuem Rust: **10240 MiB** (8192 + 2048 MiB Puffer), auch auf dem Windows-Host unter
WSL. 11,4 GiB aus dem Log koennen diese Vorpruefung erfuellen, sind aber keine Build-Platzgarantie.
Waechter nicht abschalten; weitere Abhaengigkeiten/Caches koennen Platz benoetigen. Kein Dienst oder
Modell gestartet. Offline-Fixtures pruefen Freigabe, Hashfehler, privaten Scope, Wiederverwendung
und Rollback. Ein echter Rust-/LiteLLM-Download und Ubuntu-Build stehen noch aus.

## Fehler vom 25.10.2026: uv fehlt

Das Log um 02:22 zeigt fehlendes uv vor dem Build, keinen Speichermangel. Der Installer kann jetzt
nach Zustimmung eine private uv-Basis aus einem geprueften offiziellen GitHub-Release bereitstellen,
ohne Docker-Fallback.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/litellm_install.sh --dry-run
# Explicit consent for the private uv prerequisite:
bash scripts/tools/litellm_install.sh --install-build-deps
bash scripts/tools/litellm_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder fehlende Zustimmung lehnt ab.
Dry-Run bleibt auch mit Flag schreibfrei. Status-/Build- Aktivierung laedt keine fehlende Toolchain
still herunter.

## Python, Quellen und Installationsumfang

### Fehler um 23:08: cargo fehlt

Dieser Versuch stoppt vor dem Quellen-/Paketbuild. `cargo fehlt` bedeutet zunaechst nur: kein Cargo
im Installer-PATH. Es beweist nicht, dass unter `~/.rustup/toolchains/` keine Toolchain vorhanden
ist. Der fruehere maturin- Versuch ist ebenfalls kein Nachweis einer dauerhaft installierten
Cargo-Basis.

Der Installer erkennt jetzt vorhandene direkte Toolchains unter `$RUSTUP_HOME/toolchains/` (Standard
`~/.rustup/toolchains/`) und prueft Cargo-/Rust-Version sowie sysroot. Explizite Auswahl hat
Vorrang:

```bash
# Example for Ubuntu x86_64; use the actual installed toolchain directory.
NATIVE_SOURCE_RUST_TOOLCHAIN="$HOME/.rustup/toolchains/1.98.0-x86_64-unknown-linux-gnu" \
  bash scripts/tools/litellm_install.sh --install-build-deps
```

Der
[gepruefte rust-toolchain.toml-Pin](https://github.com/BerriAI/litellm/blob/f2118fc7670ba3fa736d9b8f4deef9077a45a720/rust-toolchain.toml)
nennt **1.98.0**. Das Workspace-Minimum 1.88 aus Cargo.toml ist nicht derselbe Vertrag; hier wird
bewusst die Upstream-Toolchain verwendet. Keine ungepruefte Ersetzung durch apt-Rust oder eine
beliebige `stable`-Version.

Falls Rust 1.98.0 wirklich fehlt und **rustup bereits vorhanden ist**, bewusst separat installieren
(Netzwerk und zusaetzlicher Speicherbedarf):

```bash
rustup toolchain install 1.98.0 --profile minimal --no-self-update
```

Fehlt auch rustup, zuerst die
[offizielle Rust-Installationsanleitung](https://www.rust-lang.org/tools/install) lesen und die
Basis separat einrichten, **oder den oben beschriebenen privaten Bootstrap bewusst freigeben**. Ohne
Zustimmung laedt der LiteLLM-Installer weder rustup noch Rust herunter. Ein erfolgreicher
Rust-Download ist noch kein erfolgreicher LiteLLM-Build. Die Verfuegbarkeit des Archivs und der
echte Ubuntu-Build wurden hier nicht getestet.

Bei Verwendung wird nur der Kindprozess-PATH erweitert; Container-/sudo- Guards bleiben davor.
`RUSTUP_TOOLCHAIN` zeigt auf den vorhandenen absoluten sysroot, nicht auf einen aufzuloesenden
Kanal; `RUSTUP_AUTO_INSTALL=0` bleibt gesetzt. Persoenliche Cargo-Registry-Zugangsdaten werden nicht
uebernommen, Build-Caches bleiben privat. Keine Shellprofil- oder Default-Toolchain-Aenderung durch
diesen Auswahlhelper. Vorhandene explizite, falsche Pfade werden nicht still ersetzt. Fuer andere
Tools aendert dieser LiteLLM-spezifische Pfad nichts.

### Fehler um 21:56: linker cc not found

Der Rust-/maturin-Schritt wurde gestartet, aber ein C-Compiler/Linker namens `cc` fehlte. Das Log
zeigt keinen Speicherplatzfehler. Der neue native Buildordner wurde laut Log zurueckgerollt; private
Toolchains und bestehende Daten bleiben. Python 3.12 war in diesem Versuch vorhanden und ist nicht
die Fehlerursache.

Die Vorpruefung verlangt jetzt fuer LiteLLM auch **cargo, rustc, cc, c++, make und pkg-config**,
bevor weitere Quellen/Pakete geladen werden. Rust muss als passende Toolchain bereitstehen oder der
private Bootstrap freigegeben werden; kein Ersatz durch moeglicherweise zu altes apt-Rust. Der
Source-Build kann weitere versionsabhaengige Anforderungen melden; diese Anwesenheitspruefung ist
keine Buildgarantie.

Auf Ubuntu 24.04 kann das Setup nach Zustimmung fehlende **build-essential** und **pkg-config** via
apt bereitstellen. `build-essential` liefert die C/C++- Compiler-/Linkerbasis samt Abhaengigkeiten.
Nur diese Basiswerkzeuge kommen aus apt, nicht LiteLLM. Kein Docker, kein Proxy-Start, kein
System-Python-Umbau. Vorhandene funktionierende Compiler werden bevorzugt. Wenn Pakete installiert
sind, aber `cc` nicht im PATH liegt, wird stattdessen eine PATH-/Paketdiagnose ausgegeben; keine
unbegrenzte Neuinstallation.

Nach Uebernahme der korrigierten Setup-Dateien:

```bash
bash scripts/tools/litellm_install.sh --install-build-deps
```

Die Freigabe umfasst die benoetigten Buildabhaengigkeiten, gegebenenfalls auch den bereits
vorhandenen privaten uv-Bootstrap. apt kann Paketabhaengigkeiten aktualisieren;
System-Buildwerkzeuge bleiben bei LiteLLM-Deinstallation erhalten. Ausserhalb Ubuntu 24.04 den
Compiler bewusst separat bereitstellen; keine automatische Distribution-/Compilerumstellung.
Read-only Kontrolle:

```bash
command -v cc c++ make pkg-config cargo rustc
```

Der Name `docker_credential` in einem heruntergeladenen Rust-Paket ist fuer sich **kein Nachweis
eines Docker-Aufrufs**. Das gepostete Log zeigt einen nativen Cargo-/maturin-Build; Containerstart
bleibt im Installer gesperrt.

Der [Quellpin](https://github.com/BerriAI/litellm/tree/f2118fc7670ba3fa736d9b8f4deef9077a45a720)
beschreibt LiteLLM 1.108.0. Seine
[pyproject.toml](https://github.com/BerriAI/litellm/blob/f2118fc7670ba3fa736d9b8f4deef9077a45a720/pyproject.toml)
verlangt **Python >=3.10 und <3.15**. Diese Grenzen werden vor einem uv-Download geprueft.
Vorhandenes passendes Python kann gezielt ausgewaehlt werden:

```bash
NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.12 \
  bash scripts/tools/litellm_install.sh --install-build-deps
```

Kein Python-Download oder System-Python-Ersatz. `UV_PYTHON_DOWNLOADS=never` bleibt gesetzt.
Passendes vorhandenes uv wird bevorzugt; andernfalls kommt uv **0.13.5** aus dem
[offiziellen GitHub-Release](https://github.com/astral-sh/uv/releases/tag/0.13.5), mit festen
Groessen/SHA256 fuer Linux amd64/arm64 und anschliessender Versions- und Inventarpruefung. Das ist
eine binaere Buildwerkzeug-Ausnahme, kein Source-Build von uv. Nur Kindprozesse erhalten den
privaten PATH.

LiteLLM wird aus dem lokalen GitHub-Checkout mit dem vorhandenen `proxy`-Extra in ein privates venv
installiert. Das Extra enthaelt weitere Pakete, auch Enterprise-/Proxy-Erweiterungen: deren Lizenzen
und benoetigte Funktionen separat pruefen, nicht pauschal mit der Lizenz des Kernprojekts
gleichsetzen. Python-Abhaengigkeiten duerfen aus PyPI stammen.

Der bestehende Paketweg loest Dependency-Bereiche auf und protokolliert sie in
`resolved-requirements.txt`; er ist kein vollstaendig eingefrorener `uv sync --frozen`-Build. Kein
unveraenderlicher Dependency-Graph wird zugesichert.

## Speicher, Daten und Betriebsgrenzen

Bei neuer uv-Einrichtung gelten **8448 MiB** Startreserve: 8192 MiB Toolreserve plus 256 MiB Puffer.
Unter WSL gilt dies auch fuer den Windows-Hostspeicher; die freie Linux-Kapazitaet allein reicht
nicht. Waechter bleiben aktiv.

Private Toolchain: `~/.openclaw_ultimate_user_data/tools/litellm/toolchain/`. Fehler entfernen nur
neues Bootstrap-Staging; kein fertiger uv-Marker vor erfolgreicher Pruefung. Eine fertige Basis
bleibt bei spaeterem App-Fehler und App-Deinstallation erhalten. Bestehende Container, Datenbanken,
Volumes, /opt-Installationen und Konfigurationen werden nicht migriert oder geloescht.

Der Installer startet keinen Proxy, keine Datenbank, keine Modellabfrage, keinen
Provider-/Modellkatalogabruf und keinen Cloud-Fallback. Paket-Metadaten- und Dependency-Pruefungen
sind noch kein Nachweis eines funktionierenden Proxys. Vor spaeterem Start separat abnehmen: interne
Bindung, Authentifizierung, dienstbezogene Secrets, explizit erlaubte Provider, Budgets, Retries,
Healthchecks und redigierte Metriken/Logs. Keinen Master-Key an Browser geben.

Die [Kubernetes-/Monitoring-Baseline](../PRODUCTION_BASELINE.md) und der
[Architekturreview](../ARCHITECTURE_REVIEW_2026-10-25.md) bleiben getrennte Betriebsplaene. Der
native Paketbuild haertet oder startet den aelteren Compose-Stack nicht automatisch.

Offline-Fixtures pruefen Zustimmung, Reserve, Wiederverwendung und Fehlerpfade. Kein echter
Ubuntu-/WSL-Build oder Live-Proxy-Test wurde hier ausgefuehrt. Siehe
[Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
