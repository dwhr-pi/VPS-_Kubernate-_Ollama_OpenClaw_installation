# Profil: Synthetic_Data_Lab

## Zweck

Synthetische Testdaten, RAG-Fragen, Prompt-Testfaelle und vorbereitende Datenarbeit fuer lokale AI-Systeme.

## Installierbare Kern-Tools

- `duckdb`
- `jupyterlab`
- `minio`
- `promptfoo`
- `llamaindex`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `DVC`, `Label Studio`, `Argilla`, strukturierte Datengeneratoren

## Hardware / Plattform

- gut fuer `WSL2`, `MiniPC`, `Workstation`
- fuer grosse Datensaetze SSD und RAM einplanen

## Risiken und Grenzen

- synthetische Daten klar von Echt- und Produktionsdaten trennen
- Anonymisierung nicht nur behaupten, sondern pruefen

## Quickstart

```bash
bash scripts/profiles/Synthetic_Data_Lab_install.sh
```
