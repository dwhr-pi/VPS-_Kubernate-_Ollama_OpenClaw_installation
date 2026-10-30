# Perplexity SDKs: private Bazel-Buildbasis

## Fehler vom 26.10.2026 um 03:48 und 03:50

Beide Logs stoppen mit **`bazel fehlt`**, nicht wegen Speicherplatzmangel. Ein fertiges Python- oder
Node-SDK wurde in diesen Versuchen nicht erstellt. Nur Bazel nachzureichen waere unvollstaendig: die
geprueften Source-Builds verwenden Node 26 und pnpm 11.17.0; das Python-Wheel wird danach mit uv in
eine private Python-Umgebung installiert. Beide Voraussetzungenketten werden jetzt **vor dem
SDK-Quellcheckout** geprueft und nach Zustimmung privat ergaenzt.

Nach Uebernahme der aktualisierten Setup-Dateien in Ubuntu/WSL:

```bash
bash scripts/tools/perplexity_python_install.sh --dry-run
bash scripts/tools/perplexity_python_install.sh --install-build-deps
bash scripts/tools/perplexity_python_doctor.sh

bash scripts/tools/perplexity_node_install.sh --dry-run
bash scripts/tools/perplexity_node_install.sh --install-build-deps
bash scripts/tools/perplexity_node_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal `[j/N]`. Enter/EOF oder fehlende Zustimmung bedeutet
keinen Download. Plan, Status, Check und Doctor bleiben lesend und laden keine fehlenden Werkzeuge
nach. Logkennung fuer beide SDKs: `2026-10-26-perplexity-sdk-readonly-uninstall`.

## Deinstallationsfehler vom 26.10.2026 um 19:45

`Permission denied: package.json` trat beim Entfernen der Runtime auf. Bazel-Ausgaben koennen
schreibgeschuetzte Dateien und Verzeichnisse enthalten, deren Rechte beim Kopieren erhalten bleiben.
Unter Linux braucht das Loeschen insbesondere Schreib-/Suchrechte auf den Elternverzeichnissen; eine
einzelne Datei auf schreibbar zu setzen reicht nicht. Fremde Eigentuemer oder andere
Dateisystemsperren sind aus dem kurzen Log allein nicht auszuschliessen.

Die korrigierte Bereinigung prueft weiterhin zuerst Pin/Quelle und Inventar. Erst danach erhalten
eigene Verzeichnisse innerhalb von `runtime/` die noetigen Benutzerrechte. Unter Windows werden
eigene Readonly-Dateien behandelt; mehrfach hart verlinkte Readonly-Dateien werden nicht umgestellt.
Keine Verfolgung oder Rechteaenderung von Symlink-/Junction-Zielen, keine Spezialdateien oder
fremden Eigentuemer, kein sudo, chown oder chmod 777. Toolchains, Logs, Konfiguration und Daten
ausserhalb der Runtime bleiben bestehen. Der Installationsnachweis wird erst nach erfolgreichem
Entfernen geloescht.

Nach Uebernahme der korrigierten Setup-Dateien kann die normale Deinstallation erneut erfolgen. Hat
der alte Versuch bereits Dateien entfernt, ist der vollstaendige Inventarcheck nicht mehr
erfuellbar. Dann ausdruecklich fortsetzen:

```bash
bash scripts/tools/perplexity_node_uninstall.sh --resume-uninstall --dry-run
bash scripts/tools/perplexity_node_uninstall.sh --resume-uninstall
# Entsprechend nur bei Bedarf fuer das andere SDK:
bash scripts/tools/perplexity_python_uninstall.sh --resume-uninstall
```

Dry-Run zeigt nur den Plan; die eigentliche Restbestandspruefung erfolgt beim echten Aufruf. Der
Fortsetzungsmodus verlangt den vorhandenen Nachweis fuer genau Repo/Pin/Modus und erlaubt
ausschliesslich eine unveraenderte Teilmenge seines gespeicherten Datei-/Linkinventars. Neue oder
geaenderte Dateien, fehlender/fremder Nachweis: Abbruch ohne Entfernen. Fehlende Git-Dateien nach
einer Teildeinstallation werden nicht neu geladen. Kein pauschales Loeschen eines Ordners ohne
Besitz-/Inhaltsnachweis.

Dieser Modus funktioniert auch direkt per CLI, falls das Menue die beschaedigte Runtime nicht mehr
als installiert erkennt. Kein manuelles Loeschen des Markers oder der privaten Buildwerkzeuge. Die
vorige Kennung war `2026-10-26-perplexity-sdk-external-bazel-cache`.

## Folgefehler am 26.10.2026: Bazel-Cache im Quellverzeichnis

Die Protokolle ab 12:49 (Python) bzw. 16:46 (Node) bestaetigen, dass pnpm 11.17.0 jetzt startet;
beim Node-SDK war auch `pnpm install` erfolgreich. Beide Builds scheiterten danach mit Exit 2: Der
aus `runtime/.bazel` abgeleitete Repository-Contents-Cache lag im Haupt-Workspace. Die OpenJDK-
Warnung davor ist nicht der im Protokoll genannte Abbruchgrund.

Jetzt liegen `--output_user_root` und der explizit gesetzte `--repo_contents_cache` unter einem
neuen temporaeren Geschwisterverzeichnis `tools/<sdk>/sdk-bazel-<zufall>/`, **ausserhalb von
runtime/**. Das folgt der [Bazel-Output-Struktur](https://bazel.build/remote/output-directories).
Beide SDK-Ziele nutzen denselben korrigierten Helper, weiterhin mit `--batch` und `--jobs=2`. Kein
globaler Cache-/Bazel-Reset und keine Aenderung am SDK-Pin.

Wheel bzw. Node-Paket werden vor der temporaeren Bereinigung in die eigene Runtime kopiert.
Bazel-Verweise duerfen nur in die eigene Runtime oder den Output dieses Versuchs zeigen; externe
Artefakte werden nicht kopiert. Nur Convenience-Symlinks in genau diesen temporaeren Output werden
entfernt. Bei regulaerem Erfolg/Fehler wird der neue Output bereinigt, vorhandene Toolchains und
fremde Daten bleiben unberuehrt. Ein harter WSL-/Systemabbruch kann wie bei anderen temporaeren
Builds Rueckstaende hinterlassen; keine automatische Loeschung fremder/verwaister Verzeichnisse
hinzugefuegt.

Nach Uebernahme der Korrektur den jeweiligen Installationsaufruf oben erneut ausfuehren. Kein
manuelles Loeschen der geprueften Bazel-/Node-/pnpm-/uv-Slots. Die vorherige Kennung
`2026-10-26-perplexity-sdk-pnpm-bundle` enthaelt noch den Cachefehler. Die Python-Gesamtdauer im Log
ist kein Beleg fuer vier Stunden Bazel-Kompilation: Sie umfasst den gesamten Installationsversuch
samt Eingaben.

## Folgefehler vom 26.10.2026 um 12:37: pnpm.mjs fehlt

Bazel und Node wurden erfolgreich geprueft. Der Installer kopierte aus dem pnpm-Archiv jedoch nur
die Datei `pnpm`, nicht deren benachbarten `dist/`-Baum. Die Startdatei benoetigt `dist/pnpm.mjs`;
das ist kein fehlendes SDK-Modul und kein Anlass fuer ein globales npm/pnpm-Installieren.

Das offizielle [pnpm-Release v11.17.0](https://github.com/pnpm/pnpm/releases/tag/v11.17.0) wird
jetzt als **vollstaendiges Bundle** uebernommen: Startdatei, `dist/`, gebuendelte Abhaengigkeiten
und native Helfer. Vor dem Versionsaufruf werden Startdatei, `dist/pnpm.mjs` und `dist/worker.js`
auf Vorhandensein geprueft. Alle uebernommenen Dateien gehoeren anschliessend zur
Hash-/Inventarpruefung, auch beim Wiederverwenden. Keine Aenderung an Versionen oder
Download-SHA256.

Zur Diagnose wurde das echte amd64-Release-Archiv heruntergeladen, gegen die bereits hinterlegte
SHA256 geprueft und nur seine Dateiliste gelesen. Kein pnpm-/SDK-Code daraus ausgefuehrt;
temporaeres Diagnosearchiv entfernt. Die eingebettete Node-Version einer pnpm-Distribution kann von
der separat fuer den SDK-Build bereitgestellten Node-Version abweichen.

Nach Uebernahme der korrigierten Setup-Dateien denselben Installationsaufruf oben wiederholen.
Bereits gepruefte Bazel-/Node-Slots bleiben erhalten und werden erneut validiert. Das
fehlgeschlagene pnpm-Staging wurde verworfen; kein manuelles Loeschen der funktionierenden
Toolchains erforderlich. Ein bereits vorhandener beschaedigter Slot wird weiterhin nicht automatisch
ueberschrieben. Die vorherige Logkennung war `2026-10-26-perplexity-sdk-private-bazel`.

## Gepruefte Versionen und Quellen

| Buildwerkzeug   | Auswahl / Quelle                                                                                                                                              |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bazel           | **9.2.0**, direkter offizieller [GitHub-Release](https://github.com/bazelbuild/bazel/releases/tag/9.2.0), mit eingebettetem JDK, kein globales Java notwendig |
| Node            | Vorhandenes Node **26.x** oder privat **26.12.1** aus dem [offiziellen Node-Archiv](https://nodejs.org/dist/v26.12.1/)                                        |
| pnpm            | Vorhandenes **11.17.0** oder entsprechender offizieller [GitHub-Release](https://github.com/pnpm/pnpm/releases/tag/v11.17.0)                                  |
| uv (Python-SDK) | Passende vorhandene Version >=0.13.5 oder privat **0.13.5** aus dem offiziellen GitHub-Release                                                                |
| Python          | Vorhandenes Python >=3.10 mit SSL, optional bewusst ueber `BROWSER_RESEARCH_PYTHON_BIN` gewaehlt                                                              |

Diese Versionen sind feste Buildvertraege, kein automatisches `latest`. Quellen fuer SDK-Vertraege:
[Python CONTRIBUTING](https://github.com/perplexityai/perplexity-py/blob/1a79c5d3a7b1ef8c2dce17c0f0aa7e23f9bbdced/CONTRIBUTING.md),
[Node CONTRIBUTING](https://github.com/perplexityai/perplexity-node/blob/40a16d2dad4a7e54fdbfb19eb296b10ab1f29721/CONTRIBUTING.md)
und die `.bazelversion`-/`package.json`-/`BUILD.bazel`-Dateien derselben Pins.

Die SDKs selbst kommen weiter aus ihren gepinnten GitHub-Checkouts, nicht von Docker oder durch
Austausch gegen die primaeren PyPI-/npm-SDK-Pakete. **Buildwerkzeug-Ausnahmen:** Bazel/pnpm/uv sind
gepruefte fertige Binaerwerkzeuge, Node kommt von nodejs.org. Alle neu geladenen
Archive/Binaerdateien haben feste Bytegroessen und SHA256 aus offiziellen Asset-Digests bzw.
Node-SHASUMS. Quellen fuer diese Werte stehen im `perplexity_sdk_tools.py`-Manifest.

Der Helper verwendet bewusst nur seinen **direkten, hashgeprueften Bazel-Bestand**. Ein globaler
`bazel`-Aufruf koennte Bazelisk sein und schon bei `--version` eigenstaendig herunterladen. Deshalb
wird globales Bazel/Bazelisk nicht blind aufgerufen oder fuer den privaten Build vorausgesetzt. Eine
vorhandene eigene gepruefte private Basis wird dagegen wiederverwendet.

## Isolation und Speicher

Unterstuetzt: Linux/WSL **amd64 und arm64**, kein nativer Windows-Crossbuild. Private Slots liegen
je SDK unter `tools/perplexity_python/toolchain/` bzw. `tools/perplexity_node/toolchain/` im
externen User-Workspace. Kein globaler PATH-/Node-/Java-/npm-Umbau, keine Shellprofil-Aenderung,
kein sudo/Docker. Keine ungepruefte Uebernahme privater Toolchains anderer Anwendungen.

Neue Basis erfordert **9472 MiB** Startreserve: 8192 MiB fuer den SDK-Build plus 1280 MiB Puffer
fuer Binaerdateien/Entpacken und moegliches uv. Unter WSL gilt dies auch fuer C:, sofern es der
gepruefte Hostdatentraeger ist. Die gemeldeten 10,5 GiB koennen diese Pruefung erfuellen; es bleibt
wenig Reserve und keine Garantie fuer Bazel-Caches und alle transitiven Abhaengigkeiten.
Speicherwache nicht deaktivieren, gleichzeitige grosse Builds vermeiden.

Python wird vor neuen Downloads geprueft. Neue Komponenten werden erst nach
Groessen-/Hash-/Versionspruefung in ihren finalen Slot uebernommen. Beschaedigte Slots werden nicht
still ueberschrieben. Fehler bereinigen nur neues Staging; schon erfolgreich gepruefte
Einzelwerkzeuge bleiben fuer den naechsten Versuch. Auch bei App-Deinstallation bleiben diese
privaten Buildbasen erhalten.

Node/pnpm erhalten die private Kindprozess-PATH-Reihenfolge sowie getrennte leere
npm-Konfigurationsdateien. Keine persoenliche `.npmrc`, API- oder Cargo- Registry-Zugangsdaten.
Fehlendes `libatomic.so.1` kann unter Ubuntu 24.04 eine weitere gezielte Freigabe fuer `libatomic1`
benoetigen; bewusst separat ueber `PERPLEXITY_SDK_INSTALL_RUNTIME_LIBS=1` mit Install-Flag moeglich,
sonst Nachfrage. Die gemeinsame Bibliothek bleibt bei Tool-Deinstallation erhalten.

## Build und Abnahmestand

Die Buildprogramme werden ueber ermittelte Pfade aufgerufen, nicht trotz privater Einrichtung erneut
ausschliesslich global gesucht. Bazel laeuft mit `--batch` ohne dauerhaft verbleibenden
Bazel-Server, getrenntem temporaerem Output-Root und `--jobs=2`. Ziele bleiben `//:wheel` bzw.
`//:pkg`, **keine Live-API-Tests**. Schwere Bazel-/pnpm-/uv-Install-Schritte liefern laufende
Ausgabe und PID- Heartbeat. Bazel-Builds haben vier Stunden, die Paket-Install-Schritte zwei Stunden
Limit pro Aufruf; Abbruch beendet unter Linux die eigene Prozessgruppe. Ein Heartbeat belegt nur
einen lebenden Prozess, keinen tatsaechlichen Fortschritt. Der Node-SDK-Build verwendet einen frozen
pnpm-Lock und keine Lifecycle-Hooks im vorgeschalteten pnpm-Install. Das Python-SDK-Wheel wird mit
privatem uv installiert; seine Runtime-Dependency-Bereiche sind kein vollstaendiger Hash-Lock.

Bazel kann fuer seine deklarierte Buildgraph-Ausfuehrung weitere hermetische Runtimes und
Abhaengigkeiten laden, auch Python/Node/Java. Das ist vom erlaubten SDK-Build umfasst;
`UV_PYTHON_DOWNLOADS=never` ist **keine** globale Bazel-Sperre. Keine Offline-/GitHub-exklusive
Netzwerkzusage. Es werden weder Modelle noch ein MCP-Server oder Proxy gestartet, keine API-Keys
abgefragt und keine kostenpflichtigen Suchanfragen ausgefuehrt.

Offline-Fixtures pruefen Freigabe, Hash-/Versionsgrenzen, gebuendelte Vorbereitung, private
npm-Konfigurationen, Wiederverwendung, Cachegrenzen, Artefaktuebernahme und temporaere
Bereinigung/Rollback. Vollstaendige Ubuntu-/WSL-SDK-Builds sowie die echte API-Funktion wurden hier
nicht ausgefuehrt. Bei der Cache-Korrektur wurden drei echte Symlink-Fixtures unter Windows mangels
Symlink-Rechten uebersprungen; die plattformunabhaengigen Fixtures pruefen Cache-Lage ausserhalb des
Workspaces und temporaere Bereinigung. Das ist keine pauschale Produktionsfreigabe.

[Perplexity MCP (separat)](perplexity_mcp.md) und
[Browser-/Perplexity-Uebersicht](comet-and-browser-research.md).
