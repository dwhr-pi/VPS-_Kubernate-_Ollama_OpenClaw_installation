# Changedetection_IO: GitHub-Paket und private uv-Basis

changedetection.io ueberwacht im spaeteren Betrieb freigegebene Webseiten auf Aenderungen. Der
Installer bereitet das Python-Paket vor, startet aber keine Watches, Browser, Benachrichtigungen
oder Webdienste.

## Fehler vom 25.10.2026: uv fehlt

Das Log um 02:05 zeigt fehlendes uv vor dem Build, keinen Speichermangel. Changedetection_IO
verwendet jetzt denselben zustimmungspflichtigen privaten uv-Bootstrap wie SearXNG und ArchiveBox.
Kein Docker-Fallback.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/changedetection_io_install.sh --dry-run
# Explicit consent for the private uv prerequisite:
bash scripts/tools/changedetection_io_install.sh --install-build-deps
bash scripts/tools/changedetection_io_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder fehlende Zustimmung genehmigt
keinen Download. Dry-Run bleibt auch mit Flag schreibfrei. Status-/Build-Aktivierung darf keine
Toolchain still herunterladen.

## Python und Quellen

Die
[Paketdefinition am GitHub-Pin](https://github.com/dgtlmoon/changedetection.io/blob/2bd1a87403b83eb6f37f9f23c04ee2555baccba0/setup.py)
verlangt **Python >=3.11**. Der Installer prueft diese Grenze vor dem uv- Download. Ein vorhandenes
passendes Python kann bewusst gewaehlt werden:

```bash
NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.12 \
  bash scripts/tools/changedetection_io_install.sh --install-build-deps
```

Das Beispiel installiert Python nicht. Kein Ersatz des System-Python und kein automatischer
Python-Download durch uv (`UV_PYTHON_DOWNLOADS=never`).

Eine passende vorhandene uv-Version wird bevorzugt. Andernfalls wird nach Zustimmung uv **0.13.5**
aus dem [offiziellen GitHub-Release](https://github.com/astral-sh/uv/releases/tag/0.13.5)
bereitgestellt: feste Dateigroessen/SHA256 fuer Linux amd64/arm64, gepruefte Version und
Dateiinventar. Diese binaere Buildwerkzeug-Ausnahme ist kein Source-Build von uv. changedetection.io
selbst wird aus dem gepinnten lokalen GitHub-Checkout installiert; Python-Abhaengigkeiten duerfen
aus PyPI stammen.

## Speicher und Datenerhalt

Bei neuer uv-Einrichtung gelten **8448 MiB** Startreserve: 8192 MiB fuer das Tool plus 256 MiB
Puffer. Unter WSL gilt die Pruefung auch fuer Windows C:. Freie Linux-Kapazitaet ersetzt keinen
freien Hostspeicher; waehrend des Builds kann weiterer Platz benoetigt werden. Die Schutzgrenze wird
nicht abgesenkt.

Private Basis unter `~/.openclaw_ultimate_user_data/tools/changedetection_io/toolchain/`. Nur
Kindprozesse bekommen deren PATH; Shellprofile und globale Pakete bleiben unveraendert. Fehler
entfernen nur neues Bootstrap-Staging, nicht bestehende Daten. Kein fertiger uv-Marker vor
erfolgreicher Versionspruefung. Eine bereits fertige Toolchain bleibt bei App-Fehler oder
App-Deinstallation erhalten.

## Paketbereitschaft ist kein Betriebsnachweis

Keine Datenmigration, Cookie-/Accountuebernahme, Browserinstallation, Playwright-Ausfuehrung,
URL-Abfrage oder Nachricht beim Installieren. Fuer spaeteren Betrieb separat planen: privater
Listener mit Auth/TLS, erlaubte Zielseiten, Zugriffsrechte, Abrufintervalle, Browser-Backend,
Benachrichtigungs- Credentials, Retention und Backup. Externe Seiten koennen sensible Inhalte und
aktive Skripte liefern; kein privilegierter Browser oder freier Zugriff auf interne Dienste nur
wegen eines erfolgreichen Paketbuilds.

Offline-Tests pruefen den Bootstrap-Vertrag. Ein echter Ubuntu-/WSL-Build, laufender Browser oder
funktionierende Watches wurden hier nicht nachgewiesen. Siehe
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
python3 -I -B scripts/tool_commands.py show changedetection_io
```

### SSH-Aktionen: `changedetection_io`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run changedetection_io --action status
python3 -I -B scripts/tool_commands.py run changedetection_io --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run changedetection_io --action install --apply --confirm changedetection_io:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run changedetection_io --action update --apply --confirm changedetection_io:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run changedetection_io --action uninstall --apply --confirm changedetection_io:uninstall
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
