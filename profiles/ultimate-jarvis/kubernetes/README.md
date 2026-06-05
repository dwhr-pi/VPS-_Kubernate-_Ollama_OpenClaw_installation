# Ultimate JARVIS Kubernetes Notes

Status: planned

Kubernetes/K3s is optional for Ultimate JARVIS. Start with local services first. Move workloads to K3s only after:

- secrets management is ready
- network policies are defined
- backups are tested
- GPU workers are labeled
- admin access is protected by VPN

Suggested labels:

```yaml
ai.daniel/role: jarvis-worker
ai.daniel/gpu: "false"
ai.daniel/memory: "true"
```
