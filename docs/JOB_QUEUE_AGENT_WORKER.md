# Job Queue Agent Worker

Der Job Queue Agent Worker verhindert, dass Codex-, OpenClaw-, n8n- oder
Setup-Auftraege unkontrolliert parallel starten.

## Ziel

- einfache lokale Queue ohne Docker als Standard
- Auftraege seriell abarbeiten
- konfigurierbare Parallelitaet, default `1`
- CPU-/RAM-/Load-Schutz
- Retry-Zaehler
- Timeout pro Job
- Log pro Job
- Status: `queued`, `running`, `failed`, `done`, `skipped`

## Warum?

Schwere Tools wie AutoGPT, Airbyte, ComfyUI, Blender oder Render-Pipelines
koennen WSL2, Docker, VPS oder GPU-Workstations stark belasten. Die Queue gibt
dem Setup einen sanften Sicherheitsgurt.

## CLI

```bash
bash scripts/tools/job_queue_install.sh --prepare
bash scripts/tools/job_queue_submit.sh "echo hello"
bash scripts/tools/job_queue_status.sh
bash scripts/tools/job_queue_worker.sh start
bash scripts/tools/job_queue_worker.sh logs <job_id>
```

## OpenClaw Integration

OpenClaw soll lange oder riskante Tasks nicht direkt ausfuehren, sondern als Job
einreichen:

```bash
bash scripts/tools/job_queue_submit.sh "bash scripts/tools/autogpt_install.sh"
```

## n8n Integration

n8n kann per Execute Command oder Webhook einen Job einreichen. Der Worker
arbeitet ihn ab, schreibt Logs und n8n kann spaeter Status/Logs abrufen.

## Codex-Nachbau Integration

Ein lokaler Codex-Worker kann Pull-/Build-/Testaufgaben in die Queue legen, statt
mehrere Shellprozesse gleichzeitig zu starten.

## Ressourcenlimits

Konfiguration liegt unter:

```text
~/.openclaw_ultimate_user_data/job_queue/config.env
```

Wichtige Werte:

- `JOB_QUEUE_MAX_PARALLEL=1`
- `JOB_QUEUE_MAX_LOAD=4`
- `JOB_QUEUE_MIN_FREE_MB=2048`
- `JOB_QUEUE_TIMEOUT_SECONDS=3600`
- `JOB_QUEUE_MAX_RETRIES=1`

## Keine Secrets

Job-Kommandos duerfen keine API-Keys oder Tokens enthalten. Secrets gehoeren in
lokale `.env`-Dateien ausserhalb des Repositories.
