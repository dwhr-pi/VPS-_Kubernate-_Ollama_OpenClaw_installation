# Beispiel: Kubernetes Renderfarm

Node-Labels:

```bash
kubectl label node gpu-node-1 gpu=true render=blender
kubectl label node gpu-node-2 gpu=true ai=comfyui
kubectl label node storage-node storage=assets
```

Empfehlung:

- Kleine Setups lokal starten.
- Kubernetes erst nutzen, wenn Renderjobs wirklich parallelisiert werden.
- GPU-Worker mit klaren Limits, Storage-Pfaden und Warteschlangen betreiben.

