# Roadmap

Diese Roadmap beschreibt die naechsten sinnvollen Ausbauschritte fuer das Repository als stabile LLMOps-Plattform.

## Phase 1: Konsolidierung

- `config/tools.yml`, `config/profiles.yml`, `config/ports.yml` als zentrale Wahrheit ausbauen
- `setup_ultimate.sh` schrittweise aus den Registries generieren
- Dubletten zwischen alten und neuen Profilen sichtbar markieren
- Healthcheck- und Portcheck-Skripte in das Hauptmenue einhaengen

## Phase 2: Reifegrad der Installer

- mehr Installer direkt aus GitHub-Quellen aufbauen
- `DRY_RUN=1` und `SAFE_MODE=1` konsistent ueber alle neuen Installer ziehen
- Rollback-Konzept pro Profil vereinheitlichen
- Backup vor groesseren Profil- oder Stack-Aenderungen automatisch anbieten

## Phase 3: Medien- und GPU-Workflows

- GPU-/VRAM-Pruefung pro Bild-/Video-Profil schaerfen
- Modellordner-Management fuer ComfyUI/Forge standardisieren
- NVIDIA-, CUDA- und WSL2-Hinweise weiter praezisieren
- Batch-Rendering und Modell-Caches besser dokumentieren

## Phase 4: Plattform und Betrieb

- GitHub Actions ausbauen
- Shellcheck, Markdownlint, Linkcheck und Secret-Scan als Pflichtpruefungen
- Monitoring- und Backup-Profile direkt im Hauptsetup verdrahten
- Kubernetes/K3s-Manifeste optional weiter ausbauen, aber nicht zum Zwangspfad machen

## Phase 5: Sicherheit und Governance

- Secret-Handling weiter haerten
- SOPS/age optional vorbereiten
- Cloudflare-Tunnel-, Trading- und Web3-Hinweise weiter standardisieren
- Shell-/Browser-/Filesystem-Agenten in Safe-Mode noch deutlicher abschirmen
