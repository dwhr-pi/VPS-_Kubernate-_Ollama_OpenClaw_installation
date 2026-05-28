# Agent_Safety_Policy_Manager

## Zweck
Regeln fuer Agenten, Tool-Nutzung, Freigaben und Abbruchbedingungen verwalten.

## Typische Aufgaben
- Human-Approval-Gates fuer Trading, Security, Smart Home und Robotik definieren.
- Allow-/Denylisten fuer Tools dokumentieren.
- Policy-Verletzungen in Logs erkennen.

## Empfohlene Tools
OpenClaw, LiteLLM, LangGraph, OPA optional, Gitleaks, policy docs.

## Hardwarebedarf und Status
Hardware: leicht. Status: planned. Installationsart: local, WSL2, VPS.

## Datenschutz und Sicherheit
Policies duerfen keine Secrets enthalten. Agenten duerfen keine realen Aktionen ohne Freigabe ausfuehren.

## Beispiel-Prompt
`Erstelle eine Policy, die Shell-, Docker-, Smart-Home- und E-Mail-Aktionen nach Risiko klassifiziert.`

## Modelle
Ollama: `llama3.1:8b`, `mistral-nemo`. Cloud optional nur fuer Review.

## Grenzen
Keine Umgehung von Benutzerfreigaben oder Sicherheitsbarrieren.
