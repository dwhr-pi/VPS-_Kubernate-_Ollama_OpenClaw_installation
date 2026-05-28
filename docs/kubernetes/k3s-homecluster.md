# K3s Homecluster

K3s ist fuer dieses Setup der bevorzugte Kubernetes-Pfad. Es ist leichter als
vollstaendiges Kubernetes und passt besser zu VPS, Raspberry Pi und Homelab.

## Rollen

- Oracle VPS: optional K3s Server / Control Plane
- Raspberry Pi 5 / Mini-PC: Waechter und optional Edge Node
- RTX Server: On-Demand GPU Worker

## Labels

GPU Node:

```bash
kubectl label node GPU_NODE_NAME ai.daniel/gpu=true
```

Waechter:

```bash
kubectl label node HOME_WATCHER_NODE ai.daniel/watcher=true
```

## Sicherheitsregeln

- Kubernetes API nicht oeffentlich freigeben.
- Zugriff auf `6443` nur via WireGuard/Admin-Netz.
- Secrets nicht in Git speichern.
- SOPS oder Sealed Secrets optional nutzen.
- Network Policies vorbereiten.
- GPU Workloads gezielt auf GPU Node schedulen.

## Beispiele

- [GPU Node Labels](../../examples/k3s/gpu-node-labels.yaml)
- [Network Policies](../../examples/k3s/network-policies.yaml)
