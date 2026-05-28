# Local First Cost Control

## Ziel

Das Setup bevorzugt lokale Modelle, lokale Verarbeitung und vorhersehbare Kosten.

## Regeln

- Lokale Ollama-Modelle zuerst.
- Cloud-Modelle nur mit expliziter Freigabe.
- LiteLLM/OpenRouter/OpenAI-kompatible APIs nur mit Kostenlimit.
- Video-, Bild- und Musik-Cloud-APIs immer mit Warnung.
- Agenten duerfen externe APIs nicht ohne Human Approval nutzen.

## Messwerte

Jedes Tool/Profil soll langfristig erfassen:

- erwartete Installationszeit
- erwarteter Speicherbedarf
- RAM/SWAP
- GPU/CPU
- Cloud/API-Key noetig ja/nein
- Docker/Podman noetig ja/nein

Fehlende Werte:

- Zeit: `--:--:--`
- Speicher: `--.- MB`
