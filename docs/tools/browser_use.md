# Browser Use: private uv-Basis und GitHub-Paket

## Fehler vom 26.10.2026 um 03:42

Das Log zeigt **fehlendes uv im globalen PATH**, nicht Speicherplatzmangel. Die vorhandene
Python-3.11+-Pruefung war erfolgreich. Der neue Runtime-Ordner wurde laut Protokoll entfernt;
Browser Use ist dadurch nicht fertig installiert.

Jetzt wird eine passende globale uv-Version >=0.13.5 bevorzugt. Fehlt sie, kann nach Zustimmung eine
private uv-Basis **0.13.5** mit dem bereits fuer andere Werkzeuge vorhandenen sicheren
Bootstrap-Code bereitgestellt werden.

Nach Uebernahme der aktualisierten Setup-Dateien in Ubuntu/WSL:

```bash
bash scripts/tools/browser_use_install.sh --dry-run
bash scripts/tools/browser_use_install.sh --install-build-deps
bash scripts/tools/browser_use_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal `[j/N]`; Enter/EOF oder fehlende Freigabe erlaubt keinen
Download. Dry-Run bleibt auch mit Flag schreibfrei. Status/Check/Doctor/Uninstall laden nichts nach.
Das neue Installationslog nennt `2026-10-26-browser-use-explicit-local-lock` statt der vorherigen
`2026-10-26-browser-use-private-uv`-Baseline.

## Folgefehler vom 26.10.2026 um 12:31: uv.lock fehlt

Die private uv-Basis wurde erfolgreich geprueft. Der nachfolgende Fehler ist ein Installerfehler,
kein Speicherplatz- oder Python-Fehler: Der
[gepruefte Quellstand](https://github.com/browser-use/browser-use/tree/3df5806a0d097a1546d92c49bcf1b28c9972c3bd)
liefert keine `uv.lock` mit, die bisherige Installation verlangte sie aber mit `--frozen`. Die
[Projektmetadaten am Pin](https://github.com/browser-use/browser-use/blob/3df5806a0d097a1546d92c49bcf1b28c9972c3bd/pyproject.toml)
enthalten auch Versionsbereiche, keinen vollstaendig festgeschriebenen Gesamtbestand.

Der korrigierte Ablauf erzeugt bei fehlendem Lock ausdruecklich lokal
`uv lock --no-python-downloads --python <ausgewaehltes-python>` und prueft, dass eine nichtleere
Lockdatei entstanden ist. Danach folgt weiterhin `uv sync --frozen --no-dev --no-default-groups`.
Ein vorhandener Lock wird nicht neu aufgeloest. Herkunft und SHA256 stehen im aktuellen
Installationslog und in `runtime/browser-use-dependency-lock.json`; Lock und Nachweis werden mit dem
Installationsinventar geprueft. Der Sync darf den Lock nicht veraendern.

**Grenze der Reproduzierbarkeit:** Die erste lokale Aufloesung haengt von den zu diesem Zeitpunkt
verfuegbaren Paketversionen/Metadaten ab. Zwei frische Installationen koennen daher unterschiedliche
Locks erzeugen. Kein vom Upstream gepruefter Gesamt-Lock und keine Bit-fuer-Bit-Reproduzierbarkeit
versprochen. Die [uv-Dokumentation](https://docs.astral.sh/uv/concepts/projects/sync/) erklaert
Locking und Synchronisierung.

Nach Uebernahme dieser Korrektur denselben Installationsaufruf oben erneut verwenden; die bereits
gepruefte private uv-Basis wird wiederverwendet. Kein manuelles Loeschen der Toolchain, kein
Docker-Fallback. Bei Aufloesungs-/Installationsfehlern kein Erfolgsmarker; nur die neue Runtime wird
zurueckgerollt. Ein neues Log pruefen, nicht das alte Protokoll.

## Umfang und Grenzen

- Private Basis unter `tools/browser_use/toolchain/` im externen User-Workspace. Kein globaler
  PATH-Umbau, apt-uv, sudo, Docker oder System-Python-Ersatz.
- Offizieller [GitHub-Release 0.13.5](https://github.com/astral-sh/uv/releases/tag/0.13.5) fuer
  Linux amd64/arm64: feste Groesse/SHA256, Versions- und Inventarpruefung. Geaenderte private Basen
  werden nicht still ueberschrieben.
- Bei neuem uv **4352 MiB** Startreserve: 4096 MiB Toolreserve plus 256 MiB Bootstrap-Puffer; unter
  WSL auch fuer den Windows-Host. 10,5 GiB aus dem Log koennen die Vorpruefung erfuellen,
  garantieren aber keinen Buildabschluss.
- Der Build ruft uv ueber seinen **absoluten ermittelten Pfad** auf, nicht erneut ausschliesslich
  ueber den globalen PATH.
- Vor dem Download wird vorhandenes Python >=3.11 mit SSL geprueft. `BROWSER_RESEARCH_PYTHON_BIN`
  erlaubt eine bewusste Interpreterwahl. Kein Python-Download oder `ensurepip`-Bootstrap
  erforderlich.
- Kein ungeprueftes Sharing mit einer LiteLLM-Toolchain: jede Anwendung behaelt ihren eigenen
  geprueften Slot. Ein vorhandener Browser-Use-Slot wird wieder- verwendet; gemeinsam ist der
  Bootstrap-Code, nicht automatisch jede Installation.

Eine erfolgreiche uv-Basis bleibt bei einem spaeteren App-Fehler und bei der App-Deinstallation
erhalten. Bootstrap-Fehler entfernen nur neues Staging; Paketfehler rollen weiterhin nur die neue
Browser-Use-Runtime zurueck. Bestehende fremde Ordner und Nutzdaten bleiben erhalten; kein falscher
Installiert-Marker.

Browser Use selbst bleibt aus dem gepinnten
[GitHub-Checkout](https://github.com/browser-use/browser-use/tree/3df5806a0d097a1546d92c49bcf1b28c9972c3bd).
Paketinstallation nach dem oben beschriebenen Lock-Schritt mit
`uv sync --frozen --no-dev --no-default-groups`, ohne Python-/Chromium-Download. Abhaengigkeiten
kommen ggf. aus Upstream-Registries; kein Offline-/GitHub-exklusives Netzwerkversprechen. uv ist
eine binaere Buildwerkzeug-Ausnahme, kein Browser-Use-Image oder primaeres PyPI-Paket.

Kein Browser-/Agentenstart, API-Test oder Profil-/Cookie-Import. Browser, leeres Profil,
Toolfreigaben und Modellanbindung anschliessend separat einrichten.
[Gesamtuebersicht](comet-and-browser-research.md).

Offline-Fixtures pruefen Freigabe, Hash-/Reserve-/Fehlerpfade, readonly Plan, Pruefreihenfolge und
absoluten uv-Aufruf. Ein echter Browser-Use-Paketbuild auf dem Zielsystem wurde hier nicht
ausgefuehrt.
