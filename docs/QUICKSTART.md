# Quickstart

## Minimal lokal

```bash
bash scripts/preflight.sh
bash install.sh
```

Empfohlen: Ollama, OpenClaw, Programmierer-Profil, kleine lokale Modelle.

## Sicherer Pfad

- keine Cloud-Keys setzen
- Dienste nur auf `127.0.0.1`
- Remotezugriff erst spaeter via Tailscale oder Cloudflare Access
- schwere Tools nur mit Opt-in

## Diagnose

```bash
bash scripts/doctor.sh
bash scripts/next_level_dry_run_check.sh
```
