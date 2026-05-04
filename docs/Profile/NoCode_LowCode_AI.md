# Profil: NoCode_LowCode_AI

## Zweck

Visuelle KI- und Automationsplattform fuer Workflows, Trigger, Connectoren und Low-Code-Integrationen.

## Installierbare Kern-Tools

- `n8n`
- `activepieces`
- `node_red`
- `flowise`
- `langflow`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `Dify`, `AnythingLLM`, weitere interne Connector-Packs

## Hardware / Plattform

- gut fuer `MiniPC`, `VPS`, `Kubernetes`
- mehrere Web-UIs brauchen saubere Portplanung

## Risiken und Grenzen

- Connector-Credentials strikt ausserhalb des Repos halten
- Workflow-Designer nur intern oder via Reverse Proxy mit Auth freigeben

## Quickstart

```bash
bash scripts/profiles/NoCode_LowCode_AI_install.sh
```
