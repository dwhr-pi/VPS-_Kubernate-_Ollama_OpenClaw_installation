# Recommended Minimal Setup

Ziel: stabiler Einstieg fuer WSL2/MiniPC ohne schwere Containerlast.

## Empfohlen

- Ollama mit kleinen Modellen
- OpenClaw
- Open WebUI
- Qdrant oder ChromaDB, nicht beide sofort
- Gitleaks, Trivy, ShellCheck, shfmt
- Uptime Kuma oder Healthchecks
- Restic/Rclone fuer Backup

## Nicht im Minimalpfad

- Airbyte
- AutoGPT
- ComfyUI/Forge/vLLM
- K3s/Kubernetes
- Nextcloud/Activepieces/n8n parallel

## Vorher pruefen

```bash
bash scripts/system_profile_detect.sh
bash scripts/check_ports.sh
bash scripts/cleanup_installation_residues.sh --dry-run --all
```
