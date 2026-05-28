# WSL2 Safe Install Path

## Reihenfolge

1. Setup aktualisieren.
2. Systemprofil pruefen.
3. Minimalsetup installieren.
4. Speicher- und Portchecks ausfuehren.
5. Nur ein mittleres/schweres Tool pro Durchlauf testen.
6. Nach Fehlern Cleanup-Trockenlauf lesen.

## Befehle

```bash
bash scripts/update_setup_only.sh
bash scripts/system_profile_detect.sh
bash scripts/check_ports.sh
bash scripts/cleanup_installation_residues.sh --dry-run --all
```

## WSL2-Spezialregeln

- Windows-C:-Speicher ist genauso wichtig wie Linux-`df -h`.
- Airbyte/AutoGPT/ComfyUI koennen nach Fehlschlag viele GB belegen.
- Git-`M`-Listen koennen Datei-Modus-Aenderungen sein: `git diff --summary` pruefen.
