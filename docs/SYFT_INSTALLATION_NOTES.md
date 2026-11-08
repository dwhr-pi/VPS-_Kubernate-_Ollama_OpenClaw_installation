# Syft: GitHub statt fehlendem apt-Paket

Im protokollierten Ubuntu-System ist `syft` nicht als apt-Paket verfuegbar. Der Installer verwendet
das [offizielle Anchore-Release](https://github.com/anchore/syft/releases/tag/v1.54.1). Standard ist
`v1.54.1`; `SYFT_VERSION=vX.Y.Z` kann eine andere feste Version setzen. Linux amd64 (Intel/AMD) und
arm64 werden erkannt, das Archiv wird anhand der Release-SHA256 geprueft. Vor Installation wird
`syft version` ausgefuehrt.

```bash
bash scripts/tools/syft_install.sh --dry-run
bash scripts/tools/syft_install.sh
bash scripts/tools/syft_install.sh --check
```

Der Dry-Run fuehrt keine Downloads, Paketinstallation oder Scans aus. apt wird nur fuer fehlende
Basiswerkzeuge verwendet. Das Binary liegt unter `/usr/local/bin/syft`; die Deinstallation entfernt
nur diese Datei und bewahrt SBOMs sowie Konfiguration. Der Installer startet keinen Scan
automatisch.

Die 8397 MB freier Windows-Speicher im Log verursachen nicht den apt-Paketfehler. Sie bleiben aber
ein Engpass fuer WSL-Wachstum und spaetere Image-Scans/Downloads. Der Installer prueft 256 MB
Linux-Speicher. SBOMs koennen interne Pfade und Paketinformationen enthalten und sollten gezielt
gespeichert werden. Ein echter Linux-Installationslauf steht noch aus.

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
python3 -I -B scripts/tool_commands.py show syft
```

### SSH-Aktionen: `syft`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Syft` (ID `syft`) waehlen und die Einzelfreigaben lesen.
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
