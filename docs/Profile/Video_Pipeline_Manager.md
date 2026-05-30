# Video Pipeline Manager

## Status

- Standardstatus: planned / documentation-first
- Automatische Installation: nein
- Ressourcenklasse: gpu-heavy
- Zielhost: RTX-Workstation / Kubernetes GPU

## Zweck

Video-Pipeline fuer Schnitt, Render, ComfyUI und Queue-Jobs.

## Tools

- ffmpeg
- comfyui
- blender

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

- Installer, Uninstaller, Doctor, Portdoku, Rollback und Testmatrix ergaenzen.
