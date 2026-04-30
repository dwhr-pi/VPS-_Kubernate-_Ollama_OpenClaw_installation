# Kubernetes Guide

## Ziel

Kubernetes ist in diesem Repo vor allem fuer spaetere Cluster-, Sandbox- und Gateway-Szenarien relevant.

## Werkzeuge

- K3s
- kubectl
- Helm
- Kustomize
- k9s

## Einstieg

```bash
bash scripts/tools/k3s_install.sh
bash scripts/tools/kubectl_install.sh
bash scripts/tools/helm_install.sh
bash scripts/tools/kustomize_install.sh
```

## Deployments anzeigen

```bash
bash scripts/operations/show_k8s_deployments.sh
```

## Hinweise

- aktuelle YAMLs sind Beispiel- oder Ausgangswerte
- vor Produktivnutzung Secrets, Storage und Ingress härten
