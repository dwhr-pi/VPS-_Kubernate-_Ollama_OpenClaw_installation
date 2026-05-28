# Kubernetes Optional

## Wann lohnt sich Kubernetes?

- mehrere Nodes
- reproduzierbare Deployments
- klare Storage-/Secret-Strategie
- Monitoring/Ingress/Backup vorhanden

## Wann reicht systemd oder Docker Compose?

- Einzelner MiniPC
- WSL2
- kleine VPS
- lokale KI-Tests
- Tools mit wenigen Services

## k3s Low-Budget

k3s kann spaeter sinnvoll sein, wenn Host-Hardening, Backups, Ports und Ressourcen stabil sind. Nicht als Default fuer Erstinstallation.

## GPU-Nodes spaeter

GPU-Nodes brauchen Treiber, Runtime, Storage, Modellordner und klare Ressourcenlimits.

## Vorlage

Helm-/K8s-Struktur darf vorbereitet werden, aber keine Cluster-Installation ohne explizite Zustimmung.
