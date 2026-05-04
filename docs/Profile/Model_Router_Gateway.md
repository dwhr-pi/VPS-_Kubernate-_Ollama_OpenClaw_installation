# Profil: Model_Router_Gateway

## Zweck

Zentrale Modellschicht fuer LiteLLM, Ollama und OpenAI-kompatible APIs mit Fallbacks, Kostenkontrolle und Routing.

## Installierbare Kern-Tools

- `litellm`
- `ollama`
- `open_webui`
- `langfuse`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: Rate-Limits, getrennte Gateway-Policies, weitere Provider und Auth-Layer

## Hardware / Plattform

- gut fuer `VPS`, `MiniPC`, `Kubernetes`
- bei mehreren Modellen SSD und RAM einplanen

## Risiken und Grenzen

- Upstream-Keys und Master-Keys nur in `.env`, nie im Repo
- Gateway-Datenfluesse und Telemetrie klar trennen

## Quickstart

```bash
bash scripts/profiles/Model_Router_Gateway_install.sh
```
