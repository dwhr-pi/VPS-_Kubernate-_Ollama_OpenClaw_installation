# Physik

Wissenschaftliches Profil fuer lokale Physik-Workflows mit Ollama, OpenClaw, Codex, JupyterLab und optionalem Kubernetes-Offloading.

## Zweck

Dieses Profil unterstuetzt numerische Simulation, Datenanalyse, Paper-Auswertung, Modellvergleich und mehrsprachige Erklaerungen fuer klassische Physik, Quantenphysik, Plasmaphysik und simulationsnahe Forschung.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| QuTiP | Quantenoptik und offene Quantensysteme |
| PlasmaPy | Plasmaphysik, Partikel, Einheiten und Analyse |
| yt | Volumendaten, Simulationen, Astrophysik |

Die kuratierte Liste liegt in `profiles/science_lab/github_projects.tsv`.

## Lokale Komponenten

- Python-venv mit JupyterLab, NumPy, SciPy, SymPy, Pandas und Matplotlib
- optionale QuTiP-/PlasmaPy-/yt-Installation
- PDF-/Paper-Auswertung ueber Document-Tools und OpenClaw
- Whisper-Sprachsteuerung fuer Notizen und Laborprotokolle
- Home-Assistant-Sensorimport fuer Messwerte
- Grafana/Prometheus-Dashboards fuer Experimente

## GPU und Offloading

CUDA wird ueber `nvidia-smi`, ROCm ueber `rocminfo` erkannt. GPU-Beschleunigung ist optional und abhaengig von den verwendeten Bibliotheken. Kubernetes-Offloading eignet sich fuer lange Parameterstudien, Monte-Carlo-Jobs und Batch-Auswertungen.

## OpenClaw-Agenten

- Physik-Forschungsassistent
- Paper-Reviewer
- Simulationsplaner
- Datenanalyse-Agent
- Reproduzierbarkeitspruefer

## Ollama-Modellvorschlaege

| Modell | Einsatz |
|---|---|
| `qwen2.5:7b` | kompakte mehrsprachige Erklaerungen |
| `qwen2.5-coder:7b` | Python/Jupyter-Code |
| `deepseek-r1:8b` | Herleitungen, Plausibilitaetspruefung |
| `phi4:14b` | Mathematik und Analyse |

## Installation

```bash
bash scripts/profiles/Physik_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Physik_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Physik_install.sh
```

## Grenzen

Simulationsergebnisse muessen validiert werden. KI darf keine experimentellen Sicherheitsfreigaben ersetzen.

