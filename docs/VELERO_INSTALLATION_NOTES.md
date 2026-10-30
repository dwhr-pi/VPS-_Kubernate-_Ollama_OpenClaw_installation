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
