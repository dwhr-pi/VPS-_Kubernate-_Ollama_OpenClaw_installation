# ArchiveBox: GitHub-Paket mit privatem uv und Python

ArchiveBox dient zum lokalen Archivieren freigegebener Webinhalte. Ein installiertes Python-Paket
ist noch kein eingerichtetes Archiv oder laufender Webdienst. Bestehende Daten, Container und
/opt-Installationen bleiben unberuehrt.

## Fehler vom 25.10.2026: uv fehlt

Das Log um 01:43 zeigt einen Abbruch vor dem Build, nicht Speichermangel. Der native Installer kann
jetzt nach Zustimmung eine private uv-Basis bereitstellen, wie bereits fuer SearXNG. Kein
Docker-Fallback, kein sudo, keine globale Paketinstallation und kein Austausch des System-Python.

```bash
bash scripts/tools/archivebox_install.sh --dry-run
# Explicit consent for the private uv prerequisite:
bash scripts/tools/archivebox_install.sh --install-build-deps
bash scripts/tools/archivebox_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder fehlende Zustimmung lehnt ab. Der
Dry-Run laedt auch mit Flag nichts herunter. Status/Doctor aktivieren keinen Bootstrap und sind kein
Archivierungsauftrag.

## Python zuerst pruefen

Der
[gepruefte Quellpin](https://github.com/ArchiveBox/ArchiveBox/tree/d950dace5ef226634b86ebe43c7001aa7e076cbf)
verlangt gemaess
[pyproject.toml](https://github.com/ArchiveBox/ArchiveBox/blob/d950dace5ef226634b86ebe43c7001aa7e076cbf/pyproject.toml)
**Python >=3.13**. Ein vorhandenes Python 3.12 reicht fuer diesen Pin nicht. Das Log um **04:10**
scheitert genau daran: `/usr/bin/python3` liegt unter der verlangten Version. Das ist kein
Speicherplatzfehler. Der Installer sucht jetzt zuerst nach `python3.13`, danach `python3.14` und
prueft anschliessend seinen eigenen Interpreter. SSL und venv muessen ebenfalls importierbar sein.
Falls vorhanden, den Interpreter bewusst auswaehlen:

```bash
NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.13 \
  bash scripts/tools/archivebox_install.sh --install-build-deps
```

Das Beispiel installiert Python nicht. Ein explizites, unpassendes `NATIVE_SOURCE_PYTHON_BIN` fuehrt
zu einer verstaendlichen Fehlermeldung; es wird nicht stillschweigend ersetzt.

Fehlt ein passender Interpreter, fragt das interaktive Setup nach Zustimmung. Fuer eine gezielte
Freigabe der privaten Buildwerkzeuge:

```bash
bash scripts/tools/archivebox_install.sh --install-build-deps
```

Diese Freigabe umfasst bei Bedarf uv und eine **private Python-3.13-Laufzeit**. uv bezieht Python
aus Astrals [python-build-standalone](https://github.com/astral-sh/python-build-standalone) auf
GitHub ([offizieller uv-Weg](https://docs.astral.sh/uv/guides/install-python/)). Das ist eine
binaere Buildwerkzeug-Ausnahme, kein CPython-Source-Build. Die konkrete Patch-/Buildversion wird vom
geprueften uv-Katalog ausgewaehlt; sie ist hier nicht mit einer eigenen festen Archiv-SHA256
gepinnt. Nach dem Download werden Pfad, Version und lokale Dateihashes fuer die Wiederverwendung
geprueft. Kein Anspruch auf vollstaendig reproduzierbare Python-Binaerbuilds.

Ziel: `~/.openclaw_ultimate_user_data/tools/archivebox/toolchain/archivebox-python313/`. Es werden
weder `/usr/bin/python3`, globale Launcher noch der globale PATH veraendert. Beim Bootstrap gelten
**9216 MiB** Reserve (8192 + 1024 MiB Puffer), unter WSL auch fuer C:. Ein zusaetzlich benoetigter
uv-Bootstrap behaelt seine eigene Reservepruefung. Nur der bewusste Python-Install-Schritt darf
downloaden; venv-Erstellung und App-Build verwenden weiterhin `--no-python-downloads`. Ohne
Zustimmung, bei EOF oder im Dry-Run kein Download. Ein fehlgeschlagener neuer Python-Bootstrap wird
bereinigt; bereits vorhandene Toolchains und Daten werden nicht geloescht. Die fertige private
Python-Basis bleibt bei spaeterem App-Fehler und App-Deinstallation erhalten.

## Quellen, Speicher und Lifecycle

- ArchiveBox wird als Python-Paket aus dem lokalen gepinnten GitHub-Checkout gebaut.
- uv **0.13.5** ist eine explizite binaere Buildwerkzeug-Ausnahme aus dem
  [offiziellen GitHub-Release](https://github.com/astral-sh/uv/releases/tag/0.13.5), mit festen
  Groessen und SHA256 fuer Linux amd64/arm64.
- Eine passende vorhandene uv-Version wird bevorzugt. Private Basis unter
  `~/.openclaw_ultimate_user_data/tools/archivebox/toolchain/`; nur Kindprozesse erhalten den PATH.
  Dateien, Hashes und Version werden bei Wiederverwendung geprueft.
- Beim neuen Bootstrap gelten **8448 MiB** Reserve: 8192 MiB Toolreserve plus 256 MiB Puffer, unter
  WSL auch fuer den Windows-Host. Schutzgrenzen bleiben erhalten.
- Fehlgeschlagenes Download-/Entpack-Staging wird entfernt; keine fertige uv- Markierung vor
  erfolgreicher Versionspruefung. Vorhandene Daten bleiben erhalten.
- Die fertige private Toolchain bleibt bei spaeterem App-Fehler oder App- Deinstallation erhalten.
  Abhaengigkeiten duerfen aus PyPI kommen; kein Anspruch, dass der gesamte Dependency-Graph
  ausschliesslich aus GitHub gebaut wird.

Browser, Codecs und externe Archivierungsprogramme werden nicht automatisch eingerichtet. Kein
`archivebox init`, `install`, `setup`, Serverstart, Crawl, Cookieimport oder Accountzugriff.
Archivierte Seiten koennen aktiven und vertraulichen Inhalt enthalten: Rechte, Zugriffsschutz und
Retention gesondert planen.

Offline-Fixtures pruefen den Bootstrap-Vertrag. Ein echter Ubuntu-/WSL-Build und die vollstaendige
Archivierungsfunktion wurden hier nicht abgenommen. Siehe
[Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show archivebox
```

### SSH-Aktionen: `archivebox`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run archivebox --action status
python3 -I -B scripts/tool_commands.py run archivebox --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run archivebox --action install --apply --confirm archivebox:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run archivebox --action update --apply --confirm archivebox:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run archivebox --action uninstall --apply --confirm archivebox:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
