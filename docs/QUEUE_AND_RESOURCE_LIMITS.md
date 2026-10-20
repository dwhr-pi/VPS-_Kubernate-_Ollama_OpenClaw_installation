# Queue and Resource Limits

Aktueller Umfang und Grenzen: [Codex Task Queue](CODEX_TASK_QUEUE.md).
Start-Gates sind keine harten Ressourcenlimits; nicht alle schweren Installer
sind bereits global durch eine Queue erzwungen.

## Default

- Max parallel Jobs: 1
- Prioritaeten: low, normal, high
- Status: queued, running, done, failed, cancelled
- Logpfad: `~/.openclaw/job-queue/logs/`
- Minimalformat: TSV unter `~/.openclaw/job-queue/jobs.tsv`
- SQLite ist als optionaler Legacy-Pfad vorhanden; nicht gleichzeitig mit TSV
  unter abweichenden Queue-Konfigurationen betreiben.

## Befehle

```bash
bash scripts/queue/queue_add.sh --priority normal -- "echo test"
bash scripts/queue/queue_status.sh
bash scripts/queue/queue_run_next.sh
bash scripts/queue/queue_cancel.sh <job_id>
```

## Grenzen

- Schwere Jobs nur ueber Queue.
- Kein Job ohne Timeout.
- Keine Secrets in Kommandos.
- Bei Low-RAM/Low-Disk keine neuen Jobs starten.

## Schwere Jobtypen

Airbyte, n8n-Build, Blender-Build, ComfyUI, Modell-Downloads, Kubernetes-Deployments und Media-Render.
