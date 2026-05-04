# Profil: Local_AI_App_Builder

## Zweck

Lokale KI-Apps, interne Dashboards und kleine Werkzeuge mit Low-Code-Backends und Open-WebUI-naher Benutzeroberflaeche.

## Installierbare Kern-Tools

- `appsmith`
- `budibase`
- `nocodb`
- `directus`
- `open_webui`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `Streamlit`, `Gradio`, `FastAPI`, `Electron`, `Tauri`

## Hardware / Plattform

- gut fuer `MiniPC`, `WSL2`, `VPS`
- CPU-lastig, kaum GPU-Bedarf

## Risiken und Grenzen

- App-Builder erzeugen schnell viele UIs, Ports und Rollenmodelle
- interne Apps default nur lokal oder hinter Auth freigeben

## Quickstart

```bash
bash scripts/profiles/Local_AI_App_Builder_install.sh
```
