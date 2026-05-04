# AI_App_Builder

## Zweck
Kleine KI-Webapps, Dashboards und interne Tools lokal und selbst gehostet bauen.

## Typische Aufgaben
- Demo-Apps und Admin-Tools
- interne Agenten-Frontends
- schnelle APIs und Dashboards
- No-Code-/Low-Code-Ergänzungen

## Empfohlene Tools
FastAPI, Streamlit, Gradio, Appsmith, Budibase, NocoDB.

## Optionale Tools
Reflex, NiceGUI, PostgreSQL.

## Benötigte Ports
`7860`, `8090`, `8083`, `10000`, `8501`

## Ressourcenbedarf
4 bis 8 GB RAM je nach Zahl der laufenden UIs.

## Sicherheitsrisiken
Interne Tools werden schnell versehentlich öffentlich. Standardmäßig nur auf localhost oder hinter Auth betreiben.

## Ollama/OpenClaw-Fit
Gut für kleine lokale UIs und Tool-Frontends rund um Agenten und Modelle.

## LiteLLM/Open WebUI-Fit
Hilfreich als ergänzende Schicht für Spezial-Apps neben Open WebUI.

## Quickstart
`bash scripts/profiles/AI_App_Builder_install.sh`

## Deinstallation
`bash scripts/profiles/AI_App_Builder_uninstall.sh`

## Sinnvolle lokale Modelle
Kleinere Chat-, Extraktions- und Tool-Calling-Modelle für schnelle App-Reaktionen.

## Grenzen und Warnhinweise
Viele kleine Apps erzeugen Port- und Pflegeaufwand. Reverse Proxy und Doku früh strukturieren.
