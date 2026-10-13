# K9s: GitHub-Installation

Das protokollierte Ubuntu-noble-System bietet `k9s` nicht in seinen apt-Quellen.
Der Installer verwendet deshalb das offizielle GitHub-Release von
[derailed/k9s](https://github.com/derailed/k9s/releases/tag/v0.51.0).
Standard ist `v0.51.0`; `K9S_VERSION=vX.Y.Z` erlaubt eine andere feste Version.

Linux x86_64 (Intel/AMD) und ARM64 werden erkannt. Das Archiv wird anhand von
`checksums.sha256` geprueft und nur das Binary `k9s` entpackt. `k9s version`
wird vor der Installation nach `/usr/local/bin/k9s` als Smoke-Test ausgefuehrt.
apt wird nur fuer fehlende Basiswerkzeuge verwendet.

```bash
bash scripts/tools/k9s_install.sh --dry-run
bash scripts/tools/k9s_install.sh
bash scripts/tools/k9s_install.sh --check
```

Der Dry-Run fuehrt keine Downloads oder Installation aus. Die Deinstallation
entfernt nur das Setup-Binary. K9s-Konfiguration und `~/.kube` bleiben erhalten.
Es wird kein Cluster angelegt und kein Server-Port geoeffnet.
Die Registry bleibt bis zum echten Linux-Installationslauf auf `planned`.
