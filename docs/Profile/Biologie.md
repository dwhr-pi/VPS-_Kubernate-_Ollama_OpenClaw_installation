# Biologie

Profil fuer biologische Datenanalyse, Mikroskopie, Single-cell-Workflows, Paper-Auswertung und lokale Forschungsassistenz.

## Zweck

Das Profil unterstuetzt Biologie-Workflows mit JupyterLab, OpenClaw, Ollama, optionaler Bildanalyse und Home-Assistant-Sensorintegration fuer Laborumgebungen.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| Biopython | Sequenzen, Formate, Bio-Daten |
| Scanpy | Single-cell Analyse |
| Napari | Mikroskopie- und Bildanalyse |

## Komponenten

- Python-venv und Notebook-Struktur
- lokale KI fuer Paper, Protokolle, Hypothesen und Bildanalyse-Erklaerung
- Whisper fuer Sprachprotokolle
- Dashboards fuer Inkubator-, Temperatur-, Feuchte- oder CO2-Sensoren
- Kubernetes-Offloading fuer groessere Batch-Analysen

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Omics, Mikroskopie, Tabellen, QC und Visualisierung |
| GPU | CUDA/ROCm-Erkennung im Installer; Bildanalyse und ML optional GPU-beschleunigt |
| OpenClaw | Agenten fuer Methodenvergleich, Laborprotokolle, Datenqualitaet und Reproduzierbarkeit |
| Ollama | `qwen2.5`, `qwen2.5-coder`, `deepseek-r1`, `llama3.1` und kleine `gemma`-/`phi`-Modelle |
| Dashboards | Grafana/Prometheus fuer Sensorwerte, Batchstatus, QC-Metriken und Laufzeiten |
| Whisper | Sprachprotokolle und Beobachtungsnotizen; keine autonome Laborsteuerung |
| Home Assistant | optionale Sensorintegration fuer Temperatur, Luftfeuchte, CO2, Strom und Status |
| Kubernetes | optionales Offloading fuer Omics-Batches, Bildanalyse und lange QC-Laeufe |

## Grenzen

Keine medizinische Diagnose, keine eigenmaechtige Biohazard- oder Nasslabor-Anleitung, keine Freisetzung oder Kultivierung ohne Fach- und Sicherheitspruefung.

## Installation

```bash
bash scripts/profiles/Biologie_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Biologie_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Biologie_install.sh
```
