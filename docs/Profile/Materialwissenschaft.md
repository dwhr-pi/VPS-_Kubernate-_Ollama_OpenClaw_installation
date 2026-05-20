# Materialwissenschaft

Profil fuer Materialdaten, Kristallstrukturen, Simulationen, Feature Engineering, Paper-Auswertung und lokale KI-Forschungsassistenz.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| pymatgen | Materialstrukturen und Analyse |
| matminer | Feature Engineering und ML fuer Materialien |
| atomate2 | automatisierte Material-Workflows |
| AiiDA | reproduzierbare wissenschaftliche Workflows |

## Komponenten

- Python/JupyterLab fuer Materialdatenanalyse
- lokale KI fuer Paper, Strukturinterpretation und Experimentplanung
- CUDA/ROCm-Erkennung fuer ML- oder Simulationsjobs
- Kubernetes-Offloading fuer Batch- und Screening-Jobs
- Dashboards fuer Messreihen, Materialparameter und Jobstatus

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Strukturen, Features, ML-Tabellen, Phasendaten und Reports |
| GPU | CUDA/ROCm-Erkennung; ML- und Simulationspfade optional GPU-beschleunigt |
| OpenClaw | Agenten fuer Paper-Auswertung, Strukturanalyse, Reproduzierbarkeit und Batchplanung |
| Ollama | `qwen2.5-coder`, `deepseek-r1`, `llama3.1`, `phi4` fuer Analyse und Python-Code |
| Dashboards | Grafana/Prometheus fuer GPU, Batchstatus, Storage, Temperatur und Simulationsqueues |
| Whisper | Sprachprotokolle fuer Labor- und Analysekommentare |
| Home Assistant | optionale Sensorintegration fuer Ofen-/Raum-/Strom-/Temperaturwerte |
| Kubernetes | optionales Offloading fuer Materials-ML, Simulationen und grosse Feature-Batches |

## Installation

```bash
bash scripts/profiles/Materialwissenschaft_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Materialwissenschaft_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Materialwissenschaft_install.sh
```

## Grenzen

Materialeigenschaften, Belastbarkeit und Sicherheitsbewertungen muessen experimentell und fachlich validiert werden.
