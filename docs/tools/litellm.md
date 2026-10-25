# LiteLLM: GitHub-Paket mit privatem uv-Bootstrap

LiteLLM bietet SDK-/Proxy-Schnittstellen fuer lokale oder externe Modelle.
Ein lokaler Proxy macht einen externen Modellanbieter nicht lokal und erzeugt
keine kostenlosen API-Kontingente. Providerfreigaben und Budgets bleiben getrennt.

## Fehler vom 25.10.2026: uv fehlt

Das Log um 02:22 zeigt fehlendes uv vor dem Build, keinen Speichermangel.
Der Installer kann jetzt nach Zustimmung eine private uv-Basis aus einem
geprueften offiziellen GitHub-Release bereitstellen, ohne Docker-Fallback.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/litellm_install.sh --dry-run
# Explicit consent for the private uv prerequisite:
bash scripts/tools/litellm_install.sh --install-build-deps
bash scripts/tools/litellm_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder fehlende
Zustimmung lehnt ab. Dry-Run bleibt auch mit Flag schreibfrei. Status-/Build-
Aktivierung laedt keine fehlende Toolchain still herunter.

## Python, Quellen und Installationsumfang

### Fehler um 21:56: linker cc not found

Der Rust-/maturin-Schritt wurde gestartet, aber ein C-Compiler/Linker namens
`cc` fehlte. Das Log zeigt keinen Speicherplatzfehler. Der neue native Buildordner
wurde laut Log zurueckgerollt; private Toolchains und bestehende Daten bleiben.
Python 3.12 war in diesem Versuch vorhanden und ist nicht die Fehlerursache.

Die Vorpruefung verlangt jetzt fuer LiteLLM auch **cargo, rustc, cc, c++, make
und pkg-config**, bevor weitere Quellen/Pakete geladen werden. Rust muss als
vorhandene passende Toolchain bereitstehen; es wird nicht durch ein moeglicherweise
zu altes apt-Rust ersetzt. Der Source-Build kann weitere versionsabhaengige
Anforderungen melden; diese Anwesenheitspruefung ist keine Buildgarantie.

Auf Ubuntu 24.04 kann das Setup nach Zustimmung fehlende **build-essential**
und **pkg-config** via apt bereitstellen. `build-essential` liefert die C/C++-
Compiler-/Linkerbasis samt Abhaengigkeiten. Nur diese Basiswerkzeuge kommen
aus apt, nicht LiteLLM. Kein Docker, kein Proxy-Start, kein System-Python-Umbau.
Vorhandene funktionierende Compiler werden bevorzugt. Wenn Pakete installiert
sind, aber `cc` nicht im PATH liegt, wird stattdessen eine PATH-/Paketdiagnose
ausgegeben; keine unbegrenzte Neuinstallation.

Nach Uebernahme der korrigierten Setup-Dateien:

```bash
bash scripts/tools/litellm_install.sh --install-build-deps
```

Die Freigabe umfasst die benoetigten Buildabhaengigkeiten, gegebenenfalls auch
den bereits vorhandenen privaten uv-Bootstrap. apt kann Paketabhaengigkeiten
aktualisieren; System-Buildwerkzeuge bleiben bei LiteLLM-Deinstallation erhalten.
Ausserhalb Ubuntu 24.04 den Compiler bewusst separat bereitstellen; keine
automatische Distribution-/Compilerumstellung. Read-only Kontrolle:

```bash
command -v cc c++ make pkg-config cargo rustc
```

Der Name `docker_credential` in einem heruntergeladenen Rust-Paket ist fuer
sich **kein Nachweis eines Docker-Aufrufs**. Das gepostete Log zeigt einen
nativen Cargo-/maturin-Build; Containerstart bleibt im Installer gesperrt.

Der [Quellpin](https://github.com/BerriAI/litellm/tree/f2118fc7670ba3fa736d9b8f4deef9077a45a720)
beschreibt LiteLLM 1.108.0. Seine
[pyproject.toml](https://github.com/BerriAI/litellm/blob/f2118fc7670ba3fa736d9b8f4deef9077a45a720/pyproject.toml)
verlangt **Python >=3.10 und <3.15**. Diese Grenzen werden vor einem uv-Download
geprueft. Vorhandenes passendes Python kann gezielt ausgewaehlt werden:

```bash
NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.12 \
  bash scripts/tools/litellm_install.sh --install-build-deps
```

Kein Python-Download oder System-Python-Ersatz. `UV_PYTHON_DOWNLOADS=never`
bleibt gesetzt. Passendes vorhandenes uv wird bevorzugt; andernfalls kommt
uv **0.13.5** aus dem
[offiziellen GitHub-Release](https://github.com/astral-sh/uv/releases/tag/0.13.5),
mit festen Groessen/SHA256 fuer Linux amd64/arm64 und anschliessender Versions-
und Inventarpruefung. Das ist eine binaere Buildwerkzeug-Ausnahme, kein
Source-Build von uv. Nur Kindprozesse erhalten den privaten PATH.

LiteLLM wird aus dem lokalen GitHub-Checkout mit dem vorhandenen `proxy`-Extra
in ein privates venv installiert. Das Extra enthaelt weitere Pakete, auch
Enterprise-/Proxy-Erweiterungen: deren Lizenzen und benoetigte Funktionen
separat pruefen, nicht pauschal mit der Lizenz des Kernprojekts gleichsetzen.
Python-Abhaengigkeiten duerfen aus PyPI stammen.

Der bestehende Paketweg loest Dependency-Bereiche auf und protokolliert sie
in `resolved-requirements.txt`; er ist kein vollstaendig eingefrorener
`uv sync --frozen`-Build. Kein unveraenderlicher Dependency-Graph wird zugesichert.

## Speicher, Daten und Betriebsgrenzen

Bei neuer uv-Einrichtung gelten **8448 MiB** Startreserve: 8192 MiB Toolreserve
plus 256 MiB Puffer. Unter WSL gilt dies auch fuer den Windows-Hostspeicher;
die freie Linux-Kapazitaet allein reicht nicht. Waechter bleiben aktiv.

Private Toolchain:
`~/.openclaw_ultimate_user_data/tools/litellm/toolchain/`.
Fehler entfernen nur neues Bootstrap-Staging; kein fertiger uv-Marker vor
erfolgreicher Pruefung. Eine fertige Basis bleibt bei spaeterem App-Fehler und
App-Deinstallation erhalten. Bestehende Container, Datenbanken, Volumes,
/opt-Installationen und Konfigurationen werden nicht migriert oder geloescht.

Der Installer startet keinen Proxy, keine Datenbank, keine Modellabfrage,
keinen Provider-/Modellkatalogabruf und keinen Cloud-Fallback. Paket-Metadaten-
und Dependency-Pruefungen sind noch kein Nachweis eines funktionierenden Proxys.
Vor spaeterem Start separat abnehmen: interne Bindung, Authentifizierung,
dienstbezogene Secrets, explizit erlaubte Provider, Budgets, Retries,
Healthchecks und redigierte Metriken/Logs. Keinen Master-Key an Browser geben.

Die [Kubernetes-/Monitoring-Baseline](../PRODUCTION_BASELINE.md) und der
[Architekturreview](../ARCHITECTURE_REVIEW_2026-10-25.md) bleiben getrennte
Betriebsplaene. Der native Paketbuild haertet oder startet den aelteren
Compose-Stack nicht automatisch.

Offline-Fixtures pruefen Zustimmung, Reserve, Wiederverwendung und Fehlerpfade.
Kein echter Ubuntu-/WSL-Build oder Live-Proxy-Test wurde hier ausgefuehrt.
Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
