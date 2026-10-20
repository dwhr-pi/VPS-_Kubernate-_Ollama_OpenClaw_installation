# Queue Worker Orchestrator

Aktueller gemeinsamer Vertrag fuer TSV/SQLite, Sperren und bewusst fehlende
Funktionen: [Codex Task Queue](CODEX_TASK_QUEUE.md). Die folgenden SQLite-
Beispiele sind kein eigenstaendiger parallel laufender Worker-Dienst.

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
- Worker prueft verfuegbares RAM, Load und Disk vor dem Start; keine harte
  Swap-/GPU-/CPU-Limitierung und keine laufende Ressourcenueberwachung.
- Schwere Media-, Kubernetes-, Airbyte- oder Build-Jobs nur nach Preflight.

