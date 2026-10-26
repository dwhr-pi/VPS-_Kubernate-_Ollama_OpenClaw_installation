# Perplexity SDKs: private Bazel-Buildbasis

## Fehler vom 26.10.2026 um 03:48 und 03:50

Beide Logs stoppen mit **`bazel fehlt`**, nicht wegen Speicherplatzmangel. Ein
fertiges Python- oder Node-SDK wurde in diesen Versuchen nicht erstellt.
Nur Bazel nachzureichen waere unvollstaendig: die geprueften Source-Builds
verwenden Node 26 und pnpm 11.17.0; das Python-Wheel wird danach mit uv in eine
private Python-Umgebung installiert. Beide Voraussetzungenketten werden jetzt
**vor dem SDK-Quellcheckout** geprueft und nach Zustimmung privat ergaenzt.

Nach Uebernahme der aktualisierten Setup-Dateien in Ubuntu/WSL:

```bash
bash scripts/tools/perplexity_python_install.sh --dry-run
bash scripts/tools/perplexity_python_install.sh --install-build-deps
bash scripts/tools/perplexity_python_doctor.sh

bash scripts/tools/perplexity_node_install.sh --dry-run
bash scripts/tools/perplexity_node_install.sh --install-build-deps
bash scripts/tools/perplexity_node_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal `[j/N]`. Enter/EOF oder fehlende
Zustimmung bedeutet keinen Download. Plan, Status, Check und Doctor bleiben
lesend und laden keine fehlenden Werkzeuge nach. Logkennung fuer beide SDKs:
`2026-10-26-perplexity-sdk-private-bazel`.

## Gepruefte Versionen und Quellen

| Buildwerkzeug | Auswahl / Quelle |
|---|---|
| Bazel | **9.2.0**, direkter offizieller [GitHub-Release](https://github.com/bazelbuild/bazel/releases/tag/9.2.0), mit eingebettetem JDK, kein globales Java notwendig |
| Node | Vorhandenes Node **26.x** oder privat **26.12.1** aus dem [offiziellen Node-Archiv](https://nodejs.org/dist/v26.12.1/) |
| pnpm | Vorhandenes **11.17.0** oder entsprechender offizieller [GitHub-Release](https://github.com/pnpm/pnpm/releases/tag/v11.17.0) |
| uv (Python-SDK) | Passende vorhandene Version >=0.13.5 oder privat **0.13.5** aus dem offiziellen GitHub-Release |
| Python | Vorhandenes Python >=3.10 mit SSL, optional bewusst ueber `BROWSER_RESEARCH_PYTHON_BIN` gewaehlt |

Diese Versionen sind feste Buildvertraege, kein automatisches `latest`.
Quellen fuer SDK-Vertraege:
[Python CONTRIBUTING](https://github.com/perplexityai/perplexity-py/blob/1a79c5d3a7b1ef8c2dce17c0f0aa7e23f9bbdced/CONTRIBUTING.md),
[Node CONTRIBUTING](https://github.com/perplexityai/perplexity-node/blob/40a16d2dad4a7e54fdbfb19eb296b10ab1f29721/CONTRIBUTING.md)
und die `.bazelversion`-/`package.json`-/`BUILD.bazel`-Dateien derselben Pins.

Die SDKs selbst kommen weiter aus ihren gepinnten GitHub-Checkouts, nicht von
Docker oder durch Austausch gegen die primaeren PyPI-/npm-SDK-Pakete.
**Buildwerkzeug-Ausnahmen:** Bazel/pnpm/uv sind gepruefte fertige Binaerwerkzeuge,
Node kommt von nodejs.org. Alle neu geladenen Archive/Binaerdateien haben feste
Bytegroessen und SHA256 aus offiziellen Asset-Digests bzw. Node-SHASUMS.
Quellen fuer diese Werte stehen im `perplexity_sdk_tools.py`-Manifest.

Der Helper verwendet bewusst nur seinen **direkten, hashgeprueften Bazel-Bestand**.
Ein globaler `bazel`-Aufruf koennte Bazelisk sein und schon bei `--version`
eigenstaendig herunterladen. Deshalb wird globales Bazel/Bazelisk nicht blind
aufgerufen oder fuer den privaten Build vorausgesetzt. Eine vorhandene eigene
gepruefte private Basis wird dagegen wiederverwendet.

## Isolation und Speicher

Unterstuetzt: Linux/WSL **amd64 und arm64**, kein nativer Windows-Crossbuild.
Private Slots liegen je SDK unter `tools/perplexity_python/toolchain/` bzw.
`tools/perplexity_node/toolchain/` im externen User-Workspace. Kein globaler
PATH-/Node-/Java-/npm-Umbau, keine Shellprofil-Aenderung, kein sudo/Docker.
Keine ungepruefte Uebernahme privater Toolchains anderer Anwendungen.

Neue Basis erfordert **9472 MiB** Startreserve: 8192 MiB fuer den SDK-Build plus
1280 MiB Puffer fuer Binaerdateien/Entpacken und moegliches uv. Unter WSL gilt
dies auch fuer C:, sofern es der gepruefte Hostdatentraeger ist. Die gemeldeten
10,5 GiB koennen diese Pruefung erfuellen; es bleibt wenig Reserve und keine
Garantie fuer Bazel-Caches und alle transitiven Abhaengigkeiten. Speicherwache
nicht deaktivieren, gleichzeitige grosse Builds vermeiden.

Python wird vor neuen Downloads geprueft. Neue Komponenten werden erst nach
Groessen-/Hash-/Versionspruefung in ihren finalen Slot uebernommen. Beschaedigte
Slots werden nicht still ueberschrieben. Fehler bereinigen nur neues Staging;
schon erfolgreich gepruefte Einzelwerkzeuge bleiben fuer den naechsten Versuch.
Auch bei App-Deinstallation bleiben diese privaten Buildbasen erhalten.

Node/pnpm erhalten die private Kindprozess-PATH-Reihenfolge sowie getrennte
leere npm-Konfigurationsdateien. Keine persoenliche `.npmrc`, API- oder Cargo-
Registry-Zugangsdaten. Fehlendes `libatomic.so.1` kann unter Ubuntu 24.04 eine
weitere gezielte Freigabe fuer `libatomic1` benoetigen; bewusst separat ueber
`PERPLEXITY_SDK_INSTALL_RUNTIME_LIBS=1` mit Install-Flag moeglich, sonst Nachfrage.
Die gemeinsame Bibliothek bleibt bei Tool-Deinstallation erhalten.

## Build und Abnahmestand

Die Buildprogramme werden ueber ermittelte Pfade aufgerufen, nicht trotz
privater Einrichtung erneut ausschliesslich global gesucht. Bazel laeuft
mit `--batch` ohne dauerhaft verbleibenden Bazel-Server, lokalem Output-Root
und `--jobs=2`. Ziele bleiben `//:wheel` bzw. `//:pkg`, **keine Live-API-Tests**.
Schwere Bazel-/pnpm-/uv-Install-Schritte liefern laufende Ausgabe und PID-
Heartbeat. Bazel-Builds haben vier Stunden, die Paket-Install-Schritte zwei
Stunden Limit pro Aufruf; Abbruch beendet unter Linux die eigene Prozessgruppe.
Ein Heartbeat belegt nur einen lebenden Prozess, keinen tatsaechlichen Fortschritt.
Der Node-SDK-Build verwendet einen frozen pnpm-Lock und keine Lifecycle-Hooks
im vorgeschalteten pnpm-Install. Das Python-SDK-Wheel wird mit privatem uv
installiert; seine Runtime-Dependency-Bereiche sind kein vollstaendiger Hash-Lock.

Bazel kann fuer seine deklarierte Buildgraph-Ausfuehrung weitere hermetische
Runtimes und Abhaengigkeiten laden, auch Python/Node/Java. Das ist vom erlaubten
SDK-Build umfasst; `UV_PYTHON_DOWNLOADS=never` ist **keine** globale Bazel-Sperre.
Keine Offline-/GitHub-exklusive Netzwerkzusage. Es werden weder Modelle noch
ein MCP-Server oder Proxy gestartet, keine API-Keys abgefragt und keine
kostenpflichtigen Suchanfragen ausgefuehrt.

Offline-Fixtures pruefen Freigabe, Hash-/Versionsgrenzen, gebuendelte Vorbereitung,
private npm-Konfigurationen, Wiederverwendung und Rollback. Vollstaendige
Ubuntu-/WSL-SDK-Builds sowie die echte API-Funktion wurden hier nicht ausgefuehrt.
Das ist keine pauschale Produktionsfreigabe.

[Perplexity MCP (separat)](perplexity_mcp.md) und
[Browser-/Perplexity-Uebersicht](comet-and-browser-research.md).
