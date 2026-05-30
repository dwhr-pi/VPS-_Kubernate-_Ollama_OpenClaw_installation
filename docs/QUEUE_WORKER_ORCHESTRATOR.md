# Queue Worker Orchestrator

## Ziel
Codex-, OpenClaw-, n8n- und Agenten-Auftraege sollen nicht parallel alles ueberlasten. Die Minimalvariante nutzt eine lokale SQLite-Queue ohne Zusatzserver und startet standardmaessig maximal einen Job gleichzeitig.

## Minimalvariante
- Backend: SQLite.
- Parallelitaet: `MAX_PARALLEL_JOBS=1`.
- Prioritaeten: `low`, `normal`, `high`.
- Status: `queued`, `running`, `done`, `failed`, `paused`.
- Logpfad: `~/.openclaw/job-queue/logs/`.
- Config: `~/.openclaw/job-queue/config.env`.

## Spaeter optional
- Redis/RQ.
- RabbitMQ/Celery.
- BullMQ.
- n8n Trigger.
- OpenClaw Gateway Integration.

## CLI
```bash
bash scripts/queue/queue_submit.sh --priority normal -- "echo test"
bash scripts/queue/queue_status.sh
bash scripts/queue/queue_pause.sh
bash scripts/queue/queue_resume.sh
bash scripts/queue/queue_worker.sh
```

## Sicherheitsregeln
- Keine Secrets in Queue-Kommandos schreiben.
- Lange Jobs bekommen Timeout und eigenes Log.
- Worker startet keine Jobs, wenn RAM, Swap oder Load kritisch sind.
- Schwere Media-, Kubernetes-, Airbyte- oder Build-Jobs nur nach Preflight.

