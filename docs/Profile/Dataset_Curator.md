# Dataset Curator

## Status

- Standardstatus: planned / documentation-first
- Automatische Installation: nein
- Ressourcenklasse: medium
- Zielhost: WSL2 / MiniPC / Oracle VPS

## Zweck

Datasets kuratieren, bereinigen, labeln und dokumentieren.

## Tools

Optionaler Video-Pfad: `hf_datasets`, `hf_hub`, `video2dataset`, alle planned/documentation-first.
[Einsteigeranleitung und Quellenkatalog](../media_studio/VIDEO_TRAINING_DATASETS.md). Keine
automatische Installation, kein Download oder Training durch das Profil.

- docling
- unstructured
- duckdb

## Sicherheitsgrenzen

- Keine schweren Installationen ohne explizites Opt-in.
- Keine Secrets in Repo, Logs oder Queue-Kommandos.
- Admin-Dienste nur lokal oder ueber WireGuard/Tailscale/Reverse Proxy mit Auth.

## Checks vor Aktivierung

- `bash scripts/check_resource_budget.sh`
- `bash scripts/check_secrets.sh --dry-run`
- `bash scripts/check_ports.sh`
- Falls Queue: `bash scripts/queue/queue_status.sh`

## TODO vor stable

- Fuer Video: Lizenz/Attribution/Einwilligung und gepinnte Dataset-/Modellrevision; reale
  SSD-/Cache-/Egresslimits, passende Decoder/Trainer und Split-/Duplikatpruefung.
- MiniPC/WSL2/VPS zuerst nur Metadaten/Einzelbeispiel, GPU-Training separat planen.
- OpenClaw/n8n nur als geplanter Freigabeablauf; Daten/Captions sind untrusted input.

- Installer, Uninstaller, Doctor, Portdoku, Rollback und Testmatrix ergaenzen.
