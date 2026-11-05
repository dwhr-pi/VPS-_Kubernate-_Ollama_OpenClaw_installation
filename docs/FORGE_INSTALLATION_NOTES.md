# Forge: Multiple top-level packages

Der generische Installer versuchte `pip install -e` auf dem Forge-Root. Forge ist eine Webanwendung
mit vielen Verzeichnissen; dieser Root ist fuer diesen Installationsweg ungeeignet. Der
setuptools-Fehler ist deshalb ein Installerfehler. Ubuntu 24.04 verwendet zudem Python 3.12.

Der neue Installer waehlt Python 3.10/3.11 und verwendet Forge's
[Upstream-Vorbereitung](https://github.com/lllyasviel/stable-diffusion-webui-forge/blob/main/modules/launch_utils.py)
mit `launch.py --exit`. Er prueft Abhaengigkeiten, startet keinen Webserver und fordert keinen
SD-Modell-Download an. PyTorch und andere Abhaengigkeiten werden von Upstream heruntergeladen; das
kann mehrere GB beanspruchen.

```bash
bash scripts/tools/stable_diffusion_webui_forge_install.sh --check
# Wenn ein passendes Python bereits vorhanden ist:
FORGE_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/stable_diffusion_webui_forge_install.sh
```

Der Installer sucht auch vorhandene isolierte Python-3.11-Installationen unter
`/opt/openclaw-python`. Er baut in diesem Schritt kein weiteres Python und ersetzt das System-Python
nicht. Ohne kompatiblen Interpreter stoppt er frueh. `--dry-run` prueft Python und zeigt den Plan
ohne Installation.

Die neue Umgebung liegt unter `/opt/stable_diffusion_webui_forge/venv`. Die `.venv` aus dem
fehlgeschlagenen Versuch bleibt erhalten; vorhandene Modelle und Outputs werden nicht geloescht.
Eine inkompatible vorhandene `venv` wird nicht automatisch ersetzt.

Mindestens 40 GB freier Linux-Speicher werden geprueft; unter WSL zusaetzlich den
Windows-Datentraeger mit der VHDX beachten. Die Installationsvorbereitung ueberspringt den CUDA-Test
und ist daher kein Nachweis fuer GPU-/Bildgenerierung. Fuer den manuellen Start sind passende
GPU-Treiber und ein Modell erforderlich:

```bash
cd /opt/stable_diffusion_webui_forge
venv/bin/python launch.py --server-name 127.0.0.1 --no-download-sd-model
```

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
python3 -I -B scripts/tool_commands.py show stable_diffusion_webui_forge
```

### SSH-Aktionen: `stable_diffusion_webui_forge`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Stable Diffusion WebUI Forge` (ID `stable_diffusion_webui_forge`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
