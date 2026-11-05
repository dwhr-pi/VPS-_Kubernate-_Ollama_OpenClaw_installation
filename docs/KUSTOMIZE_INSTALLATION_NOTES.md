# Kustomize aus GitHub installieren

Der vorgelegte Logausschnitt endet vor einer abschliessenden apt-Meldung. Ein Abbruchgrund ist
daraus nicht sicher ableitbar. Der bisherige Installer setzt jedoch ein `kustomize`-Paket in den
konfigurierten apt-Quellen voraus. Stattdessen nutzt er jetzt die offiziellen
[Release-Assets](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize/v5.8.2).
Historischer Pfad: `https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.8.2`
(Abruf 404); das Release selbst ist unter dem unkodierten Pfad belegt.

## Ablauf

```bash
bash scripts/tools/kustomize_install.sh --dry-run
bash scripts/tools/kustomize_install.sh
kustomize version
```

Standard: v5.8.2, Linux amd64 (Intel/AMD) oder arm64. Andere Systeme/Architekturen werden abgelehnt.
Optional `KUSTOMIZE_VERSION=vX.Y.Z` setzen; das Release muss passende Assets und checksums.txt
enthalten. Die Release-Tags enthalten den Praefix `kustomize/`, nicht nur die Versionsnummer.

SHA256 wird vor Entpacken und Ausfuehren gegen checksums.txt geprueft. Diese Pruefung schuetzt gegen
inkonsistente Downloads, ist aber kein unabhaengiger Signaturnachweis, da Manifest und Archiv aus
derselben Quelle kommen. Nur das Binary wird nach `/usr/local/bin/kustomize` installiert. apt
liefert gegebenenfalls curl/tar/CA-Zertifikate/coreutils, nicht Kustomize selbst.

Der Installer plant 256 MB freie Disk als Reserve. Kein Docker, Node, Python, Server-Port oder
Kubernetes-Cluster erforderlich. Der Client-Test verwendet nur `version`; keine Manifeste werden
angewendet. Ein bestehendes Binary am Ziel wird ersetzt, kubeconfig und Projektdateien bleiben
unberuehrt.

## Deinstallation und Tests

```bash
bash scripts/tools/kustomize_uninstall.sh --dry-run
bash scripts/tools/kustomize_uninstall.sh
bash tests/kustomize_release_test.sh
```

Die Deinstallation entfernt ausschliesslich dieses Binary. Andere apt-/Snap- Installationen werden
nicht entfernt; bei Versionsabweichungen `type -a kustomize` pruefen. `kubectl kustomize` kann eine
andere eingebettete Version verwenden. Registry bleibt planned bis zum echten Linux-/ARM-Test.
Mock-Tests und Syntax- Pruefung ersetzen keinen echten Release-Download; keine WSL-Installation
erfolgt durch die Tests.

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
python3 -I -B scripts/tool_commands.py show kustomize
```

### SSH-Aktionen: `kustomize`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Kustomize` (ID `kustomize`) waehlen und die Einzelfreigaben lesen.
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
