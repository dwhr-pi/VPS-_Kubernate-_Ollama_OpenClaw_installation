# Kubernetes GPU Orchestrator

Profil fuer K3s-/Kubernetes-basierte GPU-, Render-, LLM- und Science-Worker.

## Fokus

- K3s, Prometheus, Grafana, Node Exporter und optional cAdvisor
- GPU-Worker fuer Ollama, ComfyUI, Blender, Molekuelsimulation und Batchjobs
- klare Trennung zwischen MiniPC, VPS, GPU-Workstation und Worker-Nodes
- Ressourcenlimits, Queues und Healthchecks

## Sicherheit

GPU-Worker sollten nicht ungeschuetzt im Internet stehen. Secrets gehoeren in Kubernetes-Secrets oder externe Secret-Stores, nicht ins Repo.

## Installation

```bash
bash scripts/profiles/Kubernetes_GPU_Orchestrator_install.sh
```
