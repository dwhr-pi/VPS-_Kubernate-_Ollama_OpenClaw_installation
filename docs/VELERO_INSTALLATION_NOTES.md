# Velero: Download liefert 404

Der alte Installer verlangte `velero-linux-amd64.tar.gz`. Dieser Name entspricht nicht den
offiziellen Release-Dateien. Das Archiv heisst beispielsweise `velero-v1.18.4-linux-amd64.tar.gz`.
Siehe [offizielle Release-Dateien](https://github.com/velero-io/velero/releases/tag/v1.18.4). Das
bisherige Repository `vmware-tanzu/velero` wird auf `velero-io/velero` umgeleitet.

Der Installer nutzt jetzt eine feste Version (Standard `v1.18.4`), die passende Linux-Architektur
amd64 oder arm64 und die Release-Pruefsummen aus `CHECKSUM`. Nur das CLI-Binary wird entpackt, mit
`version --client-only` getestet und nach `/usr/local/bin/velero` installiert. Version nach Bedarf
passend zum Velero-Server mit `VELERO_VERSION=vX.Y.Z` vorgeben.

```bash
bash scripts/tools/velero_install.sh --dry-run
bash scripts/tools/velero_install.sh
bash scripts/tools/velero_install.sh --check
```

Der Dry-Run benoetigt weder Download noch sudo. Es wird kein Velero-Server im Cluster installiert,
kein Backup gestartet und kein Cloud-Zugang eingerichtet. Die Registry bleibt bis zum echten
Installationslauf auf `planned`.

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
python3 -I -B scripts/tool_commands.py show velero
```

### SSH-Aktionen: `velero`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Velero` (ID `velero`) waehlen und die Einzelfreigaben lesen.
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
