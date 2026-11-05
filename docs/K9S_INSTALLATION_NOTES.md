# K9s: GitHub-Installation

Das protokollierte Ubuntu-noble-System bietet `k9s` nicht in seinen apt-Quellen. Der Installer
verwendet deshalb das offizielle GitHub-Release von
[derailed/k9s](https://github.com/derailed/k9s/releases/tag/v0.51.0). Standard ist `v0.51.0`;
`K9S_VERSION=vX.Y.Z` erlaubt eine andere feste Version.

Linux x86_64 (Intel/AMD) und ARM64 werden erkannt. Das Archiv wird anhand von `checksums.sha256`
geprueft und nur das Binary `k9s` entpackt. `k9s version` wird vor der Installation nach
`/usr/local/bin/k9s` als Smoke-Test ausgefuehrt. apt wird nur fuer fehlende Basiswerkzeuge
verwendet.

```bash
bash scripts/tools/k9s_install.sh --dry-run
bash scripts/tools/k9s_install.sh
bash scripts/tools/k9s_install.sh --check
```

Der Dry-Run fuehrt keine Downloads oder Installation aus. Die Deinstallation entfernt nur das
Setup-Binary. K9s-Konfiguration und `~/.kube` bleiben erhalten. Es wird kein Cluster angelegt und
kein Server-Port geoeffnet. Die Registry bleibt bis zum echten Linux-Installationslauf auf
`planned`.

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
python3 -I -B scripts/tool_commands.py show k9s
```

### SSH-Aktionen: `k9s`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`K9s` (ID `k9s`) waehlen und die Einzelfreigaben lesen.
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
