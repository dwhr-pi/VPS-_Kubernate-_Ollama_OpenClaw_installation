# Resource Requirements

Diese Seite beschreibt praxisnahe Mindestanforderungen für Profile und ausgewählte Plattform-Bausteine.

## Globale Basis

- CPU: 4 Kerne empfohlen
- RAM: 8 GB absolutes Minimum
- Storage: 25 GB Minimum für ein kleines lokales Setup

## Profile

| Profil | CPU | RAM | Storage | Hinweise |
|---|---:|---:|---:|---|
| `Programmierer` | 4+ | 16 GB | 20 GB | Für große Coding-Modelle eher 32 GB |
| `LLM_Builder` | 8+ | 32 GB | 80 GB | Für Fine-Tuning, GGUF und Quantisierung |
| `RAG_Wissensdatenbank` | 4+ | 16 GB | 20 GB | Dokumentenbestand wächst stark |
| `Security_DevSecOps` | 4+ | 8 GB | 10 GB | Container-Scans können temporär mehr Platz brauchen |
| `Monitoring_Observability` | 4+ | 12 GB | 20 GB | Langfuse, Grafana und Loki speichern Logs/Traces |
| `Backup_Recovery` | 2+ | 4 GB | datenabhängig | Backups niemals nur lokal halten |
| `Image_Generation` | 8+ | 16 GB | 40 GB | GPU empfohlen |
| `Video_Generation` | 8+ | 24 GB | 60 GB | VRAM und Disk intensiv |
| `Audio_Voice_Music` | 4+ | 8 GB | 15 GB | Für schnellere Transkription GPU hilfreich |
| `Office_Productivity` | 4+ | 12 GB | 30 GB | OCR und DMS wachsen schnell |
| `Data_Engineering` | 4+ | 16 GB | 40 GB | Datenbanken und Artefakte |

## GPU-Hinweise

- GPU-Profile sollten vor Installation `nvidia-smi` oder `rocminfo` erfolgreich auswerten können.
- Ohne GPU bleiben `Image_Generation`, `Video_Generation` und größere lokale LLMs oft nur eingeschränkt praktikabel.

## Vor und nach Installationen

Die neue Lib [scripts/lib/resource_check.sh](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/lib/resource_check.sh:1) stellt bereit:

- freier Speicher
- RAM
- CPU-Kerne
- GPU-Hinweise

Aufruf:

```bash
bash scripts/lib/resource_check.sh --summary
```
