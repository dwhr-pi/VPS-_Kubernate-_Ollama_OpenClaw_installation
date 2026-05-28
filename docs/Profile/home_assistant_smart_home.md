# home_assistant_smart_home

Status: `documentation-first`

## Zweck
Home Assistant, MQTT, lokale Sprache, Ollama und OpenClaw als Smart-Home-Assistent verbinden.

## Modelle
- Lokal/Ollama: `llama3.2:1b` fuer einfache Intent-Erkennung
- Optional extern: nicht empfohlen fuer private Smart-Home-Daten

## Tools
Home Assistant, Mosquitto, Node-RED, Whisper/faster-whisper, Piper, Tailscale.

## Beispielprompt
`Erstelle eine sichere Home-Assistant-Automation mit manueller Freigabe fuer jede schreibende Aktion.`

## Sicherheitsregeln
Keine Tueren, Heizungen, Alarmanlagen oder kritische Geraete ohne Human Approval schalten.

## Speicher-/Kostenkontrolle
Lokale STT/TTS bevorzugen. Cloud-Sprachdienste nur bewusst aktivieren.

## Workflows
Sprache -> Whisper -> Intent -> OpenClaw-Pruefung -> Home Assistant Freigabe -> Aktion.

## OpenClaw-Agent
`home-assistant-agent`: read-only Status automatisch, Aktionen nur nach Bestaetigung.
