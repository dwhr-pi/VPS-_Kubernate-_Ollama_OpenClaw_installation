# ArchiveBox: GitHub-Paket und private uv-Basis

ArchiveBox dient zum lokalen Archivieren freigegebener Webinhalte. Ein
installiertes Python-Paket ist noch kein eingerichtetes Archiv oder laufender
Webdienst. Bestehende Daten, Container und /opt-Installationen bleiben unberuehrt.

## Fehler vom 25.10.2026: uv fehlt

Das Log um 01:43 zeigt einen Abbruch vor dem Build, nicht Speichermangel.
Der native Installer kann jetzt nach Zustimmung eine private uv-Basis
bereitstellen, wie bereits fuer SearXNG. Kein Docker-Fallback, kein sudo,
keine globale Paketinstallation und kein Austausch des System-Python.

```bash
bash scripts/tools/archivebox_install.sh --dry-run
# Explicit consent for the private uv prerequisite:
bash scripts/tools/archivebox_install.sh --install-build-deps
bash scripts/tools/archivebox_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder fehlende
Zustimmung lehnt ab. Der Dry-Run laedt auch mit Flag nichts herunter.
Status/Doctor aktivieren keinen Bootstrap und sind kein Archivierungsauftrag.

## Python zuerst pruefen

Der [gepruefte Quellpin](https://github.com/ArchiveBox/ArchiveBox/tree/d950dace5ef226634b86ebe43c7001aa7e076cbf)
verlangt gemaess [pyproject.toml](https://github.com/ArchiveBox/ArchiveBox/blob/d950dace5ef226634b86ebe43c7001aa7e076cbf/pyproject.toml)
**Python >=3.13**. Ein vorhandenes Python 3.12 reicht fuer diesen Pin nicht.
Die Versionspruefung erfolgt vor dem privaten uv-Download.
Falls vorhanden, den Interpreter bewusst auswaehlen:

```bash
NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.13 \
  bash scripts/tools/archivebox_install.sh --install-build-deps
```

Das Beispiel installiert Python nicht. `uv` darf hier kein Python nachladen
(`UV_PYTHON_DOWNLOADS=never`); kein automatischer System-Python-Umbau.

## Quellen, Speicher und Lifecycle

- ArchiveBox wird als Python-Paket aus dem lokalen gepinnten GitHub-Checkout gebaut.
- uv **0.13.5** ist eine explizite binaere Buildwerkzeug-Ausnahme aus dem
  [offiziellen GitHub-Release](https://github.com/astral-sh/uv/releases/tag/0.13.5),
  mit festen Groessen und SHA256 fuer Linux amd64/arm64.
- Eine passende vorhandene uv-Version wird bevorzugt. Private Basis unter
  `~/.openclaw_ultimate_user_data/tools/archivebox/toolchain/`; nur Kindprozesse
  erhalten den PATH. Dateien, Hashes und Version werden bei Wiederverwendung geprueft.
- Beim neuen Bootstrap gelten **8448 MiB** Reserve: 8192 MiB Toolreserve plus
  256 MiB Puffer, unter WSL auch fuer den Windows-Host. Schutzgrenzen bleiben erhalten.
- Fehlgeschlagenes Download-/Entpack-Staging wird entfernt; keine fertige uv-
  Markierung vor erfolgreicher Versionspruefung. Vorhandene Daten bleiben erhalten.
- Die fertige private Toolchain bleibt bei spaeterem App-Fehler oder App-
  Deinstallation erhalten. Abhaengigkeiten duerfen aus PyPI kommen; kein Anspruch,
  dass der gesamte Dependency-Graph ausschliesslich aus GitHub gebaut wird.

Browser, Codecs und externe Archivierungsprogramme werden nicht automatisch
eingerichtet. Kein `archivebox init`, `install`, `setup`, Serverstart, Crawl,
Cookieimport oder Accountzugriff. Archivierte Seiten koennen aktiven und
vertraulichen Inhalt enthalten: Rechte, Zugriffsschutz und Retention gesondert planen.

Offline-Fixtures pruefen den Bootstrap-Vertrag. Ein echter Ubuntu-/WSL-Build
und die vollstaendige Archivierungsfunktion wurden hier nicht abgenommen.
Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
