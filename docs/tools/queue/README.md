# Queue Manager fuer OpenClaw, Codex und n8n

Der Queue Manager ist ein geplanter Sicherheits- und Stabilitaetsbaustein. Er
soll verhindern, dass schwere Jobs parallel starten und WSL2, VPS oder GPU-
Workstations ueberlasten.

## Ziel

- Jobs seriell oder begrenzt parallel ausfuehren
- schwere Builds und GPU-Jobs bewusst einreihen
- OpenClaw-, Codex- und n8n-Auftraege priorisieren
- Ressourcenklasse beachten
- Abbruch und Wiederaufnahme dokumentieren

## Kandidaten

| Tool | Quelle | Einsatz |
|---|---|---|
| RQ | `https://github.com/rq/rq` | leichte Python/Redis Queue |
| Celery | `https://github.com/celery/celery` | komplexere Python Task Queue |
| Dramatiq | `https://github.com/Bogdanp/dramatiq` | Python Queue |
| BullMQ | `https://github.com/taskforcesh/bullmq` | Node/Redis Queue |
| Temporal | `https://github.com/temporalio/temporal` | schwere Workflow Engine |
| Prefect | vorhandener Tool-Kandidat | Daten-/Workflow-Orchestrierung |
| Argo Workflows | `https://github.com/argoproj/argo-workflows` | Kubernetes Workflows |

## Empfohlene maximale Parallelitaet

| System | Empfehlung |
|---|---|
| MiniPC / WSL2 | 1 Job |
| Oracle VPS | 1-2 leichte Jobs |
| Raspberry Pi | nur leichte Jobs |
| GPU Workstation | 1 schwerer Job oder 2 leichte Jobs |

## Sicherheitsregeln

- Schwere Tools starten nie automatisch.
- GPU-/Render-/Airbyte-/AutoGPT-/ComfyUI-Jobs brauchen Freigabe.
- Jobs schreiben Logs unter `~/.openclaw_ultimate_user_data/queue`.
- Secrets werden nicht in Job-Payloads gespeichert.

## Setup

```bash
bash scripts/tools/queue_manager_install.sh --dry-run
bash scripts/tools/queue_manager_install.sh --prepare
```

Dies richtet nur lokale Konfigurationsdateien ein. Eine konkrete Queue-Engine
wird spaeter bewusst ausgewaehlt.
