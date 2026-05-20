# Chemie

Wissenschaftliches Profil fuer Chemie, Cheminformatik, Molekuelanalysen, Reaktionsideen, Laborberichte und lokale KI-gestuetzte Paper-Auswertung.

## Zweck

Dieses Profil hilft bei Molekueldaten, Strukturkonvertierung, Literaturauswertung, Spektren- und Reaktionsnotizen, ohne Laborentscheidungen ungeprueft zu automatisieren.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| RDKit | Cheminformatik, Fingerprints, Molekuelgraphen |
| OpenBabel | Molekueldateien konvertieren |
| Psi4 | Quantenchemie, ressourcenintensiv |
| DeepChem | Molecular ML und Wirkstoffdaten |

## Lokale Komponenten

- Python-venv mit JupyterLab, NumPy, SciPy, Pandas, Matplotlib
- optionale Cheminformatik-Pakete
- PDF-/Paper-Auswertung fuer Publikationen und Datenblaetter
- OpenClaw-Agenten fuer Molekuelreview und Laborprotokolle
- Dashboards fuer Messreihen, Temperaturen, pH, Druck oder Sensorwerte

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Molekuel-Reports, Spektren, Tabellen und Reaktionsnotizen |
| GPU | CUDA/ROCm-Erkennung im Installer; DeepChem/Psi4 nur optional und ressourcenbewusst |
| OpenClaw | Agenten fuer Paper-Review, Datenblatt-Zusammenfassung, Laborprotokolle und Plausibilitaet |
| Ollama | `qwen2.5-coder`, `deepseek-r1`, `llama3.1` und kleine `phi`-/`gemma`-Modelle je nach Hardware |
| Dashboards | Grafana/Prometheus fuer Sensorwerte, Messreihen, Laufzeiten und Batchstatus |
| Whisper | Sprachprotokolle und Laborbefehle nur als Textvorschlag, nie als direkte Gefahrstoffaktion |
| Home Assistant | optionale Sensorintegration fuer Temperatur, Luftfeuchte, Strom, Status und Alarme |
| Kubernetes | optionales Offloading fuer Batch-Auswertung, Molecular-ML-Experimente und grosse Reports |

## Sicherheit

KI darf keine gefaehrlichen Synthesen, Dosierungen, Explosivstoff-, Giftstoff- oder Gefahrstoffanweisungen als praktische Anleitung ausgeben. Reale Laborarbeit braucht Fachpersonal, Gefaehrdungsbeurteilung, Schutzkonzept und geltende Sicherheitsdatenblaetter.

## Installation

```bash
bash scripts/profiles/Chemie_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Chemie_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Chemie_install.sh
```
