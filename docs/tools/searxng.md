# SearXNG: natives GitHub-Paket ohne Docker

SearXNG ist eine selbst betriebene Metasuchmaschine: Sie fragt externe Suchmaschinen ab und buendelt
deren Ergebnisse. Das ist fuer Recherche und Agenten-Workflows nuetzlich, aber nicht automatisch
offline oder anonym.

## Fehler im Installationsprotokoll

Der Versuch vom 24.10.2026 scheiterte an **fehlendem `uv`**, nicht an der ersten
Speicherplatzpruefung. Diese war allerdings nur knapp bestanden: 8213 MiB auf Windows C: gegen 8192
MiB Mindestreserve.

Der Installer bevorzugt vorhandenes `uv` ab der hier geprueften Baseline 0.13.5. Fehlt es oder ist
es aelter, kann er nach ausdruecklicher Zustimmung eine private Kopie aus dem offiziellen
GitHub-Release bereitstellen. Die Versionsgrenze ist unsere Installer-Baseline, keine behauptete
SearXNG-Mindestanforderung.

```bash
bash scripts/tools/searxng_install.sh --dry-run
# Explicit consent for the private build prerequisite:
bash scripts/tools/searxng_install.sh --install-build-deps
bash scripts/tools/searxng_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal nach Zustimmung; ohne Zustimmung oder bei
nichtinteraktiver Ausfuehrung wird nichts heruntergeladen. Ein reiner Dry-Run installiert auch mit
Flag nichts.

## Speicher und Voraussetzungen

Fuer einen neuen uv-Bootstrap werden **8448 MiB** freier Zielspeicher und unter WSL auch freier
Windows-Host-Speicher verlangt: 8192 MiB Reserve plus 256 MiB Download-/Entpackpuffer. Im genannten
Log fehlen dafuer 235 MiB. Deutlich mehr freizumachen ist sinnvoll; diese Vorpruefung garantiert
nicht, dass jede spaetere Abhaengigkeit bei knappem Speicher erfolgreich baut. Die Sicherheitsgrenze
wird nicht abgesenkt.

Ein vorhandenes Python 3.10 bis 3.13 mit SSL/venv ist erforderlich; der Installer begrenzt sich
konservativ auf diese Versionsreihe. Bei Bedarf
`NATIVE_SOURCE_PYTHON_BIN=/absoluter/pfad/python3.12` setzen. Python wird nicht heruntergeladen und
das System-Python bleibt unveraendert.

## Herkunft, Umfang und Daten

- Hauptprogramm:
  [SearXNG am festen Commit](https://github.com/searxng/searxng/tree/81371861f67226091d1c4df2e3908a11d3b54eb9).
- Buildwerkzeug: [uv 0.13.5](https://github.com/astral-sh/uv/releases/tag/0.13.5), offizielle
  Linux-amd64-/arm64-Archive, feste Dateigroesse und SHA256 im Helper.
- [Offizielle uv-Installationsdokumentation](https://docs.astral.sh/uv/getting-started/installation/).

SearXNG wird aus GitHub-Quellen in einer privaten Umgebung paketiert. Python-Abhaengigkeiten kommen
ueber den Paketmanager; dies ist kein vollstaendig offline oder ausschliesslich aus GitHub gebauter
Dependency-Graph. Das uv-Release ist eine ausdrueckliche Binaer-Ausnahme fuer ein Basiswerkzeug,
kein Docker-Image und kein Ersatz des SearXNG-Quellbuilds.

uv liegt unter `~/.openclaw_ultimate_user_data/tools/searxng/toolchain/`. Nur der Buildprozess
erhaelt dessen PATH; Shellprofile und globale Programme bleiben unberuehrt. Archive werden vor
Ausfuehrung geprueft, beim Wiederverwenden werden die privaten Dateien nochmals gegen ihren
gespeicherten Nachweis geprueft. Das ist keine unabhaengige Signaturpruefung gegen einen lokalen
Angreifer. uv-Konfigurationsdateien und automatische Python-Downloads sind deaktiviert.

Der Paketbau verwendet explizit die Einstellungen aus dem Quellenverzeichnis, nicht versehentlich
eine produktive `/etc/searxng/settings.yml`. Keine Suchanfragen, Webserver, Valkey-Dienste, Browser
oder Migrationen werden gestartet. Ein erfolgreiches Paket ist noch keine betriebsbereite
Suchinstanz. Vor Betrieb sind eigenes Secret, interne Bindung, Authentifizierung/Proxy, Limiter und
gegebenenfalls Valkey separat einzurichten und zu testen.

Fehlgeschlagene neue uv-Downloads hinterlassen keinen fertigen Toolchain-Marker. Eine bereits
erfolgreich bereitgestellte private uv-Basis bleibt bei einem spaeteren App-Fehler und bei der
App-Deinstallation erhalten; bestehende Container, Daten, Logs und fremde Installationen werden
nicht entfernt.

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
python3 -I -B scripts/tool_commands.py show searxng
```

### SSH-Aktionen: `searxng`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run searxng --action status
python3 -I -B scripts/tool_commands.py run searxng --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run searxng --action install --apply --confirm searxng:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run searxng --action update --apply --confirm searxng:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run searxng --action uninstall --apply --confirm searxng:uninstall
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
