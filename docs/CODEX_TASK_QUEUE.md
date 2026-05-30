# Codex Task Queue

## Ziel
Codex-, OpenClaw-, n8n- und Setup-Auftraege sollen nicht parallel das System ueberlasten. Die Queue ist standardmaessig FIFO und startet maximal einen Job gleichzeitig.

## Minimalmodus
- Format: TSV-Datei unter `~/.openclaw/job-queue/jobs.tsv`.
- Config: `~/.openclaw/job-queue/config.env`.
- Logs: `~/.openclaw/job-queue/logs/`.
- Parallelitaet: `MAX_PARALLEL_JOBS=1`.
- Prioritaeten: `low`, `normal`, `high`.
- Status: `queued`, `running`, `done`, `failed`, `paused`, `cancelled`.

## Befehle
```bash
bash scripts/queue/queue_add.sh --priority normal -- "echo Hallo"
bash scripts/queue/queue_status.sh
bash scripts/queue/queue_run_next.sh
bash scripts/queue/queue_cancel.sh <job_id>
bash scripts/queue/queue_worker.sh
```

## Schwere Jobs
Diese Jobs sollen spaeter nur ueber Queue laufen:

- n8n-Monorepo-Build
- Blender-Build
- Airbyte
- ComfyUI
- grosse Modell-Downloads
- Kubernetes-/K3s-Deployments
- Media-/Avatar-/RVC-/DiffSinger-Renderjobs

## Opt-in Flags
- `QUEUE_ENABLE_WORKER=1`
- `INSTALL_HEAVY_TOOLS=1`
- `MEDIA_INSTALL_MODE=full`
- `SECURITY_INSTALL_SCANNERS=1`

## Sicherheitsregeln
- Keine API-Keys oder Tokens in Queue-Kommandos schreiben.
- Jeder Job braucht Timeout und Log.
- Bei Low-RAM/Low-Disk keine neuen Jobs starten.
- Fehler erzeugen Diagnose statt Endlosschleifen.

