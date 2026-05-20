# Molekuelsimulation

Profil fuer Molekulardynamik, Trajektorienanalyse, Strukturreview, GPU-Simulation und lokale KI-gestuetzte Auswertung.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| OpenMM | Molekulardynamik mit GPU-Unterstuetzung |
| LAMMPS | Partikel- und Materialsimulation |
| GROMACS | Molekulardynamik, HPC-orientiert |
| MDTraj | Trajektorienanalyse |

## Lokaler Stack

- Python-venv fuer Analyse und Notebooks
- CUDA/ROCm-Erkennung
- JupyterLab-Notebooks fuer Trajektorien, RMSD, Energie, Visualisierung
- OpenClaw-Agent fuer Simulationsplanung und Fehleranalyse
- Kubernetes-Offloading fuer Batchjobs auf GPU-Nodes

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Parameter, Trajektorienanalyse, Plots und Report-Export |
| GPU | CUDA/ROCm-Erkennung; OpenMM/GROMACS/LAMMPS bleiben bewusst optional und ressourcenintensiv |
| OpenClaw | Agenten fuer Simulationsplanung, Log-Auswertung, Plausibilitaet und Reproduzierbarkeit |
| Ollama | `qwen2.5-coder`, `deepseek-r1`, `llama3.1`, `phi4` fuer Analyse und Python-Code |
| Dashboards | Grafana/Prometheus fuer GPU, Temperatur, Laufzeit, Queue und Speicherverbrauch |
| Whisper | Sprachkommandos fuer Notizen und Jobbeschreibungen, nicht fuer unkontrollierte Jobs |
| Home Assistant | optionale Sensorintegration fuer Temperatur, Strom und Laborumgebung |
| Kubernetes | optionales Offloading fuer lange MD-Laeufe, GPU-Worker und Batch-Parameterstudien |

## Installation

```bash
bash scripts/profiles/Molekuelsimulation_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Molekuelsimulation_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Molekuelsimulation_install.sh
```

## Grenzen

Kraftfelder, Parameter, Randbedingungen und Konvergenz muessen fachlich geprueft werden. GPU-Ergebnisse sind auf Reproduzierbarkeit zu pruefen.
