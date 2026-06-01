# Helm Installation Notes

## Warum `apt install helm` fehlschlaegt

Ubuntu 24.04/Noble liefert in den Standard-Repositories kein offizielles Paket `helm`.
Der Fehler

```text
E: Unable to locate package helm
```

ist deshalb erwartbar, wenn der Installer `apt` verwendet.

## Stabiler Installationspfad

Das Setup verwendet Helm nicht mehr ueber `apt`, sondern ueber das offizielle Helm-Release:

```text
GitHub-Projekt: https://github.com/helm/helm
Release-Dateien: https://get.helm.sh/
```

Der Installer:

1. ermittelt die neueste Version ueber die GitHub API,
2. erkennt die Architektur,
3. laedt das passende Release-Archiv,
4. laedt die `.sha256sum`,
5. prueft SHA256,
6. installiert `helm` nach `/usr/local/bin/helm`,
7. prueft `helm version --short`.

## Architektur

| System | Asset |
| --- | --- |
| Intel/AMD 64-bit | `linux-amd64` |
| ARM64 / Raspberry Pi 5 / Oracle Ampere | `linux-arm64` |
| 32-bit ARM | `linux-arm` |

## Vorab pruefen

```bash
bash scripts/tools/helm_install.sh --check
bash scripts/tools/helm_install.sh --dry-run
```

## Feste Version

```bash
HELM_VERSION=v3.15.4 bash scripts/tools/helm_install.sh
```

## Sicherheit

Helm selbst ist nur ein CLI-Tool. Die sensiblen Daten liegen meist in `kubeconfig`, Helm-Values und Kubernetes-Secrets. Diese Dateien gehoeren nicht ins Repo.

