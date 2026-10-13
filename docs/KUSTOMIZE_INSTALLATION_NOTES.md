# Kustomize aus GitHub installieren

Der vorgelegte Logausschnitt endet vor einer abschliessenden apt-Meldung.
Ein Abbruchgrund ist daraus nicht sicher ableitbar. Der bisherige Installer
setzt jedoch ein `kustomize`-Paket in den konfigurierten apt-Quellen voraus.
Stattdessen nutzt er jetzt die offiziellen
[Release-Assets](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.8.2).

## Ablauf

```bash
bash scripts/tools/kustomize_install.sh --dry-run
bash scripts/tools/kustomize_install.sh
kustomize version
```

Standard: v5.8.2, Linux amd64 (Intel/AMD) oder arm64. Andere Systeme/Architekturen
werden abgelehnt. Optional `KUSTOMIZE_VERSION=vX.Y.Z` setzen; das Release muss
passende Assets und checksums.txt enthalten. Die Release-Tags enthalten den
Praefix `kustomize/`, nicht nur die Versionsnummer.

SHA256 wird vor Entpacken und Ausfuehren gegen checksums.txt geprueft. Diese
Pruefung schuetzt gegen inkonsistente Downloads, ist aber kein unabhaengiger
Signaturnachweis, da Manifest und Archiv aus derselben Quelle kommen.
Nur das Binary wird nach `/usr/local/bin/kustomize` installiert. apt liefert
gegebenenfalls curl/tar/CA-Zertifikate/coreutils, nicht Kustomize selbst.

Der Installer plant 256 MB freie Disk als Reserve. Kein Docker, Node, Python,
Server-Port oder Kubernetes-Cluster erforderlich. Der Client-Test verwendet
nur `version`; keine Manifeste werden angewendet. Ein bestehendes Binary am
Ziel wird ersetzt, kubeconfig und Projektdateien bleiben unberuehrt.

## Deinstallation und Tests

```bash
bash scripts/tools/kustomize_uninstall.sh --dry-run
bash scripts/tools/kustomize_uninstall.sh
bash tests/kustomize_release_test.sh
```

Die Deinstallation entfernt ausschliesslich dieses Binary. Andere apt-/Snap-
Installationen werden nicht entfernt; bei Versionsabweichungen `type -a kustomize`
pruefen. `kubectl kustomize` kann eine andere eingebettete Version verwenden.
Registry bleibt planned bis zum echten Linux-/ARM-Test. Mock-Tests und Syntax-
Pruefung ersetzen keinen echten Release-Download; keine WSL-Installation erfolgt
durch die Tests.
