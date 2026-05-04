# Profil: AI_Agent_Evaluation

## Zweck

Agenten-Benchmarks, Regressionspruefungen, Task-Erfolg, Halluzinations-Checks und Tracing fuer Coding- und Recherche-Agenten.

## Installierbare Kern-Tools

- `promptfoo`
- `langfuse`
- `openlit`
- `autogen`
- `openclaw`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `Ragas`, `DeepEval`, strukturierte Eval-Datasets und Langfuse-Datasets

## Hardware / Plattform

- gut fuer `WSL2`, `VPS`, `Workstation`
- mehr GPU/RAM bei grossen lokalen Modellen einplanen

## Risiken und Grenzen

- Eval-Ergebnisse sind nur so gut wie die Aufgaben- und Ground-Truth-Definition
- Testdaten koennen sensible Produktivfaelle spiegeln

## Quickstart

```bash
bash scripts/profiles/AI_Agent_Evaluation_install.sh
```
