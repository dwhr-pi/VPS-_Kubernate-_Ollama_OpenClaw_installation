# Kubectl auf Ubuntu/WSL

Im protokollierten Ubuntu-noble-System ist `kubectl` in den eingebundenen apt-Quellen nicht
vorhanden. Der Installer laedt deshalb das offizielle Binary von `dl.k8s.io`, prueft SHA256 und
testet `version --client` vor Installation nach `/usr/local/bin/kubectl`. Unterstuetzt sind
Intel/AMD x86_64 und ARM64.

GitHub-Projekt: <https://github.com/kubernetes/kubernetes> Offizielle Anleitung:
<https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>

```bash
bash scripts/tools/kubectl_install.sh --dry-run
bash scripts/tools/kubectl_install.sh
bash scripts/tools/kubectl_install.sh --check
```

Ohne Vorgabe wird die stabile Version einmal ermittelt. Fuer einen vorhandenen Cluster
`KUBECTL_VERSION=vX.Y.Z` explizit passend setzen. Laut Kubernetes soll der Client hoechstens eine
Minor-Version vom API-Server abweichen. `--dry-run` fuehrt weder Downloads noch Paketinstallationen
aus. apt wird nur fuer fehlende Systemabhaengigkeiten verwendet.

Die Deinstallation entfernt nur `/usr/local/bin/kubectl`. Andere Installationen und `~/.kube`
bleiben bestehen. Es wird kein Cluster angelegt und kein Port geoeffnet. Die Registry bleibt bis zu
einem echten Linux-Installationslauf auf `planned`; lokale Tests pruefen Logik und Pruefsummen.
