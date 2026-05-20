# Robotik_Labor

Profil fuer sichere Laborrobotik, Sensorik, Pipettier-/Messgeraete, ROS-2-nahe Simulation, OpenClaw-Agenten und Home-Assistant-Integration.

## GitHub-Projekte

| Projekt | Zweck |
|---|---|
| ROS 2 | Robotik-Middleware |
| MoveIt 2 | Bewegungsplanung |
| ros2_control | Controller-Interfaces |
| Opentrons | Laborautomation und Pipettierroboter |

## Sicherheitsregel

Standardmodus ist Simulation, Diagnose und Vorschlag. Reale Aktoren, Roboter, Pumpen, Pipettierer oder Laborgeraete duerfen nur mit menschlicher Freigabe, Not-Aus, Interlocks, Grenzwerten und Protokollierung angesteuert werden.

## Komponenten

- Python-venv fuer Sensorik, MQTT, Modbus, Serial und Bildverarbeitung
- Whisper fuer Sprachbefehle als Vorschlaege
- Home Assistant fuer Sensorstatus und Laborumgebung
- Grafana/Prometheus fuer Messwerte
- Kubernetes-Offloading fuer Bild- und Batchanalyse

## Science-Lab-Integration

| Bereich | Umsetzung |
|---|---|
| JupyterLab | Notebooks fuer Sensordaten, Bildanalyse, Kalibrierung und Versuchsreports |
| GPU | CUDA/ROCm-Erkennung; Bildverarbeitung und Simulation optional GPU-beschleunigt |
| OpenClaw | Agenten fuer Diagnose, Sicherheitscheck, Versuchsdokumentation und Simulationsplanung |
| Ollama | `qwen2.5-coder`, `deepseek-coder`, `llama3.1`, `phi4` fuer Code, Logs und Erklaerungen |
| Dashboards | Grafana/Prometheus fuer Sensorwerte, Roboterstatus, Queue, Temperatur und Alarme |
| Whisper | Sprachbefehle werden nur als Vorschlag oder Checkliste verarbeitet |
| Home Assistant | Sensorstatus, Strom, Temperatur, Luftfeuchte, Laborampeln und Alarmkontakte |
| Kubernetes | optional fuer Bildanalyse, Batch-Auswertung, Simulationen und GPU-Worker |

## Installation

```bash
bash scripts/profiles/Robotik_Labor_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Robotik_Labor_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Robotik_Labor_install.sh
```
