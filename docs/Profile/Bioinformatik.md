# Bioinformatik

Profil fuer Sequenzanalyse, Genomik, Workflows, Datenpipelines, Paper-Auswertung und lokale KI-Assistenz fuer Bioinformatik.

## Zweck

Dieses Profil bereitet eine modulare, lokale Bioinformatik-Umgebung mit Python, JupyterLab, OpenClaw-Agenten, Dokumentanalyse und optionalem Kubernetes-Offloading vor.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| Biopython | Sequenzparser und Bio-Datenformate |
| nf-core tools | Nextflow-Workflow-Standards |
| Galaxy | Bioinformatik-Plattform |
| Bioconda Recipes | Tool- und Paketreferenzen |

## Workflows

- FASTA/FASTQ/VCF/CSV auswerten
- Paper und Methoden vergleichen
- Pipeline-Reports zusammenfassen
- Multi-Agent-Review fuer Reproduzierbarkeit
- lokale Dashboards fuer Laufzeiten, Fehler und Datenqualitaet

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Sequenzanalyse, Tabellen, QC, Varianten und Reports |
| GPU | CUDA/ROCm-Erkennung; GPU nur fuer passende ML-/Alignment- oder Bildpfade optional |
| OpenClaw | Agenten fuer Pipeline-Review, Paper-Auswertung, Reproduzierbarkeit und Fehlerdiagnose |
| Ollama | `qwen2.5-coder`, `deepseek-coder`, `deepseek-r1`, `llama3.1` und kleine `phi`-/`gemma`-Modelle |
| Dashboards | Grafana/Prometheus fuer Pipeline-Laufzeiten, Fehler, Storage und Queue-Status |
| Whisper | Sprachsteuerung fuer Notizen, Suchauftraege und Report-Kommentare |
| Home Assistant | optional fuer Labor-/NAS-/Mini-PC-Sensorik und Strom-/Temperaturstatus |
| Kubernetes | optional fuer Nextflow-/Snakemake-nahe Worker, Batchjobs und GPU-Offloading |

## Installation

```bash
bash scripts/profiles/Bioinformatik_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Bioinformatik_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Bioinformatik_install.sh
```

## Hinweis

Patienten-, Genom- und Studiendaten sind sensibel. Lokale Verarbeitung, Pseudonymisierung und klare Zugriffskontrolle sind Pflicht.
