# LLMOps_Control_Center

## Zweck
Zentrale Betriebsuebersicht fuer lokale und optionale Cloud-LLM-Dienste: Routing, Monitoring, Kosten, Healthchecks und Sicherheitsstatus.

## Typische Aufgaben
- Modellendpunkte pruefen und dokumentieren.
- LiteLLM/Open WebUI/Ollama/Grafana/Langfuse Status zusammenfassen.
- Ausfaelle, Kostenanstieg und ungewuenschte Remote-Nutzung erkennen.

## Empfohlene Tools
Ollama, LiteLLM, Open WebUI, Langfuse, OpenLIT, Prometheus, Grafana, Uptime Kuma.

## Hardwarebedarf und Status
Hardware: mittel, server-tauglich. Status: planned. Installationsart: local, WSL2, VPS optional mit Auth.

## Datenschutz und Sicherheit
Prompt-/Trace-Daten koennen personenbezogene oder vertrauliche Inhalte enthalten. UIs nur lokal, per Tailnet oder mit starker Auth.

## Beispiel-Prompt
`Pruefe meine lokalen LLM-Dienste, fasse Kosten-/Latenzrisiken zusammen und schlage sichere Fallbacks vor.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5-coder:7b`, `mistral-nemo`. Cloud optional: GPT-4.1/4o-kompatible Modelle mit Kostenlimit.

## Grenzen
Kein automatisches Umschalten auf teure Cloud-Modelle ohne Freigabe.
